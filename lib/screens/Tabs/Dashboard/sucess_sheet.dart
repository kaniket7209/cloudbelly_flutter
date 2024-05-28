import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SuccessSheetBottomSheet {
  Future<dynamic> successSheet(BuildContext context) {
    return showModalBottomSheet(
      // useSafeArea: true,

      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        // print(data);
        return PopScope(
          canPop: true,
          onPopInvoked: (_) {
            context.read<TransitionEffect>().setBlurSigma(0);
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1),
                          topRight: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1)),
                    ),
                  ),
                  //height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      top: 2.h,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TouchableOpacity(
                          onTap: () {
                            return Navigator.of(context).pop();
                          },
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h, horizontal: 3.w),
                              width: 55,
                              height: 5,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFA6E00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                        const SuccessView(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SuccessView extends StatefulWidget {
  const SuccessView({super.key});

  @override
  State<SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<SuccessView> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Space(25),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 36),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Congratulations,',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 20,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.14,
                  ),
                ),
                TextSpan(
                  text: ' \nGeeta Kitchen',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 40,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Space(5),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            "We thank you for being a part of a community. Now sit back & relax, you will get the lowest price Guarenteed!",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 12,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              height: 15 / 12.0,
              // Calculate the line height based on font size
              letterSpacing: 0.03,
            ),
          ),
        ),
        Space(26),
        
      ],
    );
  }
}
