import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class AppwideBanner extends StatelessWidget {
  // const AppwideBanner({super.key});
  double height;
  AppwideBanner({super.key, this.height = 300});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800, // Set the maximum width to 800
        ),
        child: Container(
            width: 100.w,
            height: height == 300 ? 30.h : height,
            decoration: ShapeDecoration(
              color: Color(0xFFB1D9D8),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    bottomLeft:
                        SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                    bottomRight:
                        SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
              ),
            )),
      ),
    );
  }
}
