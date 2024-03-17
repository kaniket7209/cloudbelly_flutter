import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CommonButton extends StatelessWidget {
  final String text;
  CommonButton(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 5.h,
        width: double.infinity,
        decoration: ShapeDecoration(
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
          child: Text(
            text,
            style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0A4C61),
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
