import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/common_button_login.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({super.key});

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  bool _isSelected = false;
  String selectedOption = '';
  List<String> userTypeList = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    userTypeList = ["I am hungry", "I cook & sell", "I supply raw materials"];
    setState(() {});
  }

  Future<void> _handleSignIn() async {
    if (selectedIndex == null) {
      TOastNotification().showErrorToast(context, "Please Select Options");
    } else {
      try {
        var userData = await GoogleSignIn().signIn();
        if (userData != null) {
          AppWideLoadingBanner().loadingBanner(context);
          String msg = await Provider.of<Auth>(context, listen: false)
              .googleLogin(userData.email, selectedIndex == 0 ? "Customer" : selectedIndex == 1 ? "Vendor" :"Supplier");
          Navigator.of(context).pop();
          if (msg == 'Login successful') {
            //TOastNotification().showSuccesToast(context, msg);
            UserPreferences().isLogin = true;
            Navigator.of(context).pushReplacementNamed(Tabs.routeName);
          } else {
            if (msg == '-1') msg = "Error!";
            TOastNotification().showErrorToast(context, msg);
          }
        }
      } on PlatformException catch (error) {
        print("error:: $error");
      } catch (e) {
        print("err:: $e");
      }
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Stack(
                fit: StackFit.loose,
                children: [
                  Image.asset(
                    Assets.googleLoginBgImage,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,

                  ),
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6), // Adjust opacity as needed
                      BlendMode.srcOver,
                    ),
                    child: Image.asset(
                      Assets.googleLoginBgImage,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0,left: 20.0,top: 30.0),
                    child: Container(
                      decoration: BoxDecoration(
                        //color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Space(4.h),
                                const Center(
                                  child: Text(
                                    'Tell us who you are?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.w800,
                                      height: 0.03,
                                      letterSpacing: 0.78,
                                    ),
                                  ),
                                ),
                                Space(3.h),
                                ListView.separated(
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          selectedIndex = index;
                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 34,
                                              top: 10,
                                              bottom: 10,
                                              right: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                userTypeList[index],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFF0A4C61),
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const Space(
                                                10,
                                                isHorizontal: true,
                                              ),
                                              Container(
                                                //height: 30,width: 30,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:selectedIndex == index ? const Color(0xFFFA6E00) : const Color(0xFFABABAB),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, _) {
                                      return const Space(21);
                                    },
                                    itemCount: userTypeList.length),
                                Space(2.h),
                                Space(3.h),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text:
                                            "By Clicking Log In with google, you agree to our ",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w400),
                                      ),
                                      TextSpan(
                                        text: "Terms.",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.white,
                                            color: Colors.white,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w400),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _launchURL(
                                                "https://app.cloudbelly.in/terms-and-conditions");
                                          },
                                      ),
                                      const TextSpan(
                                        text:
                                            " Learn how we process your data in our",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w400),
                                      ),
                                      TextSpan(
                                        text: "Privacy policy",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.white,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w400),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _launchURL(
                                                "https://app.cloudbelly.in/privacy-policy");
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                                Space(2.h),
                                InkWell(
                                  onTap: (){
                                    _handleSignIn();
                        
                                  },
                                  child: Center(
                                    child: Container(
                                      height: 5.h,
                                      width: double.infinity,
                                      decoration: const ShapeDecoration(
                                        shadows: [
                                          BoxShadow(
                                            offset: Offset(0, 4),
                                            color: Color.fromRGBO(165, 200, 199, 0.2),
                                            blurRadius: 20,
                                          )
                                        ],
                                        color: Colors.white,
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius.all(
                                              SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                                        ),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(Assets.googleIcon,height: 25,width: 25,),
                                            const Space(08,isHorizontal: true,),
                                            const Text(
                                              "Login with Google",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xFF0A4C61),
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Space(20)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
