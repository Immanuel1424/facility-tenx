import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Conditional import for web notifications
import 'dart:html' as html;

import '../di/service_locator.dart';
import '../network/api_client.dart';

/// Service for managing Firebase Cloud Messaging (FCM) push notifications
///
/// **Web-First Implementation**: This service is optimized for web browser push notifications.
/// - Uses VAPID key for web push (required)
/// - Service worker handles background notifications (firebase-messaging-sw.js)
/// - Browser notifications work in both foreground and background
/// - Mobile platforms are supported but web is the primary use case
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Get VAPID key for web push notifications
  /// Get this from Firebase Console: Project Settings > Cloud Messaging > Web Push certificates
  /// If no key pair exists, click "Generate key pair"
  /// Priority: 1) FCM_VAPID_KEY from .env file, 2) Fallback constant
  static String? get _vapidKey {
    try {
      // First try to get from environment variables
      final envKey = dotenv.env['FCM_VAPID_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        return envKey;
      }
    } catch (e) {
      // dotenv not loaded or key not found, use fallback
    }
    // Fallback VAPID key (can be overridden via .env)
    return 'BI98TapONqeOaoSUnUzo3qFohhdeTL2m_-OzZi9fkXm9OK2C9gK9cjDVyvKB-nHtOCLqE0pjLkiAGU6j4hgmkCI';
  }

  /// Initialize push notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('PushNotificationService already initialized');
      return;
    }

    try {
      // For web, configure service worker path first
      if (kIsWeb) {
        try {
          // Register service worker for Firebase Messaging
          // The service worker must be at the root: /firebase-messaging-sw.js
          await _firebaseMessaging.setAutoInitEnabled(true);
          debugPrint('✅ Firebase Messaging auto-init enabled for web');
        } catch (e) {
          debugPrint('⚠️ Service worker registration warning: $e');
          // Continue anyway - service worker may already be registered
        }
      }

      // Request notification permission
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
          '📱 Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('✅ User granted notification permission');

        // Initialize notifications based on platform
        if (kIsWeb) {
          // For web, initialize browser notifications
          await _initializeWebNotifications();
        } else {
          // For mobile, initialize local notifications
          await _initializeLocalNotifications();
        }

        // Get FCM token
        // For web, VAPID key is required for push notifications
        if (kIsWeb) {
          try {
            if (_vapidKey != null && _vapidKey!.isNotEmpty) {
              _fcmToken =
                  await _firebaseMessaging.getToken(vapidKey: _vapidKey);
              debugPrint('📱 FCM Token (Web with VAPID): $_fcmToken');
            } else {
              // Try without VAPID key (may work if configured in Firebase Console)
              _fcmToken = await _firebaseMessaging.getToken();
              debugPrint('📱 FCM Token (Web without VAPID): $_fcmToken');
              debugPrint(
                  '⚠️ VAPID key not configured. Web push may not work properly.');
              debugPrint(
                  '⚠️ Get VAPID key from: Firebase Console > Project Settings > Cloud Messaging > Web Push certificates');
            }
          } catch (e) {
            // Gracefully handle service worker errors - don't crash the app
            final errorStr = e.toString();
            debugPrint('❌ Error getting FCM token for web: $e');

            // Check if it's a service worker issue
            if (errorStr.contains('service worker') ||
                errorStr.contains('service-worker') ||
                errorStr.contains('messaging') ||
                errorStr.contains('404') ||
                errorStr.contains('firebase-messaging-sw')) {
              debugPrint(
                  '⚠️ Service worker registration failed. Push notifications may not work.');
              debugPrint(
                  '⚠️ This is non-critical - app will continue to work without push notifications.');
              debugPrint(
                  '⚠️ To fix: Ensure firebase-messaging-sw.js exists at web root in Docker image.');
              // Don't set _fcmToken - app will work without push notifications
              _fcmToken = null;
            } else {
              // Other errors - still log but don't crash
              debugPrint(
                  '⚠️ FCM token unavailable, but app will continue to work.');
              _fcmToken = null;
            }
            // Continue initialization - app should work without push notifications
          }
        } else {
          // For mobile platforms, no VAPID key needed
          _fcmToken = await _firebaseMessaging.getToken();
          debugPrint('📱 FCM Token: $_fcmToken');
        }

        if (_fcmToken != null) {
          // Don't send token to backend yet - wait for authentication
          // Token will be registered after successful login
          debugPrint(
              '📱 FCM token obtained, will register after authentication');
        }

        // Setup message handlers
        _setupMessageHandlers();

        // Handle token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          debugPrint('🔄 FCM Token refreshed: $newToken');
          _fcmToken = newToken;
          // Only register if already authenticated (token will be registered after auth)
          // This prevents 401 errors during token refresh before login
          if (_isAuthenticated) {
            await _sendTokenToBackend(newToken);
          } else {
            debugPrint(
                '📱 Token refreshed but not authenticated yet, will register after login');
          }
        });

        _isInitialized = true;
      } else {
        debugPrint(
            '❌ User declined notification permission: ${settings.authorizationStatus}');
        if (kIsWeb) {
          debugPrint(
              '💡 Tip: User needs to grant notification permission in browser settings');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing push notifications: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Initialize web browser notifications
  /// This sets up the browser's Notification API for web platforms
  Future<void> _initializeWebNotifications() async {
    if (!kIsWeb) {
      return;
    }

    try {
      // Check if Notification API is supported
      if (html.Notification.supported == false) {
        debugPrint('⚠️ Browser does not support Notification API');
        return;
      }

      // Check current permission status
      final permissionStatus = html.Notification.permission;
      debugPrint(
          '📱 Browser notification permission status: $permissionStatus');

      if (permissionStatus == 'granted') {
        debugPrint('✅ Browser notifications initialized and ready');
      } else if (permissionStatus == 'default') {
        debugPrint('ℹ️ Browser notification permission not yet requested');
      } else {
        debugPrint('⚠️ Browser notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing web notifications: $e');
    }
  }

  /// Initialize local notifications for mobile platforms
  /// This is for Android/iOS native notifications
  Future<void> _initializeLocalNotifications() async {
    // Skip local notifications initialization on web (use web notifications instead)
    if (kIsWeb) {
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (!kIsWeb && Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'main_channel',
        'Main Notifications',
        description: 'Notifications for maintenance tickets and updates',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Notification opened app: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // App opened from terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
            '📬 App opened from notification: ${message.notification?.title}');
        _handleNotificationTap(message);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    // For web, show browser notification (works in foreground too)
    if (kIsWeb) {
      final notification = message.notification;
      if (notification == null) return;

      try {
        // Request permission if not already granted
        if (await _checkWebNotificationPermission()) {
          // Show browser notification for foreground messages
          await _showWebNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            data: message.data,
          );
          debugPrint('📬 Web notification shown: ${notification.title}');
        } else {
          debugPrint('⚠️ Browser notification permission not granted');
        }
      } catch (e) {
        debugPrint('❌ Error showing web notification: $e');
      }
      return;
    }

    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Notifications',
      channelDescription: 'Notifications for maintenance tickets and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to relevant screen based on notification data
    final data = message.data;
    if (data.containsKey('ticketId')) {
      // Use a global navigator key or context
      // This will be handled by the app router
      debugPrint('🔗 Navigate to ticket: ${data['ticketId']}');
      // Navigation will be handled in the widget tree
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final apiClient = getIt<ApiClient>();
      final platform = _getPlatform();

      await apiClient.registerDevice(
        fcmToken: token,
        platform: platform,
        deviceInfo: _getDeviceInfo(),
      );

      debugPrint('✅ FCM token registered with backend');
    } catch (e) {
      // Only log as error if we're authenticated (expected to work)
      // If not authenticated, this is expected and shouldn't be logged as error
      if (_isAuthenticated) {
        debugPrint('❌ Failed to register FCM token: $e');
      } else {
        debugPrint('⚠️ FCM token registration skipped (not authenticated): $e');
      }
    }
  }

  /// Register FCM token with backend after successful authentication
  /// This should be called after user logs in
  Future<void> registerTokenAfterAuth() async {
    if (_fcmToken == null) {
      debugPrint('⚠️ No FCM token available to register');
      return;
    }

    _isAuthenticated = true;
    await _sendTokenToBackend(_fcmToken!);
  }

  /// Mark as unauthenticated (e.g., on logout)
  void markAsUnauthenticated() {
    _isAuthenticated = false;
  }

  String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    }
    return 'web';
  }

  Map<String, dynamic> _getDeviceInfo() {
    return {
      'platform': _getPlatform(),
      if (kIsWeb) 'userAgent': 'web',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Check if web notification permission is granted
  Future<bool> _checkWebNotificationPermission() async {
    if (!kIsWeb) return false;

    try {
      // Check if Notification API is supported
      if (html.Notification.supported == false) {
        debugPrint('⚠️ Browser does not support Notification API');
        return false;
      }

      // Actually check the browser's notification permission status
      final permission =
          html.window.navigator.permissions?.query({'name': 'notifications'});
      if (permission != null) {
        final result = await permission;
        final isGranted = result.state == 'granted';
        debugPrint('📱 Browser notification permission: ${result.state}');
        return isGranted;
      }

      // Fallback: Check using Notification.permission (synchronous)
      final permissionStatus = html.Notification.permission;
      debugPrint(
          '📱 Browser notification permission (sync): $permissionStatus');
      return permissionStatus == 'granted';
    } catch (e) {
      debugPrint('❌ Error checking notification permission: $e');
      // Fallback: Check using Notification.permission (synchronous)
      try {
        final permissionStatus = html.Notification.permission;
        return permissionStatus == 'granted';
      } catch (_) {
        return false;
      }
    }
  }

  /// Show browser notification for web platform (like email alerts)
  /// This method directly shows browser notifications for foreground messages.
  /// Background messages are handled by the service worker.
  Future<void> _showWebNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!kIsWeb) return;

    try {
      // Check permission first
      final hasPermission = await _checkWebNotificationPermission();
      if (!hasPermission) {
        debugPrint(
            '⚠️ Notification permission not granted. Current status: ${html.Notification.permission}');
        return;
      }

      // Show browser notification directly using the Notification API
      // This works for foreground messages when the app is active
      // In dart:html, Notification constructor takes title and options as a Map
      final notification = html.Notification(
        title,
        body: body,
        icon: '/icons/Icon-192.png',
      );

      // Set additional properties if supported
      try {
        // Use JS interop to set additional notification properties
        final jsNotification = notification as dynamic;
        if (data != null) {
          jsNotification.data = data;
        }
        jsNotification.tag = data?['ticketId']?.toString() ??
            data?['tag']?.toString() ??
            'notification';
        jsNotification.requireInteraction = false;
        jsNotification.silent = false;
      } catch (e) {
        // Some properties may not be supported, continue anyway
        debugPrint('⚠️ Could not set all notification properties: $e');
      }

      debugPrint('📬 Web notification shown: $title - $body');

      // Handle notification click
      notification.onClick.listen((event) {
        debugPrint('🔔 Notification clicked: $title');
        notification.close();

        // Handle navigation if ticketId is present
        if (data != null && data.containsKey('ticketId')) {
          final ticketId = data['ticketId'];
          debugPrint('🔗 Navigate to ticket: $ticketId');
          // Navigation will be handled by the app router
        }
      });

      // Auto-close after 5 seconds if not clicked
      Future.delayed(const Duration(seconds: 5), () {
        notification.close();
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error showing web notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Unregister device token (e.g., on logout)
  Future<void> unregister() async {
    if (_fcmToken != null) {
      try {
        final apiClient = getIt<ApiClient>();
        await apiClient.unregisterDevice(fcmToken: _fcmToken!);
        debugPrint('✅ FCM token unregistered');
      } catch (e) {
        debugPrint('❌ Failed to unregister FCM token: $e');
      }
    }
    _fcmToken = null;
    _isInitialized = false;
    _isAuthenticated = false;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background message: ${message.notification?.title}');
  // Handle background notification
}
