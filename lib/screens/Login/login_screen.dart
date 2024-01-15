import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';

import 'package:cloudbelly_app/widgets/appwide_button.dart';

import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/common_button_login.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String user_email = '';
  String selectedOption = 'Customer';
  String user_mobile_number = '';
  bool _isSelected = false;
  // ignore: unused_field
  bool _isLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  AppwideBanner(),
                  Center(
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 3.h),
                        margin: !_isLogin
                            ? EdgeInsets.only(top: 8.h, bottom: 5.h)
                            : EdgeInsets.only(top: 25.h, bottom: 5.h),
                        width: 90.w,
                        decoration: ShapeDecoration(
                          shadows: [
                            const BoxShadow(
                              offset: Offset(0, 4),
                              color: Color.fromRGBO(137, 136, 135, 0.418),
                              blurRadius: 20,
                            )
                          ],
                          color: Colors.white,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 35,
                              cornerSmoothing: 1,
                            ),
                          ),
                        ),
                        child: !_isLogin
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TouchableOpacity(
                                        onTap: () {
                                          setState(() {
                                            _isLogin = true;
                                          });
                                          print('login');
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  250, 110, 0, 0.7),
                                              fontSize: 18,
                                              fontFamily: 'Jost',
                                              fontWeight: FontWeight.w600,
                                              height: 0.03,
                                              letterSpacing: 0.78,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Space(4.h),
                                  const Center(
                                    child: Text(
                                      'Get Started',
                                      style: TextStyle(
                                        color: Color(0xFF094B60),
                                        fontSize: 26,
                                        fontFamily: 'Jost',
                                        fontWeight: FontWeight.w600,
                                        height: 0.03,
                                        letterSpacing: 0.78,
                                      ),
                                    ),
                                  ),
                                  Space(4.h),
                                  AppwideTextField(
                                    hintText: 'Enter your Email',
                                    onChanged: (p0) {
                                      print(p0);
                                    },
                                  ),
                                  Space(3.h),
                                  AppwideTextField(
                                    hintText: 'Enter your Phone Number',
                                    onChanged: (p0) {
                                      print(p0);
                                    },
                                  ),
                                  Space(3.h),
                                  AppwideTextField(
                                    hintText: 'Create a Password',
                                    onChanged: (p0) {
                                      print(p0);
                                    },
                                  ),
                                  Space(3.h),
                                  Container(
                                    // rgba(165, 200, 199, 1),
                                    decoration: const ShapeDecoration(
                                      shadows: [
                                        BoxShadow(
                                          offset: Offset(0, 4),
                                          color: Color.fromRGBO(
                                              165, 200, 199, 0.6),
                                          blurRadius: 20,
                                        )
                                      ],
                                      color: Colors.white,
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius.all(
                                            SmoothRadius(
                                                cornerRadius: 10,
                                                cornerSmoothing: 1)),
                                      ),
                                    ),
                                    height: 6.h,
                                    child: Center(
                                      child: DropdownButton<String>(
                                        hint: Text(
                                          !_isSelected
                                              ? 'Who are You '
                                              : selectedOption,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF0A4C61),
                                              fontFamily: 'Product Sans',
                                              fontWeight: FontWeight.w400),
                                        ),
                                        //value: selectedOption,

                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value.toString();
                                            _isSelected = true;
                                          });
                                        },
                                        underline:
                                            Container(), // This line removes the bottom line
                                        items: <String>[
                                          'Customer',
                                          'Vendor',
                                          'Supplier',
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF0A4C61),
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Space(3.h),
                                  AppWideButton(
                                    num: -1,
                                    txt: 'Sign up',
                                    onTap: () {
                                      print('sign up');
                                      Navigator.of(context)
                                          .pushReplacementNamed(Tabs.routeName);
                                    },
                                  ),
                                  Space(4.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        height: 1,
                                        width: 30.w,
                                        decoration: const BoxDecoration(
                                            color: Colors.black),
                                      ),
                                      const Text('Or',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Color(0xFF0A4C61),
                                              fontFamily: 'Product Sans',
                                              fontWeight: FontWeight.w400)),
                                      Container(
                                        height: 1,
                                        width: 30.w,
                                        decoration: const BoxDecoration(
                                            color: Colors.black),
                                      )
                                    ],
                                  ),
                                  Space(2.h),
                                  CommonButton('Continue with Whatsapp'),
                                  Space(1.5.h),
                                  CommonButton('Continue with Google'),
                                  // FutureBuilder(
                                  //   future: Authentication.initializeFirebase(
                                  //       context: context),
                                  //   builder: (context, snapshot) {
                                  //     if (snapshot.hasError) {
                                  //       return Text('Error initializing Firebase');
                                  //     } else if (snapshot.connectionState ==
                                  //         ConnectionState.done) {
                                  //       return GestureDetector(
                                  //           child: CommonButton('Continue with Google'),
                                  //           onTap: () async {
                                  //             setState(() {
                                  //               _isSigningIn = true;
                                  //             });

                                  //             User? user =
                                  //                 await Authentication.signInWithGoogle(
                                  //                     context: context);

                                  //             setState(() {
                                  //               _isSigningIn = false;
                                  //             });

                                  //             if (user != null) {
                                  //               // Navigator.of(context).pushNamed(
                                  //               //     SetupBusinessIdentityScreen.routeName);
                                  //             }
                                  //           });
                                  //     }
                                  //     return CircularProgressIndicator();
                                  //   },
                                  // ),
                                  Space(1.5.h),
                                  CommonButton('Continue with Facebook'),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TouchableOpacity(
                                        onTap: () {
                                          setState(() {
                                            _isLogin = false;
                                          });
                                          print('sign');
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'Sign up',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  250, 110, 0, 0.7),
                                              fontSize: 18,
                                              fontFamily: 'Jost',
                                              fontWeight: FontWeight.w600,
                                              height: 0.03,
                                              letterSpacing: 0.78,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Space(4.h),
                                  const Center(
                                    child: Text(
                                      'Welocome back',
                                      style: TextStyle(
                                        color: Color(0xFF094B60),
                                        fontSize: 26,
                                        fontFamily: 'Jost',
                                        fontWeight: FontWeight.w600,
                                        height: 0.03,
                                        letterSpacing: 0.78,
                                      ),
                                    ),
                                  ),
                                  Space(4.h),
                                  AppwideTextField(
                                    hintText: 'Enter your Email',
                                    onChanged: (p0) {
                                      print(p0);
                                    },
                                  ),
                                  Space(3.h),
                                  AppwideTextField(
                                    hintText: 'Enter Password',
                                    onChanged: (p0) {
                                      print(p0);
                                    },
                                  ),
                                  Space(4.h),
                                  AppWideButton(
                                    num: -1,
                                    txt: 'Login',
                                    onTap: () {
                                      print('Login');
                                      Navigator.of(context)
                                          .pushReplacementNamed(Tabs.routeName);
                                    },
                                  ),
                                ],
                              )),
                  ),
                ],
              ),
            ],
          ),
        ));
//         curl  -X POST \
//   'https://app.cloudbelly.in/update-user' \
//   --header 'Accept: */*' \
//   --header 'User-Agent: Thunder Client (https://www.thunderclient.com)' \
//   --header 'Content-Type: application/json' \
//   --data-raw '{
//   "phone":"6206630515",
//   "user_id":"65a428ce8c90b8cc72944b9e"
// }'
  }
}

// ignore: must_be_immutable
class TextFieldLabel extends StatelessWidget {
  TextFieldLabel({
    super.key,
    required this.label,
  });
  String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 3.w,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
