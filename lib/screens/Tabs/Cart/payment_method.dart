import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'view_cart.dart';

class PaymentMethodScreen extends StatefulWidget {
  static const routeName = '/cart/payment-method-screen';

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TouchableOpacity(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                            top: 10,
                            bottom: 10,
                          ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 60.w,
                            child: Text(
                              'Payment options',
                              style: TextStyle(
                                color: Color(0xFF1E1E1E),
                                fontSize: 16,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '3 items . Total - Rs 390',
                            style: TextStyle(
                                color: Color(0xFF494949),
                                fontSize: 12,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w400,
                                height: 0),
                          ),
                        ],
                      )
                    ],
                  ),
                  Space(12),
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
                    children: [
                      Column(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 165, 0, 1),
                                  borderRadius: BorderRadius.circular(10))),
                          Container(
                              height: 20,
                              width: 2,
                              color: Color.fromRGBO(255, 165, 0, 1)),
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 165, 0, 1),
                                  borderRadius: BorderRadius.circular(10))),
                        ],
                      ),
                      Space(
                        9,
                        isHorizontal: true,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Easy Bites by hotel Empire',
                                style: TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 12,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Space(8, isHorizontal: true),
                              Container(
                                  height: 15,
                                  width: 0.8,
                                  color: Color.fromRGBO(213, 149, 102, 1)),
                              Space(5, isHorizontal: true),
                              Text(
                                'Delivery in 26 minutes',
                                style: TextStyle(
                                  color: Color(0xFF494949),
                                  fontSize: 12,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          Space(8),
                          Row(
                            children: [
                              Text(
                                'Aniket Singh',
                                maxLines: 2,
                                style: TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 12,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Space(8, isHorizontal: true),
                              Container(
                                  height: 15,
                                  width: 0.8,
                                  color: Color.fromRGBO(213, 149, 102, 1)),
                              Space(5, isHorizontal: true),
                              SizedBox(
                                width: 50.w,
                                child: Text(
                                  '23rd Main Rd, Hosapalaya, Bangalore, Karnataka, India',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color.fromRGBO(73, 73, 73, 1),
                                    fontSize: 12,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Space(2.h),
                ],
              ),
            ),
          ),
          Space(36),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidgetCart(text: 'UPI'),
                  Space(20),
                  PaymentMethodCart(
                    title: 'Add New UPI ID',
                    subtitle: 'You need to have a registered UPI ID',
                  ),
                  Space(40),
                  TextWidgetCart(text: 'Credit & Debit Card'),
                  Space(20),
                  PaymentMethodCart(
                    title: 'Add New Card',
                    subtitle: 'Save and pay via cards',
                  ),
                ],
              )),
        ]),
      ),
    );
  }
}

class PaymentMethodCart extends StatelessWidget {
  String title;
  String subtitle;
  PaymentMethodCart({
    super.key,
    required this.subtitle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: GlobalVariables().ContainerDecoration(
          offset: Offset(0, 4),
          blurRadius: 15,
          shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
          boxColor: Colors.white,
          cornerRadius: 15),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: GlobalVariables().ContainerDecoration(
                offset: Offset(0, 4),
                blurRadius: 15,
                shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
                boxColor: Color.fromRGBO(210, 114, 229, 1),
                cornerRadius: 10),
            child: Center(
                child: Text(
              '+',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )),
          ),
          Space(17, isHorizontal: true),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFFFA6E00),
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Color(0xFF494949),
                  fontSize: 12,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Color(0xFFFA6E00),
          )
        ],
      ),
    );
  }
}
