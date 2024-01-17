// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/screens/Tabs/Home/store_setup_sheets.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppWideButton extends StatelessWidget {
  int num;
  String txt;
  bool ispop;
  final Function? onTap;
  AppWideButton({
    super.key,
    required this.num,
    this.onTap,
    required this.txt,
    this.ispop = false,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: num > 0
          ? () {
              if (ispop) Navigator.of(context).pop();
              Navigator.of(context).pop();
              if (num < 3) SlidingSheet().showAlertDialog(context, num + 1);
            }
          : onTap,
      child: Center(
        child: Container(
          height: 6.h,
          width: 100.w,
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
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (num > 0)
                Container(
                  height: 4.h,
                  width: 35,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                    ),
                  ),
                ),
              if (num > 0) Space(isHorizontal: true, num == 2 ? 10.w : 15.w),
              Text(
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
            ],
          )),
        ),
      ),
    );
  }
}
