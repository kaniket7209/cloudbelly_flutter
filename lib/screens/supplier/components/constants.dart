import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../api_service.dart';
import '../../../widgets/space.dart';
import '../../../widgets/touchableOpacity.dart';

Widget whiteCardSection(Widget widget) {
  return Container(
    decoration: ShapeDecoration(
      shadows: const [
        BoxShadow(
          offset: Offset(0, 4),
          color: Color.fromRGBO(198, 239, 161, 0.6),
// rgba
          blurRadius: 25,
        )
      ],
      color: Colors.white,
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 15,
          cornerSmoothing: 1,
        ),
      ),
    ),
    child: widget,
  );
}

Future<dynamic> customButtomSheetSection(
    BuildContext context, Widget childWidget) {
  final ScrollController _controller = ScrollController();

  bool _isVendor =
      Provider.of<Auth>(context, listen: false).userType == 'Vendor';
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Important: make the background transparent
    isScrollControlled: true,  // This allows the bottom sheet to expand to the content size
    builder: (BuildContext context) {
      return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Adjust the blur intensity
          child: SingleChildScrollView(
            child: Wrap(
                children: [childWidget]
            ),
          )
      );
    },
  );
}

Widget SemiBoldText(String title) {
  return Text(
    title,
    style: const TextStyle(
      color: Color(0xFF094B60),
      fontSize: 20,
      fontFamily: 'Jost',
      fontWeight: FontWeight.w500,
      // height: 0.06,
      letterSpacing: 0.54,
    ),
  );
}
