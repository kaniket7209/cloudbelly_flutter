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
    _getUserData();
    super.initState();
  }

  bool _isAvailable = false;

  Future<void> _getUserData() async {
    final temp = await Provider.of<Auth>(context, listen: false).tryAutoLogin();
    setState(() {
      _isAvailable = temp;
    });
    print(_isAvailable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Space(10.h),
            Text('Welcome Screen'),
            Space(20.h),
            // Text('khkhk'),
            Center(
                child: _isAvailable
                    ? GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final extractedUserData =
                              json.decode(prefs.getString('userData')!)
                                  as Map<String, dynamic>;
                          AppWideLoadingBanner().loadingBanner(context);

                          String msg =
                              await Provider.of<Auth>(context, listen: false)
                                  .login(extractedUserData['email'],
                                      extractedUserData['password']);
                          Navigator.of(context).pop();
                          if (msg == 'Login successful') {
                            TOastNotification().showSuccesToast(context, msg);
                            Navigator.of(context)
                                .pushReplacementNamed(Tabs.routeName);
                          } else {
                            if (msg == '-1') msg = "Error!";
                            TOastNotification().showErrorToast(context, msg);
                          }
                          // Navigator.of(context)
                          //     .pushReplacementNamed(Tabs.routeName);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "User deatils found | click to login".toUpperCase(),
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Login".toUpperCase(),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
          ],
        ),
      ),
    );
  }
}
