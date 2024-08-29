import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  print('Creating notification channel...');
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  print('Notification channel created.');
}

Future<void> showNotification(RemoteMessage message) async {
  // Set the largeIcon to your drawable resource
  final largeIcon = const DrawableResourceAndroidBitmap('cloudbelly_logo');

  // Set the notification details
  final bool isOrderNotification = message.data['type'] == 'incoming_order';

  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    channelDescription: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    largeIcon: largeIcon,  // Set the large icon here
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  print('Showing notification with custom logo... ${message.data['type']}');

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: message.data['type'], // Add payload data if needed
  );
  print('Notification shown.');
}