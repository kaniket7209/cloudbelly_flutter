import 'dart:io';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Login/map.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/graphs.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';

import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Login/welcome_screen.dart';
import 'package:cloudbelly_app/services/uni_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/Tabs/Profile/profile_view.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  showNotification(message);
  print("Handling a background message: ${message.notification!.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await UnilinksServices.init();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          "AIzaSyB3UySbCaiXjC_bh2h9JAjTKvbeUVA1OmQ", // paste your api key here
      appId:
          "1:508708683425:android:fcfeda59f64fd186e9bae0", //paste your app id here
      messagingSenderId: "508708683425", //paste your messagingSenderId here
      projectId: "cloudbelly-d97a9", //paste your project id here
    ),
  );
  requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterLocalNotificationsPlugin().initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings(
          '@mipmap/ic_launcher'), // Make sure you have the proper icons
    ),
    onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse){
         print("notificationResponse:: ${notificationResponse?.payload}");
    }
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message);
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.notification}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await UserPreferences.init();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  await prefs.setString('fcmToken', fcmToken ?? "");
  Auth().getToken(fcmToken);
  Auth().getUserData();

  //print('fcmToken: $fcmToken');
  //await Firebase.initializeApp(

  //     // options: DefaultFirebaseOptions.currentPlatform,
  //   );
  initDynamicLinks();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Auth()),
  ], child: const MyApp()));
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}
Future showNotification(RemoteMessage message) async {

  var androidChannel = const AndroidNotificationDetails(
    'CHANNEL_ID',
    'CHANNEL_NAME',
    channelDescription: 'CHANNEL_DESCRIPTION',
    importance: Importance.high,
    priority: Priority.high,
  );
  var platformChannel = NotificationDetails(android: androidChannel);
  FlutterLocalNotificationsPlugin().show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformChannel,
    payload: 'New Payload',
  );
}
void initDynamicLinks() async {
  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    _handleDeepLink(dynamicLinkData.link);
  }).onError((error) {
    // Handle errors
    print('Dynamic Link Failed: $error');
  });

  // Get the initial dynamic link if the app is opened with a dynamic link
  final data = await FirebaseDynamicLinks.instance.getInitialLink();
  if (data?.link != null) {
    _handleDeepLink(data!.link);
  }
}

void _handleDeepLink(Uri deepLink) {
  final String? userId = deepLink.queryParameters['profileId'];
  if (userId != null) {
    print(" profileId found in the deep link");
    // Use the navigator key to push the ProfileView
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => ProfileView(userIdList: [userId]),
    ));
  } else {
    print("No profileId found in the deep link");
  }
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ViewCartProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => TransitionEffect(),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'CloudBelly',
            theme: ThemeData(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all<Color>(Color(0xFFFA6E00)),
                trackColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(177, 217, 216, 1)),
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
              useMaterial3: true,
            ),
            initialRoute: WelcomeScreen.routeName,
            routes: {
              LoginScreen.routeName: (context) => LoginScreen(),
              '/map': (context) => MapScreen(),
              WelcomeScreen.routeName: (context) => WelcomeScreen(),
              Tabs.routeName: (context) => Tabs(),
              PostsScreen.routeName: (context) => PostsScreen(),
              GraphsScreen.routeName: (context) => GraphsScreen(),
              ViewCart.routeName: (context) => ViewCart(),
            },
          ),
        ),
      );
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
/*final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  _firebaseMessaging.getToken().then((token) {
    print('Firebase Token: $token');
  });
  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message in foreground: ${message.notification!.title}');
  });

  // Handle notifications when the app is terminated or in the background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Received message in background: ${message.notification!.title}');
  });*/
