import 'dart:io';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Login/map.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/graphs.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';

import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Login/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  _firebaseMessaging.getToken().then((token) {
    print('Firebase Token: $token');
  });
  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: AndroidInitializationSettings('assets/images/logo.png'),
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
  });
  //await Firebase.initializeApp(

  //     // options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // initDynamicLinks();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Auth()),
  ], child: const MyApp()));
}

// void initDynamicLinks() async {
//   FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
//     _handleDeepLink(dynamicLinkData.link);
//   }).onError((error) {
//     // Handle errors
//     print('Dynamic Link Failed: $error');
//   });

//   final data = await FirebaseDynamicLinks.instance.getInitialLink();
//   final Uri deepLink = data!.link;
//   _handleDeepLink(deepLink);
// }

// void _handleDeepLink(Uri deepLink) {
//   if (deepLink != null) {
//     // if (deepLink.pathSegments.contains('userProfile')) {
//     final String? userId = deepLink.queryParameters['id'];
//     if (userId != null) {
//       // Use navigatorKey to navigate without context
//       navigatorKey.currentState!.push(MaterialPageRoute(
//         builder: (context) {
//           return Profile();
//         },
//       ));
//     }
//     // }
//   }
// }

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
