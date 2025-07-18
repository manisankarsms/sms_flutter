// lib/services/web_notification_stub.dart
// This file provides stub implementations for web platform

class FlutterLocalNotificationsPlugin {
  // Stub implementation for web
  Future<void> initialize(dynamic settings, {Function? onDidReceiveNotificationResponse}) async {
    // No-op for web
  }

  Future<void> show(int id, String? title, String? body, dynamic details, {String? payload}) async {
    // No-op for web
  }

  T? resolvePlatformSpecificImplementation<T>() => null;
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String icon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({
    bool requestAlertPermission = false,
    bool requestBadgePermission = false,
    bool requestSoundPermission = false,
  });
}

class InitializationSettings {
  const InitializationSettings({
    AndroidInitializationSettings? android,
    DarwinInitializationSettings? iOS,
  });
}

class NotificationResponse {
  final String? payload;
  NotificationResponse({this.payload});
}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(
      String channelId,
      String channelName, {
        String? channelDescription,
        dynamic importance,
        dynamic priority,
        String? icon,
      });
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails();
}

class NotificationDetails {
  const NotificationDetails({
    AndroidNotificationDetails? android,
    DarwinNotificationDetails? iOS,
  });
}

class AndroidNotificationChannel {
  const AndroidNotificationChannel(
      String id,
      String name, {
        String? description,
        dynamic importance,
      });
}

class AndroidFlutterLocalNotificationsPlugin {
  Future<void> createNotificationChannel(AndroidNotificationChannel channel) async {
    // No-op for web
  }
}

// Mock enums
enum Importance { high }
enum Priority { high }