import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';

import 'package:cloudbelly_app/widgets/appwide_button.dart';

import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/common_button_login.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // var _formKey;
  // TextEditingController _emailController = TextEditingController();
  // TextEditingController _phoneController = TextEditingController();

  String user_email = '';
  String user_pass = '';
  String selectedOption = 'Customer';
  String user_mobile_number = '';
  bool _isSelected = false;
  // ignore: unused_field
  bool _isLogin = false;

  Future<void> _submitForm() async {
    // Perform signup logic
    String email = user_email;
    String pass = user_pass;

    // Add your signup logic here
    // For example, print the values:
    // Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    String msg = await login(email, pass);

    if (msg == 'Login successful') {
      TOastNotification().showSuccesToast(context, msg);
      Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    } else {
      if (msg == '-1') msg = "Error!";
      TOastNotification().showErrorToast(context, msg);
    }
  }

  Future<void> _submitFormSignUp() async {
    // Perform signup logic

    // Add your signup logic here

    // For example, print the values:
    String msg =
        await signUp(user_email, user_pass, user_mobile_number, selectedOption);
    if (msg == 'Registration successful') {
      TOastNotification().showSuccesToast(context, msg);

      Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    } else
      TOastNotification().showErrorToast(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    AppwideBanner(),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 420, // Set the maximum width to 800
                        ),
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 3.h),
                            margin: !_isLogin
                                ? EdgeInsets.only(top: 8.h, bottom: 5.h)
                                : EdgeInsets.only(top: 17.h, bottom: 5.h),
                            width: 90.w,
                            decoration: ShapeDecoration(
                              shadows: const [
                                BoxShadow(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                          user_email = p0.toString();
                                          print(p0);
                                        },
                                      ),
                                      Space(3.h),
                                      AppwideTextField(
                                        hintText: 'Enter your Phone Number',
                                        onChanged: (p0) {
                                          user_mobile_number = p0.toString();
                                          print(p0);
                                        },
                                      ),
                                      Space(3.h),
                                      AppwideTextField(
                                        hintText: 'Create a Password',
                                        onChanged: (p0) {
                                          user_pass = p0.toString();
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
                                            borderRadius:
                                                SmoothBorderRadius.all(
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
                                                selectedOption =
                                                    value.toString();
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
                                                      fontFamily:
                                                          'Product Sans',
                                                      fontWeight:
                                                          FontWeight.w400),
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
                                          return _submitFormSignUp();
                                          // print('sign up');
                                          // Navigator.of(context)
                                          //     .pushReplacementNamed(Tabs.routeName);
                                        },
                                      ),
                                      Space(4.h),
                                      Container(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Container(
                                              height: 1,
                                              width: 20.w,
                                              decoration: const BoxDecoration(
                                                  color: Colors.black),
                                            ),
                                            const Text('Or',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Color(0xFF0A4C61),
                                                    fontFamily: 'Product Sans',
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            Container(
                                              height: 1,
                                              width: 20.w,
                                              decoration: const BoxDecoration(
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                      ),
                                      Space(2.h),
                                      CommonButton('Continue with Whatsapp'),
                                      Space(1.5.h),
                                      CommonButton('Continue with Google'),
                                      Space(1.5.h),
                                      CommonButton('Continue with Facebook'),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                          user_email = p0;
                                          print(p0);
                                        },
                                      ),
                                      Space(3.h),
                                      AppwideTextField(
                                        hintText: 'Enter Password',
                                        onChanged: (p0) {
                                          user_pass = p0;
                                          print(p0);
                                        },
                                      ),
                                      Space(4.h),
                                      AppWideButton(
                                        num: -1,
                                        txt: 'Login',
                                        onTap: () {
                                          _submitForm();
                                          print('Login');
                                        },
                                      ),
                                      Space(4.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            height: 1,
                                            width: 20.w,
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
                                            width: 20.w,
                                            decoration: const BoxDecoration(
                                                color: Colors.black),
                                          )
                                        ],
                                      ),
                                      Space(2.h),
                                      CommonButton('Continue with Whatsapp'),
                                      Space(1.5.h),
                                      CommonButton('Continue with Google'),
                                      Space(1.5.h),
                                      CommonButton('Continue with Facebook'),
                                    ],
                                  )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
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
