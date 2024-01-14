import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppwideDropDown extends StatelessWidget {
  final String hintText;
  final String intitialValue;
  final List<String> list;
  final Function(String?) onChanged;

  AppwideDropDown({
    required this.hintText,
    required this.onChanged,
    required this.intitialValue,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // rgba(165, 200, 199, 1),
      decoration: ShapeDecoration(
        shadows: [
          BoxShadow(
              color: Color.fromRGBO(165, 200, 199, 0.4),
              blurRadius: 10,
              spreadRadius: 4)
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
        ),
      ),
      height: 6.h,
      child: Center(
        child: DropdownButton<String>(
          value: intitialValue,
          onChanged: onChanged,
          underline: Container(), // This line removes the bottom line
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
