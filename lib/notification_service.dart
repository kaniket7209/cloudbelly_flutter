import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// var androidSetting = const AndroidInitializationSettings('launch_background');
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  // var initializationSettings = InitializationSettings(
  //     android: androidSetting,
      
  // );
  // await flutterLocalNotificationsPlugin.initialize(
  //   initializationSettings,
  // );
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
  // Choose the appropriate notification details based on the payload
  final bool isOrderNotification = message.data['type'] == 'incoming_order';
  print("isOrderNotification  $isOrderNotification");
  const AndroidNotificationDetails androidPlatformChannelSpecificsCatSound =  AndroidNotificationDetails(
    'high_importance_channel_order', // id
    'High Importance Notifications', // title
    channelDescription: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('cat_sound'), // Custom sound
    playSound: true,
  );

  const AndroidNotificationDetails androidPlatformChannelSpecificsDefaultSound = AndroidNotificationDetails(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    channelDescription: 'This channel is used for default notifications.', // description
    importance: Importance.high,
    priority: Priority.high,
    playSound: true, // Default sound
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: isOrderNotification ? androidPlatformChannelSpecificsCatSound : androidPlatformChannelSpecificsDefaultSound,
  );

  print('Showing notification with custom sound...  ${message.data['type']}');

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: message.data['type'], // Add payload data if needed
  );
  print('Notification shown.');
}
