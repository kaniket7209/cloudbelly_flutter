import 'package:cloudbelly_app/screens/Login/map.dart';
// import 'package:cloudbelly_app/screens/Login/signup.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/inventory_hub.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';

import 'package:cloudbelly_app/screens/Login/login_screen.dart';

import 'package:cloudbelly_app/screens/Login/welcome_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CloudBelly',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          // '/signup': (context) => SignUpPage(),
          '/map': (context) => MapScreen(),
          WelcomeScreen.routeName: (context) => WelcomeScreen(),
          Tabs.routeName: (context) => Tabs(),
          InventoryHub.routeName: (context) => InventoryHub(),
        },
      );
    });
  }
}
