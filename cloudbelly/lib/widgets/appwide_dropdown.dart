import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppwideDropDown extends StatefulWidget {
  final String intitialValue;
  final List<String> list;
  final Function(String?) onChanged;

  AppwideDropDown({
    required this.onChanged,
    required this.intitialValue,
    required this.list,
  });

  @override
  State<AppwideDropDown> createState() => _AppwideDropDownState();
}

class _AppwideDropDownState extends State<AppwideDropDown> {
  // ignore: non_constant_identifier_names
  String _SelectedOption = 'Select';
  @override
  Widget build(BuildContext context) {
    return Container(
      // rgba(165, 200, 199, 1),
      decoration: ShapeDecoration(
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
      height: 6.h,
      child: Center(
        child: DropdownButton<String>(
          value: _SelectedOption,
          onChanged: (value) {
            setState(() {
              _SelectedOption = value.toString();
            });

            widget.onChanged;
          },
          underline: Container(), // This line removes the bottom line
          items: widget.list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0A4C61),
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w400),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
