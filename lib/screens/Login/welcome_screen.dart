import 'dart:convert';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isAvailable = false;

  @override
  void initState()  {
    super.initState();
    Future.delayed(const Duration(microseconds: 1000), () {
      UserPreferences().isLogin == true
          ? Navigator.of(context).pushReplacementNamed(Tabs.routeName)
          : Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      //_getUserData();
    });
  }

  Future<void> moveToNextPage() async {
    UserPreferences().isLogin == true
        ? Navigator.of(context).pushReplacementNamed(Tabs.routeName)
        : Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final temp = await Provider.of<Auth>(context, listen: false).tryAutoLogin();
    setState(() {
      _isAvailable = temp;
    });

    if (_isAvailable) {
      final extractedUserData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      AppWideLoadingBanner().loadingBanner(context);
      String msg = await Provider.of<Auth>(context, listen: false)
          .login(extractedUserData['email'], extractedUserData['password']);
      Navigator.of(context).pop();
      if (msg == 'Login successful') {
        await prefs.remove('feedData');
        await prefs.remove('menuData');
        TOastNotification().showSuccesToast(context, msg);
        Navigator.of(context).pushReplacementNamed(Tabs.routeName);
      } else {
        msg = msg == '-1' ? "Error!" : msg;
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
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
            /*Space(10.h),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: 3),
              builder: (context, double value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Image.asset('assets/images/cloudbelly_logo.png',
                  width: 200, height: 200),
            ),

            Lottie.asset('assets/Animation - 1710085539831.json',
                width: 500, height: 500), // Lottie animation
            Padding(
              padding: EdgeInsets.all(20),
              child: Text("Loading.....".toUpperCase(),
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
            ),*/
          ],
        ),
      ),
    );
  }
}
