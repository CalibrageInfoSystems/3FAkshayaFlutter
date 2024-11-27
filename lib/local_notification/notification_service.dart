import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void notificationAction(
      NotificationResponse notificationResponse) async {
    print('notification(${notificationResponse.payload}) action tapped: ');
  }

  static Future<void> initLocalNotifications() async {
    AndroidInitializationSettings androidInitialization =
        const AndroidInitializationSettings("@mipmap/ic_launcher");

    DarwinInitializationSettings iosInitialization =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationAction,
      onDidReceiveBackgroundNotificationResponse: notificationAction,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification(
      {required int id, required String title, required String body, String? payload}) async {
        print('showNotification called');
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'channel akshaya id',
      'channel akshaya name',
      channelDescription: 'channel akshaya description',
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails, iOS: const DarwinNotificationDetails());

    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);
  }
}