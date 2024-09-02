import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/main.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

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
                  padding: const EdgeInsets.fromLTRB(0, 23, 10, 0),
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
                                  fontSize: 32,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0A4C61),
                                  fontFamily: 'Product Sans Black'),
                            ),
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // SizedBox(
                              //   height: 25,
                              // ),
                              Container(
                                
                                // padding: EdgeInsets.only(left: 30),
                                constraints: BoxConstraints(maxWidth: 30.w),
                                child: Image.asset(
                                  'assets/images/cb_circle_logo.png', // Adjust image asset path
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
                                  fontWeight: FontWeight.w600,
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
                          Padding(
                            padding:  EdgeInsets.only(right: 3.w),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 80,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // openEnterUserTypeBottomSheet(context,'6206630515');
                                    // openEnterOtpBottomSheet(context,'6206630515');
                                    openEnterWhatsAppNumberBottomSheet(context);
                                    // openThankYouScreen(context);
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
    final TextEditingController whatsAppController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    void _handleInputChange(String value) {
      if (value.length == 10) {
        focusNode.unfocus();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    Future<void> sendOtp() async {
      // Simulate sending OTP
      final res = await Provider.of<Auth>(context, listen: false)
          .sendOtp(whatsAppController.text);
      
      if (res == '200') {
        // OTP sent successfully, open the next page
        Navigator.pop(context); // Close the current dialog if any
        openEnterOtpBottomSheet(context, whatsAppController.text);
      } else {
        // Error occurred, print the error
       
        TOastNotification().showErrorToast(context,
            'Failed to send OTP. Please check the number ${whatsAppController.text}');
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return
             Container(
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
                padding: const EdgeInsets.fromLTRB(30.0, 16, 30, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Enter your \nWhatsApp number',
                      style: TextStyle(
                        color: Color(0xFF0A4C61),
                        fontSize: 32,
                        height: 1.1,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Product Sans Black',
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
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
                      child: TextField(
                        cursorColor: Color(0xFF0A4C61),
                        controller: whatsAppController,
                        focusNode: focusNode,
                        onChanged: (value) {
                          setState(() {
                            _handleInputChange(value);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '9876789678',
                          hintStyle: TextStyle(
                            color: Color(0xFF0A4C61).withOpacity(0.5),
                            letterSpacing: 2.5,
                          ),
                          filled: true,
                          fillColor: Color(0xFFD3EEEE),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                            letterSpacing: 5,
                            fontWeight: FontWeight.w400,
                            fontFamily:
                                'Product Sans Black' // Apply letter spacing to entered text
                            ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: GestureDetector(
                            onTap: sendOtp,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 1.2.h),
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    offset: const Offset(5, 6),
                                    color:
                                        Color(0xffFA6E00).withOpacity(0.45),
                                    blurRadius: 30,
                                  ),
                                ],
                                color: Color(0xffFA6E00),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 15,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Send OTP',
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
                      ],
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

Future<void> openEnterOtpBottomSheet(
    BuildContext context, String mobileNo) async {
  List<String> otp = List.filled(6, '');
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return _EnterOtpBottomSheet(
        mobileNo: mobileNo,
        otp: otp,
      );
    },
  );
}

class _EnterOtpBottomSheet extends StatefulWidget {
  final String mobileNo;
  final List<String> otp;

  _EnterOtpBottomSheet({required this.mobileNo, required this.otp});

  @override
  __EnterOtpBottomSheetState createState() => __EnterOtpBottomSheetState();
}

class __EnterOtpBottomSheetState extends State<_EnterOtpBottomSheet> {
  int _counter = 60; // Initialize the counter to 60 seconds
  Timer? _timer; // Declare the Timer

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
         
        });
      } else {
        _timer?.cancel();
        
      }
    });
   
  }

  Future<void> resendOtp() async {
    final res = await Provider.of<Auth>(context, listen: false)
        .sendOtp(widget.mobileNo);
    if (res == '200') {
      // OTP sent successfully
      Navigator.pop(context);
      await openEnterOtpBottomSheet(context, widget.mobileNo);
    } else {
      print("Failed to send OTP. Error code: $res");
    }
  }

  Future<void> _submitOtp() async {
  final prefs = await SharedPreferences.getInstance();

  final otpCode = widget.otp.join();

  final res = await Provider.of<Auth>(context, listen: false)
      .verifyOtp(widget.mobileNo, otpCode);

  if (!mounted) return; // Check if the widget is still mounted

  if (res['code'] == 200) {
    print('OTP verified successfully. Proceeding with login.');

    // Proceed with login
    final logRes = await Provider.of<Auth>(context, listen: false)
        .commonLogin(context, widget.mobileNo, '');
    print("logRes $logRes");

    if (!mounted) return; // Check if the widget is still mounted

    if (logRes['code'] == 200) {
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pop(context);
      TOastNotification().showSuccesToast(context, 'Login Successful');
      await prefs.remove('feedData');
      await prefs.remove('menuData');
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    } else if (logRes['code'] == 400) {
    
      await openEnterUserTypeBottomSheet(context, widget.mobileNo);
    } else {
      TOastNotification().showErrorToast(context, 'Unexpected error. Please try again');
    }
  } else {

    TOastNotification().showErrorToast(context, 'Wrong OTP');
  }
}
  @override
  Widget build(BuildContext context) {
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
          bottom: MediaQuery.of(context).viewInsets.bottom / 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Container(
              child: Text(
                'Enter OTP',
                style: TextStyle(
                  color: Color(0xFF0A4C61),
                  fontSize: 32,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
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
                          widget.otp[index] = value;

                          if (value.length == 1) {
                            if (index != 5) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).unfocus();
                            }
                          } else if (value.length == 0 && index != 0) {
                            widget.otp[index] = '';
                            FocusScope.of(context).previousFocus();
                          }
                          print("otp ent ${widget.otp}");
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
                    if (_counter > 0)
                      Text(
                        'Resend OTP in $_counter seconds',
                        style: TextStyle(
                          color: Color(0xFF0A4C61),
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                        ),
                      )
                    else
                      TextButton(
                        onPressed: resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Color(0xFFFB8020),
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
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
  }
}
Future<void> openEnterUserTypeBottomSheet(
    BuildContext context, String mobile_no) async {
  String? selectedUserType;

  final selectedType = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
              height: MediaQuery.of(context).size.height * 0.4,
              padding: EdgeInsets.only(
                left: 40,
                right: 40,
                top: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'Choose \nyour profile',
                      style: TextStyle(
                        fontSize: 32,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff0A4C61),
                        fontFamily: 'Product Sans Black',
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedUserType = 'Vendor';
                            });
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              Navigator.pop(context, 'Vendor');
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: Color(0xFFA5C8C7).withOpacity(0.4),
                                  blurRadius: 20,
                                ),
                              ],
                              color: Color(0xFFFFFFFF),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 15,
                                  cornerSmoothing: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: ShapeDecoration(
                                    shadows: const [
                                      BoxShadow(
                                        offset: Offset(0, 4),
                                        color: Color.fromRGBO(
                                            165, 200, 199, 0.6),
                                        blurRadius: 20,
                                      ),
                                    ],
                                    color: selectedUserType == 'Vendor'
                                        ? const Color(0xFFFA6E00)
                                        : const Color(0xFFA5C8C799),
                                    shape: const SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius.all(
                                        SmoothRadius(
                                            cornerRadius: 10,
                                            cornerSmoothing: 1),
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                                SizedBox(width: 10),
                                const Text(
                                  'Restaurant/bakery/cafe',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Product Sans',
                                      color: Color(0xff0A4C61),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedUserType = 'Customer';
                            });
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              Navigator.pop(context, 'Customer');
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: Color(0xFFA5C8C7).withOpacity(0.4),
                                  blurRadius: 20,
                                ),
                              ],
                              color: Color(0xFFFFFFFF),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 15,
                                  cornerSmoothing: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: ShapeDecoration(
                                    shadows: const [
                                      BoxShadow(
                                        offset: Offset(0, 4),
                                        color: Color.fromRGBO(
                                            165, 200, 199, 0.6),
                                        blurRadius: 20,
                                      ),
                                    ],
                                    color: selectedUserType == 'Customer'
                                        ? const Color(0xFFFA6E00)
                                        : const Color(0xFFA5C8C799),
                                    shape: const SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius.all(
                                        SmoothRadius(
                                            cornerRadius: 10,
                                            cornerSmoothing: 1),
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                                SizedBox(width: 10),
                                const Text(
                                  'Customer',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Product Sans',
                                      color: Color(0xff0A4C61),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // GestureDetector(
                        //   onTap: () {
                        //     setState(() {
                        //       selectedUserType = 'Supplier';
                        //     });
                        //     Future.delayed(const Duration(milliseconds: 300),
                        //         () {
                        //       Navigator.pop(context, 'Supplier');
                        //     });
                        //   },
                        //   child: Container(
                        //     padding: EdgeInsets.symmetric(
                        //         vertical: 10, horizontal: 10),
                        //     decoration: ShapeDecoration(
                        //       shadows: [
                        //         BoxShadow(
                        //           offset: const Offset(0, 4),
                        //           color: Color(0xFFA5C8C7).withOpacity(0.4),
                        //           blurRadius: 20,
                        //         ),
                        //       ],
                        //       color: Color(0xFFFFFFFF),
                        //       shape: SmoothRectangleBorder(
                        //         borderRadius: SmoothBorderRadius(
                        //           cornerRadius: 15,
                        //           cornerSmoothing: 1,
                        //         ),
                        //       ),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Container(
                        //           height: 30,
                        //           width: 30,
                        //           decoration: ShapeDecoration(
                        //             shadows: const [
                        //               BoxShadow(
                        //                 offset: Offset(0, 4),
                        //                 color: Color.fromRGBO(
                        //                     165, 200, 199, 0.6),
                        //                 blurRadius: 20,
                        //               ),
                        //             ],
                        //             color: selectedUserType == 'Supplier'
                        //                 ? const Color(0xFFFA6E00)
                        //                 : const Color(0xFFA5C8C799),
                        //             shape: const SmoothRectangleBorder(
                        //               borderRadius: SmoothBorderRadius.all(
                        //                 SmoothRadius(
                        //                     cornerRadius: 10,
                        //                     cornerSmoothing: 1),
                        //               ),
                        //             ),
                        //           ),
                        //           child: const Icon(
                        //             Icons.check,
                        //             color: Colors.white,
                        //             size: 15,
                        //           ),
                        //         ),
                        //         SizedBox(width: 10),
                        //         const Text(
                        //           'Supplier',
                        //           style: TextStyle(
                        //               fontSize: 16,
                        //               fontFamily: 'Product Sans',
                        //               color: Color(0xff0A4C61),
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 20),
                     
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });

    if (selectedType != null) {
      // Save the selected user type and update the server
      await saveUserType(context, selectedType, mobile_no);
    }
  }
Future<void> saveUserType(BuildContext context, String userType, String mobile_no) async {
  print("selected usertype $userType");

  // Save the Provider instance before using it in async functions
  final authProvider = Provider.of<Auth>(context, listen: false);

  // Call commonLogin again with the updated user type
  final logRes = await authProvider.commonLogin(context, mobile_no, userType);
  print("logresponse $logRes");
  if (logRes['code'] == 200) {
    TOastNotification().showSuccesToast(context, 'Login Successful');
    navigatorKey.currentState?.pushReplacementNamed(Tabs.routeName);
  } else if (logRes['code'] == 201) {
    navigatorKey.currentState?.pop();
    TOastNotification().showSuccesToast(context, 'Registration Successful');
    await openThankYouScreen(context);
  } else if (logRes['code'] == 400) {
    TOastNotification().showErrorToast(context, 'Otp not verified');
  } else {
    TOastNotification().showErrorToast(context, 'Unexpected error. Please try again');
  }
}

Future<void> openThankYouScreen(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                  topLeft: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                ),
              ),
            ),
            height: MediaQuery.of(context).size.height /2,
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 1,
            ),
            child:
             Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 100.w),
                child: Lottie.asset(
                  'assets/Animation - thanks.json',
                ),
              ),
            ),
          );
        },
      );
    },
  );

  // Delay for 2 seconds using Future.delayed
  Future.delayed(Duration(seconds: 2), () {
    navigatorKey.currentState?.pop();
    navigatorKey.currentState?.pushReplacementNamed(Tabs.routeName);
  });
}
