import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/Utils/Authentication.dart';
import 'package:cloudbelly_app/screens/Login/otp_screen.dart';
import 'package:cloudbelly_app/widgets/common_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String selectedOption = 'Select';
  String user_mobile_number = '';
  // ignore: unused_field
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AppwideBanner(),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get Started',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    TextFieldLabel(label: 'Email'),
                    const SizedBox(
                      height: 5,
                    ),
                    Card(
                      elevation: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // Set the background color of the TextField
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 6.h,
                        child: TextField(
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.only(left: 14),
                            hintText: 'Enter your Email-id here',
                            hintStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              user_email = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    TextFieldLabel(label: 'Mobile Number'),
                    SizedBox(
                      height: 1.h,
                    ),
                    Card(
                      elevation: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 6.h,
                        child: TextField(
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.only(left: 14),
                            hintText: 'Enter your mobile number here',
                            hintStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              user_mobile_number = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    TextFieldLabel(label: 'Tell us more about you'),
                    SizedBox(
                      height: 1.h,
                    ),
                    Card(
                      elevation: 20,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          // border: Border.all(
                          //   width: 0,
                          // ),
                        ),
                        child: Center(
                          child: DropdownButton<String>(
                            value: selectedOption,
                            onChanged: (newValue) {
                              setState(() {
                                selectedOption = newValue!;
                              });
                            },
                            underline:
                                Container(), // This line removes the bottom line
                            items: <String>[
                              'Select',
                              'Foodie',
                              'Restaurant',
                              'Home kitchen',
                              'Food Blogger',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (user_email != '' &&
                            user_mobile_number != '' &&
                            user_mobile_number.length == 10 &&
                            user_email.contains("@gmail.com") &&
                            selectedOption != 'Select') {
                          Navigator.pushNamed(context, OtpScreen.routeName,
                              arguments: {
                                'number': user_mobile_number,
                              });
                        }
                      },
                      child: Center(
                        child: Container(
                          height: 5.7.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color.fromRGBO(255, 165, 0, 1),
                                  const Color.fromRGBO(255, 208, 123, 1)
                                ]),
                            color: const Color.fromRGBO(255, 165, 0, 1),
                          ),
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 1,
                          width: 150,
                          decoration: BoxDecoration(color: Colors.black),
                        ),
                        Text(
                          'Or',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        Container(
                          height: 1,
                          width: 150,
                          decoration: BoxDecoration(color: Colors.black),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    CommonButton('Continue with Whatsapp'),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    FutureBuilder(
                      future:
                          Authentication.initializeFirebase(context: context),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error initializing Firebase');
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return GestureDetector(
                              child: CommonButton('Continue with Google'),
                              onTap: () async {
                                setState(() {
                                  _isSigningIn = true;
                                });

                                User? user =
                                    await Authentication.signInWithGoogle(
                                        context: context);

                                setState(() {
                                  _isSigningIn = false;
                                });

                                if (user != null) {
                                  // Navigator.of(context).pushNamed(
                                  //     SetupBusinessIdentityScreen.routeName);
                                }
                              });
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    CommonButton('Continue with Facebook'),
                  ],
                ),
              ),
            ],
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
