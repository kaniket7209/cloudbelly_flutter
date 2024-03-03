import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  // const WelcomeScreen({super.key});
  static const routeName = '/welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 5), () {
      _getUserData();
    });
    super.initState();
  }

  bool _isAvailable = false;

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
        TOastNotification().showSuccesToast(context, msg);
        Navigator.of(context).pushReplacementNamed(Tabs.routeName);
      } else {
        if (msg == '-1') msg = "Error!";
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
      Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
    print(_isAvailable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or app name here
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: 3),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/cloudbelly_logo.png',
                width: 200,
                height: 200,
                // adjust width and height according to your logo
              ),
            ),
            SizedBox(height: 30),
            // Animated text to make it more dynamic
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: 3),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Text(
                'Welcome to Cloudbelly',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Space(10.h),

            // Text('khkhk'),

            Center(
                child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Loading.....".toUpperCase(),
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )

                // GestureDetector(
                //     onTap: () async {
                //       final prefs = await SharedPreferences.getInstance();
                //       final extractedUserData =
                //           json.decode(prefs.getString('userData')!)
                //               as Map<String, dynamic>;
                //       AppWideLoadingBanner().loadingBanner(context);

                //       String msg =
                //           await Provider.of<Auth>(context, listen: false)
                //               .login(extractedUserData['email'],
                //                   extractedUserData['password']);
                //       Navigator.of(context).pop();
                //       if (msg == 'Login successful') {
                //         TOastNotification().showSuccesToast(context, msg);
                //         Navigator.of(context)
                //             .pushReplacementNamed(Tabs.routeName);
                //       } else {
                //         if (msg == '-1') msg = "Error!";
                //         TOastNotification().showErrorToast(context, msg);
                //         Navigator.of(context)
                //             .pushNamed(LoginScreen.routeName);
                //       }
                //       // Navigator.of(context)
                //       //     .pushNamed(LoginScreen.routeName);
                //       // Navigator.of(context)
                //       //     .pushReplacementNamed(Tabs.routeName);
                //     },
                //     child: Padding(
                //       padding: EdgeInsets.all(20),
                //       child: Text(
                //         "User deatils found | click to login".toUpperCase(),
                //         style: GoogleFonts.nunito(
                //           fontSize: 15,
                //           color: Colors.black,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //     ),
                //   )
                ),
          ],
        ),
      ),
    );
  }
}
