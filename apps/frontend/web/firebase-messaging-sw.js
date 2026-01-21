// Firebase Cloud Messaging Service Worker
// This service worker handles background push notifications for web

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDOxrZ9lzyMYQycwVgYCl8SyWjlLjyRZBU",
  authDomain: "tenx-bf726.firebaseapp.com",
  projectId: "tenx-bf726",
  storageBucket: "tenx-bf726.firebasestorage.app",
  messagingSenderId: "859031041738",
  appId: "1:859031041738:web:1ff14fe363f9c41534a633",
  measurementId: "G-CE38K8FFQS"
};

// Initialize Firebase in the service worker
firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages (also works for foreground via service worker)
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received message ', payload);
  
  const notificationTitle = payload.notification?.title || payload.data?.title || 'New Notification';
  const notificationBody = payload.notification?.body || payload.data?.body || '';
  
  // Enhanced notification options (like email alerts)
  const notificationOptions = {
    body: notificationBody,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    image: '/icons/Icon-192.png', // Large image for better visibility
    tag: payload.data?.ticketId || payload.data?.tag || 'notification',
    requireInteraction: false, // Auto-close after a few seconds
    silent: false, // Play notification sound
    timestamp: Date.now(),
    vibrate: [200, 100, 200], // Vibration pattern (if supported)
    data: {
      ...payload.data,
      click_action: payload.data?.ticketId ? `/service-requests/${payload.data.ticketId}` : '/',
    },
    actions: payload.data?.ticketId ? [
      {
        action: 'view',
        title: 'View Ticket',
      },
      {
        action: 'close',
        title: 'Close',
      }
    ] : [],
  };

  // Show the notification (works for both background and foreground)
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification click received.');
  
  event.notification.close();

  // Handle navigation based on notification data
  const data = event.notification.data;
  let urlToOpen = '/';
  
  if (data && data.ticketId) {
    urlToOpen = `/tickets/${data.ticketId}`;
  }

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // Check if there's already a window/tab open with the target URL
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }
      // If not, open a new window/tab
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});

