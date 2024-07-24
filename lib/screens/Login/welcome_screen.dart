import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/screens/Login/commonLoginScreen.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(CommonLoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Image.asset(Assets.appIcon)),
            SizedBox(height: 20),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: 3),
              builder: (context, double value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Image.asset('assets/images/cloudbelly_logo.png',
                  width: 200, height: 200),
            ),
            
            
          ],
        ),
      ),
    );
  }
}