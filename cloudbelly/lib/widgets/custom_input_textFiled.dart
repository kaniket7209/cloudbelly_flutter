import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomInputTextField extends StatefulWidget {
  CustomInputTextField({required this.label, required this.fun});

  String label;
  String fun;

  @override
  State<CustomInputTextField> createState() => _CustomInputTextFieldState();
}

class _CustomInputTextFieldState extends State<CustomInputTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color of the TextField
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(
        //   width: 0,
        // ),
      ),
      child: TextField(
        decoration: InputDecoration(
          fillColor: Colors.white,
          contentPadding: EdgeInsets.only(left: 14),
          hintText: widget.label,
          hintStyle: TextStyle(fontSize: 18),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          widget.fun;
        },
      ),
    );
  }
}
