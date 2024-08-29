import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('cloudbelly_logo'); // Your small icon here

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  print('Creating notification channel...');
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  print('Notification channel created.');
}

Future<void> showNotification(RemoteMessage message) async {
  // Notification settings for order-related notifications with custom sound
  const AndroidNotificationDetails androidPlatformChannelSpecificsCatSound =
      AndroidNotificationDetails(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    channelDescription:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('cat_sound'), // Custom sound
    icon: 'cloudbelly_logo', // Your small icon on the left side
    enableVibration: true,
  );

  // Notification settings for all other notifications with the default sound
  const AndroidNotificationDetails androidPlatformChannelSpecificsDefaultSound =
      AndroidNotificationDetails(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    channelDescription:
        'This channel is used for important notifications.',
         // description
    importance: Importance.high,
    priority: Priority.high,
    playSound: true, // Default notification sound
    icon: 'cloudbelly_logo', // Your small icon on the left side
    enableVibration: true,
    color: Color(0xffEBF9FD)
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: message.data['type'] == 'incoming_order'
        ? androidPlatformChannelSpecificsCatSound
        : androidPlatformChannelSpecificsDefaultSound,
  );

  print('Showing notification...');

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: message.data['type'], // Add payload data if needed
  );
  print('Notification shown.');
}