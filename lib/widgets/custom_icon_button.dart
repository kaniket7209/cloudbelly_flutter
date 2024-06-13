import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CustomIconButton extends StatelessWidget {
  IconData ic;
  Color color;
  Color boxColor;
  String text;

  final Function? onTap;
  CustomIconButton(
      {required this.ic,
      this.onTap,
      this.color = Colors.cyan,
      this.boxColor = Colors.white,
      this.text = ''});

  @override
  Widget build(BuildContext context) {
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';
    String? userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color boxShadowColor;

    if (userType == 'Vendor') {
      boxShadowColor = const Color.fromRGBO(10, 76, 97, 0.5);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xBC73BC).withOpacity(0.5);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150).withOpacity(0.5);
    } else {
      boxShadowColor = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }
    if (color == Colors.cyan) color = Color.fromRGBO(38, 115, 140, 1);
    return TouchableOpacity(
      onTap: onTap as void Function()?,
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shadows: [
            BoxShadow(
              offset: Offset(0, 4),
              // color: Color.fromRGBO(31, 111, 109, 0.5),
              color: boxShadowColor,
              blurRadius: 20,
            )
          ],
          color: boxColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 10,
              cornerSmoothing: 1,
            ),
          ),
        ),
        child: text == ''
            ? Icon(
                ic,
                color: color,
              )
            : text == 'notification'
                ? Transform.rotate(
                    angle: 25 * 3.1415926535 / 180, //
                    child: Icon(
                      ic,
                      color: color,
                    ),
                  )
                : Center(
                    child: Image.asset(
                      'assets/images/back_double_arrow.png',
                      width:
                          24, // You can adjust the width and height as needed
                      height: 24,
                    ),
                  ),
      ),
    );
  }
}
