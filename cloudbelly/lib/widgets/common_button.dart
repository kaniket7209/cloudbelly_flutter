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
        decoration: BoxDecoration(
          border: Border.all(width: 0.3),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
