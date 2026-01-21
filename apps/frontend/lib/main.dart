import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'src/core/di/service_locator.dart';
// Localization temporarily disabled - uncomment when needed
// import 'src/core/localization/app_localizations.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/theme/theme_service.dart' show themeNotifier;
import 'src/features/auth/data/repositories/auth_repository.dart';
import 'src/features/auth/presentation/bloc/auth_bloc.dart';
import 'src/features/auth/presentation/bloc/auth_event.dart';
import 'src/core/notifications/push_notification_service.dart'
    show PushNotificationService, firebaseMessagingBackgroundHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (non-blocking for web)
  if (kIsWeb) {
    // On web, load .env asynchronously without blocking initial render
    dotenv.load(fileName: '.env').catchError((Object e) {
      debugPrint('⚠️ Could not load .env file: $e');
    });
  } else {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('✅ Environment variables loaded successfully');
    } catch (e) {
      debugPrint('⚠️ Could not load .env file: $e');
    }
  }

  // Setup service locator (critical path - must be fast)
  try {
    await setupServiceLocator();
  } catch (e, stackTrace) {
    // Log error but don't crash - show error UI instead
    debugPrint('❌ Failed to setup service locator: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue anyway - error will be shown in UI
  }

  // Create Auth BLoC (needed for initial routing)
  final authBloc = AuthBloc(
    authRepository: getIt<AuthRepository>(),
  );

  // Check authentication status on app start
  authBloc.add(const CheckAuthEvent());

  // Start app immediately - defer Firebase and push notifications
  runApp(
    FacilityErpApp(authBloc: authBloc),
  );

  // Initialize Firebase and push notifications AFTER first frame (non-blocking)
  // This improves Time to Interactive (TTI) by deferring non-critical initialization
  if (kIsWeb) {
    // On web, defer Firebase initialization until after first paint
    // This allows the app to render faster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFirebaseAndPushNotifications();
    });
  } else {
    // For native, initialize immediately (not performance-critical)
    _initializeFirebaseAndPushNotifications();
  }
}

/// Initialize Firebase and push notifications asynchronously
/// This is deferred to improve initial load time and Time to Interactive (TTI)
Future<void> _initializeFirebaseAndPushNotifications() async {
  try {
    if (kIsWeb) {
      // Web Firebase is initialized via script in index.html
      // But we still need to initialize it in Flutter for consistency
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized for web (deferred)');
    } else {
      // For native apps (Android, iOS, macOS)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized for ${defaultTargetPlatform.name} (deferred)');
    }

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize push notification service
    try {
      await PushNotificationService().initialize();
    } catch (e) {
      debugPrint('⚠️ Push notification initialization skipped: $e');
    }
  } catch (e, stackTrace) {
    debugPrint('⚠️ Firebase initialization error (non-critical): $e');
    debugPrint('Stack trace: $stackTrace');
    // Don't rethrow - Firebase is not critical for initial app load
  }
}

class FacilityErpApp extends StatefulWidget {
  const FacilityErpApp({
    super.key,
    required this.authBloc,
  });

  final AuthBloc authBloc;

  @override
  State<FacilityErpApp> createState() => _FacilityErpAppState();
}

class _FacilityErpAppState extends State<FacilityErpApp> {
  @override
  Widget build(BuildContext context) {
    final router = AppRouter(widget.authBloc).router;

    return RepositoryProvider<AuthRepository>.value(
      value: getIt<AuthRepository>(),
      child: BlocProvider<AuthBloc>.value(
        value: widget.authBloc,
        child: ValueListenableBuilder<Color>(
          valueListenable: themeNotifier,
          builder: (context, primaryColor, _) {
            return MaterialApp.router(
              title: 'TENX',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(primaryColor: primaryColor),
              darkTheme: AppTheme.darkTheme(primaryColor: primaryColor),
              themeMode: ThemeMode.system,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
              ],
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
