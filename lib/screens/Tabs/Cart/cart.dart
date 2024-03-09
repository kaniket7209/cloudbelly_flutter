import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 65.w,
            decoration: ShapeDecoration(
              shadows: [
                const BoxShadow(
                  offset: Offset(0, 4),
                  color: Color.fromRGBO(31, 111, 109, 0.6),
                  blurRadius: 20,
                )
              ],
              shape: SmoothRectangleBorder(),
            ),
            child: ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 35,
                  cornerSmoothing: 1,
                ),
                child: Image.asset(Assets.coming_soon_jpg))),
        Space(3.h),
        Center(
          child: Text(
            'Feature Coming Soon',
            style: TextStyle(
              color: Color(0xFF094B60),
              fontSize: 20,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
              // height: 0.05,
              letterSpacing: 0.60,
            ),
          ),
        )
      ],
    );
  }
}
