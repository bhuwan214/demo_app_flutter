import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local notifications for order updates and other in-app events.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _orderChannel =
      AndroidNotificationChannel(
    'order_updates',
    'Order Updates',
    description: 'Notifications when an order is placed or updated.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_orderChannel);
  }

  static NotificationDetails _defaultDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          _orderChannel.id,
          _orderChannel.name,
          channelDescription: _orderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  static Future<void> showOrderPlacedNotification({
    required double amount,
    String? orderId,
  }) async {
    final String title = orderId == null
        ? 'Order placed successfully'
        : 'Order #$orderId placed';
    final String body =
        'We\'re processing your order totalling Rs ${amount.toStringAsFixed(2)}.';

    await _showNotification(title: title, body: body);
  }

  static Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (title.isEmpty && body.isEmpty) {
      return;
    }

    final int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

    await _plugin.show(
      notificationId,
      title.isEmpty ? 'Notification' : title,
      body,
      _defaultDetails(),
      payload: payload,
    );
  }
}
