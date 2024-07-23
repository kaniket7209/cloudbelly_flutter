import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
                // height: MediaQuery.of(context).size.height * 0.4,
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
                      topLeft:
                          SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                      topRight:
                          SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 23, 30, 0),
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
                              width: 230,
                              height: 230,
                            ),
                          ),
                          Spacer(),
                          Column(
                            children: [
                              SizedBox(
                                height: 80,
                              ),
                              GestureDetector(
                                onTap: () {
                                  openEnterOtpBottomSheet(context,'6206630515');
                                  // openEnterWhatsAppNumberBottomSheet(context);
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 1.h),
                                    // margin: EdgeInsets.only(bottom: 2.h),
                                    decoration: ShapeDecoration(
                                      shadows: [
                                        BoxShadow(
                                          offset: const Offset(5, 6),
                                          color: Color(0xffFA6E00)
                                              .withOpacity(0.45),
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
            final TextEditingController whatsAppController =
                TextEditingController();

            Future<void> sendOtp() async {
              // Simulate sending OTP
              final res = await Provider.of<Auth>(context, listen: false)
                  .sendOtp(whatsAppController.text);
              print("resOTP $res");
              if (res == '200') {
                // OTP sent successfully, open the next page
                Navigator.pop(context); // Close the current dialog if any
                openEnterOtpBottomSheet(context, whatsAppController.text);
              } else {
                // Error occurred, print the error
                print("Failed to send OTP. Error code: $res");
                TOastNotification().showErrorToast(context,
                    'Failed to send OTP. Please check the no. ${whatsAppController.text}');
              }
            }

            return Padding(
             padding: EdgeInsets.only(
                  
                  bottom: MediaQuery.of(context).viewInsets.bottom/3,
                ),
              child: Container(
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
                      topLeft:
                          SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                      topRight:
                          SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                    ),
                  ),
                ),
                height: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).size.height * 0.6
                    : MediaQuery.of(context).size.height * 0.4,
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
                        'Enter your \nWhatsApp number',
                        style: TextStyle(
                          color: Color(0xFF0A4C61),
                          fontSize: 32,
                          height: 1.1,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Product Sans Black',
                        ),
                      ),
                      SizedBox(height: 26),
                      TextField(
                        cursorColor: Color(0xFF0A4C61),
                        controller: whatsAppController,
                        decoration: InputDecoration(
                          hintText: '9876789678',
                          filled: true,
                          
                          fillColor: Color(0xFFD3EEEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: sendOtp,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 1.h),
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
                                ),
                              ),
                            ),
                            child: const Text(
                              'Send OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

Future<void> openEnterOtpBottomSheet(BuildContext context, String mobileNo) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          List<String> otp = List.filled(6, '');

          Future<void> resendOtp() async {
            final res = await Provider.of<Auth>(context, listen: false).sendOtp(mobileNo);
            if (res == '200') {
              // OTP sent successfully
              Navigator.pop(context);
              openEnterOtpBottomSheet(context, mobileNo);
            } else {
              print("Failed to send OTP. Error code: $res");
            }
          }

          Future<void> _submitOtp() async {
            final otpCode = otp.join();
            print('Entered OTP: $otpCode');
            final res = await Provider.of<Auth>(context, listen: false).verifyOtp(mobileNo, otpCode);

            if (res['code'] == 200) {
              print('OTP verified successfully. Proceeding with login.');
              TOastNotification().showSuccesToast(context, 'OTP verified');
              // Proceed with login
            } else {
              print("Failed to verify OTP. Error code: ${res['msg']}");
              TOastNotification().showErrorToast(context, '${res['msg']}');
            }
          }

          return SingleChildScrollView(
            child: Container(
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
                    topRight: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                  ),
                ),
              ),
              padding: EdgeInsets.only(
                left: 40,
                right: 5,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      width: 30,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA6E00).withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    child: Text(
                      'Enter OTP',
                      style: TextStyle(
                        color: Color(0xFF0A4C61),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans Black',
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                color: Color(0xffDBF5F5),
                                blurRadius: 20,
                                offset: Offset(0, 12),
                                spreadRadius: 0,
                              ),
                            ],
                            color: const Color(0xffD3EEEE),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 13,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: TextField(
                              cursorColor: Color(0xff0A4C61),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  otp[index] = value;
                                  print('OTP List after input $index: $otp');
                                });
                                if (value.length == 1) {
                                  if (index != 5) {
                                    FocusScope.of(context).nextFocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                } else if (value.length == 0 && index != 0) {
                                  otp[index] = '';
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.only(right: 40),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: resendOtp,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                color: Color(0xFFFB8020),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                              ),
                            ),
                          ),
                          Text(
                            'OTP in',
                            style: TextStyle(
                              color: Color(0xFF0A4C61),
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                            ),
                          ),
                          Text(
                            ' 60 seconds',
                            style: TextStyle(
                              color: Color(0xFF0A4C61),
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 40),
                        child: Center(
                          child: GestureDetector(
                            onTap: _submitOtp,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7.w, vertical: 1.h),
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    offset: const Offset(5, 6),
                                    color: Color(0xffFA6E00).withOpacity(0.45),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                  ),
                                ],
                                color: Color(0xffFA6E00),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 17,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
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
