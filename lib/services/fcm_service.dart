import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'notification_service.dart';

/// Handles Firebase Cloud Messaging registration and message streams.
class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initializes FCM: permissions, token logging, and stream listeners.
  static Future<void> initialize() async {
    await _messaging.setAutoInitEnabled(true);
    await _ensurePermissions();
    await _configureForegroundPresentation();
    await _syncInitialToken();

    // Handle app launch via notification tap (terminated state).
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async => _handleForegroundMessage(message),
    );
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    _messaging.onTokenRefresh.listen(_persistToken);
  }

  static Future<void> _ensurePermissions() async {
    // iOS / macOS require explicit permission; Android 13+ uses same API.
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('🔕 Push permission denied by the user.');
    } else {
      debugPrint('🔔 Push permission status: ${settings.authorizationStatus}.');
    }
  }

  static Future<void> _configureForegroundPresentation() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> _syncInitialToken() async {
    final String? token = await _messaging.getToken();
    await _persistToken(token);
  }

  static Future<void> _persistToken(String? token) async {
    if (token == null) {
      return;
    }

    debugPrint('📲 FCM token: $token');
    // TODO: Send token to your backend if device level targeting is required.
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message: ${message.messageId}');
    if (message.notification != null) {
      debugPrint('   Title: ${message.notification?.title}');
      debugPrint('   Body : ${message.notification?.body}');
    }

    final String? title =
        message.notification?.title ?? message.data['title']?.toString();
    final String? body =
        message.notification?.body ?? message.data['body']?.toString();

    if (title != null || body != null) {
      await NotificationService.showSimpleNotification(
        title: title ?? 'New notification',
        body: body ?? '',
        payload: message.data.isEmpty ? null : message.data.toString(),
      );
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🚪 Notification opened app: ${message.messageId}');
    if (message.data.isNotEmpty) {
      debugPrint('   Data: ${message.data}');
    }
  }
}

/// Top-level background handler required by firebase_messaging.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🌙 Handling background message: ${message.messageId}');
}
