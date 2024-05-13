// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppwideTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  Function(String)? onSubmitted;
  TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  double height;
  final Widget? prefixIcon;
  final String? userType;

  AppwideTextField({
    required this.hintText,
    required this.onChanged,
    this.height = 1.1,
    this.onSubmitted,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // rgba(165, 200, 199, 1),
      decoration: ShapeDecoration(
        shadows: [
          BoxShadow(
            offset: const Offset(0, 4),
            color: userType ==
                UserType.Vendor.name
                ? const Color.fromRGBO(
                165, 200, 199, 0.6)
                : userType ==
                UserType.Supplier.name
                ? const Color.fromRGBO(
                77, 191, 74, 0.3)
                : const Color.fromRGBO(
                188, 115, 188, 0.2),
            blurRadius: 20,
          ),/*
          BoxShadow(
            offset: const Offset(0, 4),
            color: *//*Provider.of<Auth>(context, listen: false).userType ==
                    UserType.Vendor.name
                ?*//* const Color.fromRGBO(165, 200, 199, 0.6),
                *//*: const Color(0xFFBC73BC),*//*
            blurRadius: Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                    UserType.Vendor.name
                ? 20
                : 15,
          )*/
        ],
        color: Colors.white,
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
        ),
      ),
      height: height == 1.1 ? 6.h : height,
      child: Center(
        child: TextFormField(
          controller: controller,
          validator: validator,
          style: Provider.of<Auth>(context, listen: false)
              .userData?['user_type'] ==
              UserType.Vendor.name
              ?  const TextStyle(
            color:  Color(0xFF0A4C61) ,
          ) : const TextStyle(
              fontSize: 14,
              fontFamily: 'PT Sans',
              fontWeight: FontWeight.w400,
              color: Color(0xFF2E0536)
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(left: 14),
            hintText: hintText,
          //  suffixIcon: prefixIcon,
            hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0A4C61),
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
