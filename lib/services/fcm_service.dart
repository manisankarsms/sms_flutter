import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Only import flutter_local_notifications for mobile platforms
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
if (dart.library.html) 'package:sms/services/web_notification_stub.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin? _localNotifications;

  // Initialize FCM
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Request permissions (iOS and Android)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Initialize local notifications only for mobile platforms
    if (!kIsWeb) {
      await _initializeLocalNotifications();
    } else {
      // For web, request notification permission
      await _requestWebNotificationPermission();
    }

    // Get FCM token
    String? token = await getToken();
    print('FCM Token: $token');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      print('FCM Token refreshed: $token');
      // Send token to your server
    });

    // Handle background messages (not supported on web)
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle app launch from notification
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // Get FCM token with web-specific handling
  static Future<String?> getToken() async {
    try {
      String? token;

      if (kIsWeb) {
        // For web, you need to provide the vapidKey
        // Get this from Firebase Console -> Project Settings -> Cloud Messaging -> Web configuration
        token = await _firebaseMessaging.getToken(
          vapidKey: 'BJ4mQoVHJJxHQbaRL7mQHowgnVpSxSAUeJ81rnTl2fBHoc7yTsEt35bQ2fSl_vbvr29DPmumpb8wJI-RimGXyp0', // Replace with your actual VAPID key
        );
      } else {
        // For mobile platforms
        token = await _firebaseMessaging.getToken();
      }

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Method to manually refresh token
  static Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return await getToken();
    } catch (e) {
      print('Error refreshing FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Request web notification permission
  static Future<void> _requestWebNotificationPermission() async {
    if (kIsWeb) {
      try {
        // Request notification permission for web
        NotificationSettings settings = await _firebaseMessaging.requestPermission();
        print('Web notification permission: ${settings.authorizationStatus}');
      } catch (e) {
        print('Error requesting web notification permission: $e');
      }
    }
  }

  // Initialize local notifications (mobile only)
  static Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) return; // Skip for web

    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle local notification tap
        print('Local notification tapped: ${response.payload}');
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    if (kIsWeb) {
      // For web, show browser notification
      _showWebNotification(message);
    } else {
      // For mobile, show local notification
      _showLocalNotification(message);
    }
  }

  // Show web notification
  static void _showWebNotification(RemoteMessage message) {
    if (kIsWeb) {
      print('Showing web notification: ${message.notification?.title}');
      // Web notifications are handled automatically by the browser
      // You can add custom logic here if needed
    }
  }

  // Show local notification (mobile only)
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb || _localNotifications == null) return;

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications!.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You have a new message',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    print('Data: ${message.data}');

    // Navigate to specific screen based on notification data
    // Example: Get.toNamed('/notification-detail', arguments: message.data);
  }

  // Check if FCM is supported on current platform
  static bool get isSupported {
    return true; // FCM is supported on all platforms
  }

  // Check if local notifications are supported
  static bool get isLocalNotificationSupported {
    return !kIsWeb;
  }
}

// Background message handler (must be top-level function)
// Note: This won't work on web platform
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    print('Handling background message: ${message.messageId}');
  }
}