import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CustomIconButton extends StatelessWidget {
  final IconData ic;
  final Color? color;
  final Color boxColor;
  final String text;
  final Function? onTap;

  CustomIconButton({
    required this.ic,
    this.onTap,
    this.color,
    this.boxColor = Colors.white,
    this.text = '',
  });

  @override
  Widget build(BuildContext context) {
    String? userType = Provider.of<Auth>(context, listen: false).userData?['user_type'];

    // Determine the profile color based on the user type
    Color colorProfile;
    if (userType == 'Vendor') {
      colorProfile = const Color(0xFF094B60);
    } else if (userType == 'Customer') {
      colorProfile = const Color(0xFF2E0536);
    } else if (userType == 'Supplier') {
      colorProfile = const Color.fromARGB(255, 26, 48, 10);
    } else {
      colorProfile = const Color.fromRGBO(77, 191, 74, 0.6); // Default color if user_type is none of the above
    }

    // Determine the box shadow color based on the user type
    Color boxShadowColor;
    if (userType == 'Vendor') {
      boxShadowColor = const Color.fromRGBO(10, 76, 97, 0.5);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xBC73BC).withOpacity(0.5);
    } else if (userType == 'Supplier') {
      boxShadowColor = const Color.fromARGB(0, 115, 188, 150).withOpacity(0.5);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6); // Default color if user_type is none of the above
    }

    // If color is provided, use it for the box shadow color
    boxShadowColor = color ?? boxShadowColor;

    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shadows: [
            BoxShadow(
              offset: const Offset(0, 4),
              color: boxShadowColor,
              blurRadius: 20,
            )
          ],
          color: boxColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 1,
            ),
          ),
        ),
        child: text == ''
            ? Icon(
                ic,
                color: colorProfile,
              )
            : text == 'notification'
                ? Transform.rotate(
                    angle: 25 * 3.1415926535 / 180, //
                    child: Icon(
                      ic,
                      color: colorProfile,
                    ),
                  )
                : Center(
                    child: Image.asset(
                      'assets/images/back_double_arrow.png',
                      width: 24, // You can adjust the width and height as needed
                      height: 24,
                    ),
                  ),
      ),
    );
  }
}

