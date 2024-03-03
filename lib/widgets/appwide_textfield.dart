// ignore_for_file: must_be_immutable

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppwideTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;

  double height;

  AppwideTextField(
      {required this.hintText, required this.onChanged, this.height = 1.1});

  @override
  Widget build(BuildContext context) {
    return Container(
      // rgba(165, 200, 199, 1),
      decoration: const ShapeDecoration(
        shadows: [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(165, 200, 199, 0.6),
            blurRadius: 20,
          )
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
        ),
      ),
      height: height == 1.1 ? 6.h : height,
      child: Center(
        child: TextField(
          decoration: InputDecoration(
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(left: 14),
            hintText: hintText,
            hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0A4C61),
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
