import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ViewCart extends StatefulWidget {
  static const routeName = '/view-cart';

  @override
  State<ViewCart> createState() => _ViewCartState();
}

class _ViewCartState extends State<ViewCart> {
  bool _isAddressExpnaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(254, 247, 254, 1),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 100.w,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    bottomLeft:
                        SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                    bottomRight:
                        SmoothRadius(cornerRadius: 40, cornerSmoothing: 1)),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  Space(5.5.h),
                  Row(
                    children: [
                      TouchableOpacity(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 10, top: 10, bottom: 10),
                          child: SizedBox(
                            width: 25,
                            child: Text(
                              '<<',
                              style: TextStyle(
                                color: Color(0xFFFA6E00),
                                fontSize: 22,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.66,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60.w,
                        child: Text(
                          'Geeta’s Kitchen',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 16,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                  Space(0.5.h),
                  Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 0.50,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color(0xFF2E0536),
                        ),
                      ),
                    ),
                  ),
                  Space(1.7.h),
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.st,
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 35,
                        color: Color(0xFFFA6E00),
                      ),
                      Text(
                        '21 min to Home',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 18,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w500,
                          height: 0.05,
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        width: 35.w,
                        child: Text(
                          'Colive Gardenia, HSR Layout, Banglore, India',
                          maxLines: _isAddressExpnaded ? 6 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xFF2E0536),
                              fontSize: 14,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      TouchableOpacity(
                        onTap: () {
                          setState(() {
                            _isAddressExpnaded = !_isAddressExpnaded;
                          });
                        },
                        child: Icon(
                          _isAddressExpnaded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 35,
                          color: Color(0xFFFA6E00),
                        ),
                      ),
                    ],
                  ),
                  Space(2.h),
                ],
              ),
            ),
          ),
          Space(3.5.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: GlobalVariables().ContainerDecoration(
                      offset: Offset(0, 4),
                      blurRadius: 15,
                      shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
                      boxColor: Colors.white,
                      cornerRadius: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ordering for somebody?',
                        style: TextStyle(
                          color: Color(0xFF2E0536),
                          fontSize: 14,
                          fontFamily: 'Product Sans Medium',
                          fontWeight: FontWeight.w500,
                          height: 0.13,
                        ),
                      ),
                      Text(
                        'Add details',
                        style: TextStyle(
                          color: Color(0xFFFA6E00),
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          height: 0.08,
                        ),
                      )
                    ],
                  ),
                ),
                Space(32),
                Container(
                  padding: EdgeInsets.only(
                      top: 2.5.h, left: 4.w, right: 4.w, bottom: 1.h),
                  decoration: GlobalVariables().ContainerDecoration(
                      offset: Offset(0, 4),
                      blurRadius: 15,
                      shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
                      boxColor: Colors.white,
                      cornerRadius: 25),
                  child: Column(
                    children: [
                      for (int index = 0; index < 3; index++) MenuItemInCart(),
                    ],
                  ),
                ),
                Space(3.h),
                TextWidgetCart(text: 'Offers & Benefits'),
                Space(1.h),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: GlobalVariables().ContainerDecoration(
                      offset: Offset(0, 4),
                      blurRadius: 15,
                      shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
                      boxColor: Colors.white,
                      cornerRadius: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Apply Coupon',
                        style: TextStyle(
                          color: Color(0xFF2E0536),
                          fontSize: 14,
                          fontFamily: 'Product Sans Medium',
                          fontWeight: FontWeight.w500,
                          height: 0.13,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Color(0xFFFA6E00),
                      ),
                    ],
                  ),
                ),
                Space(33),
                TextWidgetCart(text: 'Delivery Instructions'),
                Space(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DeliveryInstructionWidgetCart(
                      text: 'Take-Away',
                    ),
                    DeliveryInstructionWidgetCart(
                      text: 'Leave at the door',
                    ),
                    DeliveryInstructionWidgetCart(
                      text: 'Avoid Calling',
                    ),
                    DeliveryInstructionWidgetCart(
                      text: 'Leave at security',
                    ),
                  ],
                ),
                Space(4.h),
                TextWidgetCart(
                    text:
                        'Review your order & address details to avoid cancellations'),
                Space(1.5.h),
                policyWidgetCart(),
              ],
            ),
          ),
          Space(2.h),
        ]),
      ),
    );
  }
}

class DeliveryInstructionWidgetCart extends StatelessWidget {
  String text;
  DeliveryInstructionWidgetCart({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      width: 70,
      height: 90,
      decoration: GlobalVariables().ContainerDecoration(
          offset: Offset(2, 5),
          blurRadius: 20,
          shadowColor: const Color.fromRGBO(158, 116, 158, 0.25),
          boxColor: Colors.white,
          cornerRadius: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        // crossAxisAlignment: cro,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4C4C4C),
              fontSize: 12,
              fontFamily: 'Product Sans Medium',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class policyWidgetCart extends StatelessWidget {
  const policyWidgetCart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: GlobalVariables().ContainerDecoration(
            offset: Offset(0, 4),
            blurRadius: 15,
            shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
            boxColor: Colors.white,
            cornerRadius: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              //If you cancel within 60 seconds of placing your
              children: [
                Text(
                  'Note:',
                  style: TextStyle(
                    color: Color(0xFFFA6E00),
                    fontSize: 14,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' If you cancel within 60 seconds of placing your',
                  style: TextStyle(
                    color: Color(0xFF383838),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Text(
              'order, a 100% refund will be issued. NO refund for cancellations made after 60 seconds.',
              style: TextStyle(
                color: Color(0xFF383838),
                fontSize: 12,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            Space(10),
            Text(
              'Avoid cancellation as it leads to food wastage.',
              style: TextStyle(
                color: Color(0xFFB549CA),
                fontSize: 12,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
            Space(18),
            Text(
              'READ CANCELLATION POLICY',
              style: TextStyle(
                color: Color(0xFFFA6E00),
                fontSize: 12,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              width: 170,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Color(0xFFFA6E00),
                  ),
                ),
              ),
            ),
            Space(20)
          ],
        ));
  }
}

class MenuItemInCart extends StatelessWidget {
  const MenuItemInCart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 2),
                      height: 15,
                      width: 15,
                      decoration: ShapeDecoration(
                        shadows: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            color: Color.fromRGBO(56, 56, 56, 0.15),
                            blurRadius: 15,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Color.fromRGBO(26, 155, 15, 1),
                            Color.fromRGBO(36, 255, 0, 1)
                          ],
                        ),
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                          cornerRadius: 4,
                          cornerSmoothing: 1,
                        )),
                      )),
                  Space(9, isHorizontal: true),
                  SizedBox(
                    width: 28.w,
                    child: Text(
                      'Aloo Tikki Burger',
                      style: TextStyle(
                        color: Color(0xFF4C4C4C),
                        fontSize: 14,
                        fontFamily: 'Product Sans Medium',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Space(24, isHorizontal: true),
                  Text(
                    'Customize ',
                    style: TextStyle(
                      color: Color(0xFF4C4C4C),
                      fontSize: 12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_sharp,
                    size: 27,
                    color: Color(0xFFFA6E00),
                  ),
                ],
              )
            ],
          ),
          Space(1, isHorizontal: true),
          Icon(
            Icons.keyboard_arrow_down_sharp,
            size: 35,
            // weight: 1000,
            color: Color(0xFFFA6E00),
          ),
          Container(
            height: 33,
            width: 33,
            decoration: GlobalVariables().ContainerDecoration(
                offset: Offset(3, 6),
                blurRadius: 20,
                shadowColor: const Color.fromRGBO(158, 116, 158, 0.5),
                boxColor: Color(0xFFFA6E00),
                cornerRadius: 8),
            child: Center(
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_up_sharp,
            size: 35,
            // weight: 1000,
            color: Color(0xFFFA6E00),
          ),
          Space(1, isHorizontal: true),
          Text(
            'Rs 120',
            style: TextStyle(
              color: Color(0xFFFA6E00),
              fontSize: 14,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
              height: 0.08,
            ),
          )
        ],
      ),
    );
  }
}

// class DotDotLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2.0;

//     final double dotSpacing = 8.0; // Spacing between dots
//     final double dotSize = 4.0; // Diameter of each dot

//     double currentX = dotSpacing / 2;

//     while (currentX < size.width) {
//       canvas.drawCircle(Offset(currentX, size.height / 2), dotSize, paint);
//       currentX += dotSpacing;
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

class TextWidgetCart extends StatelessWidget {
  TextWidgetCart({
    super.key,
    required this.text,
  });
  String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF2E0536),
        fontSize: 18,
        fontFamily: 'Jost',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
