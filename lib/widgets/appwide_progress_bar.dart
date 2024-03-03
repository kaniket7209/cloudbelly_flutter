// ignore_for_file: must_be_immutable

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppWIdeProgreesBar extends StatelessWidget {
  Color color;
  double part;

  AppWIdeProgreesBar({
    super.key,
    required this.color,
    required this.part,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 15,
          decoration: ShapeDecoration(
            shadows: const [
              BoxShadow(
                offset: Offset(0, 4),
                color: Color.fromRGBO(124, 193, 191, 0.3),
                blurRadius: 20,
              )
            ],
            color: Color.fromRGBO(223, 244, 248, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 5,
                cornerSmoothing: 1,
              ),
            ),
          ),
          width: 90.w,
        ),
        Container(
          height: 15,
          decoration: ShapeDecoration(
            shadows: const [
              BoxShadow(
                offset: Offset(0, 4),
                color: Color.fromRGBO(124, 193, 191, 0.3),
                blurRadius: 20,
              )
            ],
            color: color,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 5,
                cornerSmoothing: 1,
              ),
            ),
          ),
          width: 90.w * part,
        ),
      ],
    );
  }
}
