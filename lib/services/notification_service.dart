import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/product.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked: ${response.payload}");
      },
    );

    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> checkAndShowExpiryNotification(List<Product> products) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expiringSoon = products.where((p) {
      if (p.expiryDate == null) return false;
      final exp = DateTime(p.expiryDate!.year, p.expiryDate!.month, p.expiryDate!.day);
      final differenceInDays = exp.difference(today).inDays;
      return differenceInDays >= 0 && differenceInDays <= 30;
    }).toList();

    final expired = products.where((p) {
      if (p.expiryDate == null) return false;
      final exp = DateTime(p.expiryDate!.year, p.expiryDate!.month, p.expiryDate!.day);
      return exp.isBefore(today);
    }).toList();

    if (expiringSoon.isNotEmpty || expired.isNotEmpty) {
      String title = "⚠️ تنبيه صلاحية المنتجات";
      String body = "";

      if (expired.isNotEmpty && expiringSoon.isNotEmpty) {
        body = "لديك ${expired.length} صنف منتهي الصلاحية و${expiringSoon.length} صنف ينتهي خلال شهر أو أقل.";
      } else if (expired.isNotEmpty) {
        body = "لديك ${expired.length} صنف منتهي الصلاحية حالياً!";
      } else {
        body = "لديك ${expiringSoon.length} صنف ينتهي تاريخ صلاحيته خلال شهر أو أقل.";
      }

      await _showNotification(
        id: 101,
        title: title,
        body: body,
      );
    }
  }

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expiry_channel_id',
      'تنبيهات تاريخ الانتهاء',
      channelDescription: 'تنبيهات تلقائية للمنتجات المنتهية أو القريبة من الانتهاء',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
