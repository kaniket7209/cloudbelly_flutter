import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  // const WelcomeScreen({super.key});
  static const routeName = '/welcome-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 165, 0, 1),
      body: Center(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, User x34 to your new future, your own online store!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
      )),
    );
  }
}
