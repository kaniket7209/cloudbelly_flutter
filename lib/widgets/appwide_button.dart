// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppWideButton extends StatelessWidget {
  int num;
  String txt;
  bool ispop;
  double width;
  final Function? onTap;
  AppWideButton({
    super.key,
    required this.num,
    this.onTap,
    required this.txt,
    this.ispop = false,
    this.width = 1.1,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Center(
        child: Container(
          height: 6.h,
          width: width == 1.1 ? 100.w : width,
          // width: ,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: const ShapeDecoration(
            shadows: [
              BoxShadow(
                offset: Offset(0, 4),
                color: Color.fromRGBO(0, 0, 0, 0.25),
                blurRadius: 4,
              )
            ],
            color: Color.fromRGBO(250, 110, 0, 0.7),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.all(
                  SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
            ),
          ),
          child: Center(
            child: Text(
              txt,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                height: 0,
                letterSpacing: 0.16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
