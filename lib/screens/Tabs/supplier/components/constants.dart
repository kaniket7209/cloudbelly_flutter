import 'package:cloudbelly_app/api_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

//import '../../../api_service.dart';


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
      Provider.of<Auth>(context, listen: false).userData?['user_type'] == 'Vendor';
  return showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          context.read<TransitionEffect>().setBlurSigma(0);
          return true;
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          // Adjust as needed
          minChildSize: 0.3,
          // Adjust as needed
          maxChildSize: 0.55,
          // Adjust as needed
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              double extent = 10; // Initial extent value
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent != extent) {
                    extent = notification.extent;
                    // print('Extent: $extent');
                    context.read<TransitionEffect>().setBlurSigma(
                        notification.extent * 10); // Print extent value
                  }
                  return false;
                },
                child: SingleChildScrollView(
                    controller: scrollController, child: childWidget),
              );
            });
          },
        ),
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
