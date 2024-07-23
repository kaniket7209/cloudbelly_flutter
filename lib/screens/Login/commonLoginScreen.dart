import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:responsive_sizer/responsive_sizer.dart';

class CommonLoginScreen extends StatefulWidget {
  static const routeName = '/common-login-screen';

  const CommonLoginScreen({Key? key}) : super(key: key);

  @override
  _CommonLoginScreenState createState() => _CommonLoginScreenState();
}

class _CommonLoginScreenState extends State<CommonLoginScreen> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen background image with blur effect
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/feedSection.png', // Adjust image asset path
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Color(0xff0A4C61).withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
          // Centered popup
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: const ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      color: Color(0x7FB1D9D8),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                      topLeft: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                      topRight:
                          SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,30,30,0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 30),
                            constraints: BoxConstraints(maxWidth: 60.w),
                            child: Text(
                              'Welcome \nto Cloudbelly',
                              style: TextStyle(
                                  fontSize: 34,
                                  height: 1.1,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A4C61),
                                  fontFamily: 'Product Sans Black'),
                            ),
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 25,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 30),
                                constraints: BoxConstraints(maxWidth: 30.w),
                                child: Image.asset(
                                  'assets/images/logo_small.png', // Adjust image asset path
                                  fit: BoxFit.cover,
                                  width: 20.w,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                       
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 30),
                            child: Text(
                              'You can cook, eat or share your favourite food.',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0A4C61),
                                  fontFamily: 'Product Sans Medium'),
                            ),
                          ),
                        ],
                      ),
                     
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 60.w),
                            child: Lottie.asset(
                              'assets/Animation - welcome.json',
                              width: 250,
                              height: 250,
                            ),
                          ),
                          Spacer(),
                          Column(
                            children: [
                              SizedBox(height: 80,),
                              GestureDetector(
                                onTap: () {
                                  openEnterWhatsAppNumberBottomSheet(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 1.h),
                                    // margin: EdgeInsets.only(bottom: 2.h),
                                    decoration: ShapeDecoration(
                                      shadows: [
                                        BoxShadow(
                                          offset: const Offset(5, 6),
                                          color: Color(0xffFA6E00).withOpacity(0.45),
                                          blurRadius: 30,
                                        ),
                                      ],
                                      color: Color(0xffFA6E00),
                                      shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                        cornerRadius: 13,
                                        cornerSmoothing: 1,
                                      )),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.bold,
                                        // height: 0,
                                        letterSpacing: 0.14,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Future<void> openEnterWhatsAppNumberBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final TextEditingController _whatsAppController =
                TextEditingController();

            return Container(
              decoration: const ShapeDecoration(
                shadows: [
                  BoxShadow(
                    color: Color(0x7FB1D9D8),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                color: Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                    topRight:
                        SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                  ),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        width: 30,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFA6E00).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Enter your WhatsApp number',
                      style: TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _whatsAppController,
                      decoration: InputDecoration(
                        hintText: '9876789678',
                        filled: true,
                        fillColor: Color(0xFFEFEFEF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          String mobileNo = _whatsAppController.text;
                          final res =
                              await Provider.of<Auth>(context, listen: false)
                                  .sendOtp(mobileNo);
                          if (res == '200') {
                            Navigator.pop(context);
                            // openEnterOtpBottomSheet(context, mobileNo);
                          } else {
                            print("Error sending OTP");
                          }
                        },
                        child: Text('Send OTP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFA726),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
