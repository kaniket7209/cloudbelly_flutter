// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/performance.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/social_status.dart';
import 'package:cloudbelly_app/screens/supplier/components/constants.dart';
import 'package:cloudbelly_app/screens/supplier/supplier_inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'components/components.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard>
    with SingleTickerProviderStateMixin {
  int _activeButtonIndex = 2;

  Future<void> _refreshFeed() async {
    setState(() {});
  }

  Widget _profileSummary() {
    return Column(
      children: [
        Space(3.h),
        // Adjusted the width of buttons based on screen width
        _activeButtonIndex == 1
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ColumnWidgetHomeScreen(
                    data: 8.toString(),
                    txt: 'Stock Health',
                  ),
                  ColumnWidgetHomeScreen(
                    data: '23%',
                    txt: 'Waste %aGE',
                  ),
                  ColumnWidgetHomeScreen(
                    data: '4.3x',
                    txt: 'Avg turnaround',
                  )
                ],
              )
            : _activeButtonIndex == 2
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ColumnWidgetHomeScreen(
                        data: '10',
                        txt: 'Stock health',
                      ),
                      ColumnWidgetHomeScreen(
                        data: '23%',
                        txt: 'Waste %age',
                      ),
                      ColumnWidgetHomeScreen(
                        data: '5.6',
                        txt: 'Avg turnaround',
                      )
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ColumnWidgetHomeScreen(
                        data: '10',
                        txt: 'Total Customers',
                      ),
                      ColumnWidgetHomeScreen(
                        data: '32',
                        txt: 'Total orders',
                      ),
                      ColumnWidgetHomeScreen(
                        data: '5',
                        txt: 'Repeat Customers',
                      )
                    ],
                  ),

        Space(3.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TouchableOpacity(
              onTap: () {
                setState(() {
                  _activeButtonIndex = 1;
                });
              },
              child: ButtonWidgetHomeScreen(
                width: 27.w,
                txt: 'Social Status',
                isActive: _activeButtonIndex == 1,
              ),
            ),
            TouchableOpacity(
              onTap: () {
                setState(() {
                  _activeButtonIndex = 2;
                });
              },
              child: ButtonWidgetHomeScreen(
                width: 27.w,
                txt: 'Inventory',
                isActive: _activeButtonIndex == 2,
              ),
            ),
            TouchableOpacity(
              onTap: () {
                setState(() {
                  _activeButtonIndex = 3;
                });
              },
              child: ButtonWidgetHomeScreen(
                width: 28.w,
                txt: 'Performance',
                isActive: _activeButtonIndex == 3,
              ),
            ),
          ],
        ),
        Space(2.h)
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800, // Set your maximum width here
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SupplierBanner(),
                  Column(
                    children: [
                      Space(6.h),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 800, // Set the maximum width to 800
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // SvgPicture.asset(
                              //   Assets.notification_svg,
                              //   color: Colors.red,
                              //   width: 20, // Adjust width and height as needed
                              //   height: 20,
                              // ),
                              CustomIconButton(
                                text: 'notification',
                                ic: Icons.notifications_outlined,
                                onTap: () {
                                  Navigator.of(context).pushNamed('/map');
                                },
                              ),
                              Container(width: 40.w, child: StoreLogoWidget()),
                              CustomIconButton(
                                ic: Icons.more_horiz,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      StoreNameWidget(),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 440, // Set the maximum width to 420
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Column(
                              children: [
                                Space(3.h),
                                whiteCardSection(_profileSummary()),
                                Space(3.h),
                                if (_activeButtonIndex == 1)
                                  SocialStatusContent(),
                                if (_activeButtonIndex == 2)
                                  const SupplierInventory(),
                                if (_activeButtonIndex == 3)
                                  const Performance(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle tap on the area around the BackdropFilter
                      print('Tapped outside of the modal bottom sheet');
                      // You can add any logic here, such as dismissing the modal bottom sheet
                      // For example:
                      // Navigator.of(context).pop();
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: context.watch<TransitionEffect>().blurSigma,
                        sigmaY: context.watch<TransitionEffect>().blurSigma,
                      ),
                      child: Container(
                        color: Colors.transparent, // Transparent color
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreLogoWidget extends StatelessWidget {
  const StoreLogoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Space(15),
        Provider.of<Auth>(context, listen: true).logo_url != ''
            ? Container(
                height: 70,
                width: 70,
                decoration: const ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(163, 220, 118, 1),
                      // rgba(163, 220, 118, 1)
                      blurRadius: 20,
                    )
                  ],
                  shape: SmoothRectangleBorder(),
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  ),
                  child: Image.network(
                    Provider.of<Auth>(context, listen: true).logo_url,
                    fit: BoxFit.cover,
                    loadingBuilder: GlobalVariables().loadingBuilderForImage,
                    errorBuilder: GlobalVariables().ErrorBuilderForImage,
                  ),
                ),
              )
            : Container(
                height: 70,
                width: 70,
                decoration: ShapeDecoration(
                  shadows: const [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(31, 111, 109, 0.4),
                      blurRadius: 20,
                    ),
                  ],
                  color: Color.fromRGBO(31, 111, 109, 0.6),
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  )),
                ),
                child: Center(
                  child: Text(
                    Provider.of<Auth>(context, listen: true)
                        .store_name[0]
                        .toUpperCase(),
                    style: TextStyle(fontSize: 40),
                  ),
                )),
      ],
    );
  }
}

class StoreNameWidget extends StatelessWidget {
  const StoreNameWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Space(2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.5.w),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  )),
                ),
                child: Center(
                  child: Text(
                    Provider.of<Auth>(context, listen: true).store_name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 14,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.10,
                      letterSpacing: 0.42,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class InventoryForcastingWidget extends StatelessWidget {
  bool isBuy;

  InventoryForcastingWidget({
    super.key,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w, bottom: 2.h),
        height: 24.h,
        width: double.infinity,
        decoration: ShapeDecoration(
          shadows: const [
            BoxShadow(
              color: Color.fromRGBO(165, 200, 199, 0.6),
              offset: Offset(0,
                  4), // Adjust the Y offset to control the shadow on the bottom
              blurRadius: 4,
              spreadRadius: 0,
            )
          ],
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 10,
              cornerSmoothing: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InventotyForcastingBoldTextWidget(txt: 'ITEMS'),
                        InventotyForcastingBoldTextWidget(txt: 'QTY'),
                        InventotyForcastingBoldTextWidget(txt: 'STATUS'),
                      ],
                    ),
                    Space(2.5.h),
                    const InventoryFocastRowWidget(),
                    const InventoryFocastRowWidget(),
                    const InventoryFocastRowWidget(),
                    Space(1.h),
                  ],
                ),
                // Space(isHorizontal: true, 5.w),
                Container(
                  height: 11.h,
                  width: 26.w,
                  decoration: ShapeDecoration(
                    shadows: const [
                      BoxShadow(
                        color: Color.fromRGBO(124, 193, 191, 0.3),
                        offset: Offset(0, 4),
                        // Adjust the Y offset to control the shadow on the bottom
                        blurRadius: 20,
                        spreadRadius: 0,
                      )
                    ],
                    color: const Color.fromRGBO(177, 217, 216, 1),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 5.h,
              width: 30.w,
              decoration: ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    color: Color.fromRGBO(232, 128, 55, 0.5),
                    offset: Offset(5, 6),
                    // Adjust the Y offset to control the shadow on the bottom
                    blurRadius: 30,
                    spreadRadius: 0,
                  )
                ],
                color: const Color.fromRGBO(250, 110, 0, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  isBuy ? 'Buy' : 'Resell',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.12,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class InventoryFocastRowWidget extends StatelessWidget {
  const InventoryFocastRowWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Container(
            width: 14.w,
            margin: EdgeInsets.only(right: 2.w),
            child: const Text(
              'Wheat',
              style: TextStyle(
                color: Color(0xFF0A4C61),
                fontSize: 10,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0.10,
                letterSpacing: 0.10,
              ),
            ),
          ),
          Container(
            width: 14.w,
            margin: EdgeInsets.only(right: 2.w),
            child: const Text(
              'x 5 kg',
              style: TextStyle(
                color: Color(0xFF0A4C61),
                fontSize: 10,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0,
                letterSpacing: 0.10,
              ),
            ),
          ),
          Container(
            width: 9,
            height: 8.25,
            margin: EdgeInsets.only(left: 2.w),
            decoration: const ShapeDecoration(
              color: Color(0xFFF44B4B),
              shape: OvalBorder(),
              shadows: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InventotyForcastingBoldTextWidget extends StatelessWidget {
  String txt;

  InventotyForcastingBoldTextWidget({
    super.key,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14.w,
      margin: EdgeInsets.only(right: 2.w),
      child: Text(
        txt,
        style: const TextStyle(
          color: Color(0xFF094B60),
          fontSize: 14,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w600,
          height: 0.10,
          letterSpacing: 0.42,
        ),
      ),
    );
  }
}

class InvetoryBasedReciepeWidget extends StatelessWidget {
  bool isResell;

  InvetoryBasedReciepeWidget({
    super.key,
    this.isResell = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16.h,
      width: 50.w,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      padding: EdgeInsets.only(left: 1.w, right: 1.w),
      decoration: ShapeDecoration(
        shadows: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0,
                4), // Adjust the Y offset to control the shadow on the bottom
            blurRadius: 4,
            spreadRadius: 0,
          )
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 10,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  margin: EdgeInsets.only(top: 1.h),
                  child: ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 15,
                      cornerSmoothing: 1,
                    ),
                    child: Image.network(
                        'https://yt3.googleusercontent.com/ytc/AIf8zZTYlXLDIuAUCzFL3-_oMTuLZZ5Cbf__p2HquXNAeA=s176-c-k-c0x00ffffff-no-rj'),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aalu Parantha',
                      style: TextStyle(
                        color: Color(0xFF0A4C61),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0.06,
                        letterSpacing: 0.14,
                      ),
                    ),
                    Space(1.h),
                    const ReciepeTextWidgetHomeScreen(txt: 'Units - 17 pc'),
                    const ReciepeTextWidgetHomeScreen(txt: 'Units - 17 pc'),
                    const ReciepeTextWidgetHomeScreen(txt: 'Units - 17 pc'),
                  ],
                )
              ]),
          Space(0.5.h),
          Row(
            mainAxisAlignment: isResell
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceAround,
            children: [
              if (!isResell)
                Column(
                  children: [
                    const Text(
                      'Add to product',
                      style: TextStyle(
                        color: Color(0xFF0A4C61),
                        fontSize: 10,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: 0.30,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 15.w,
                      color: const Color.fromRGBO(250, 110, 0, 1),
                    )
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ButtonWidgetHomeScreen(
                  txt: isResell ? 'Add to cart' : 'Learn recipe',
                  isActive: true,
                  height: 3.h,
                  width: 22.w,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ReciepeTextWidgetHomeScreen extends StatelessWidget {
  final String txt;

  const ReciepeTextWidgetHomeScreen({
    super.key,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: const TextStyle(
        color: Color(0xFF0A4C61),
        fontSize: 10,
        fontFamily: 'Product Sans',
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class BoldTextWidgetHomeScreen extends StatelessWidget {
  final txt;

  const BoldTextWidgetHomeScreen({
    super.key,
    this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: const TextStyle(
        color: Color(0xFF094B60),
        fontSize: 18,
        fontFamily: 'Jost',
        fontWeight: FontWeight.w600,
        // height: 0.06,
        letterSpacing: 0.54,
      ),
    );
  }
}

class ToolsButtonWidgetHomeSCreen extends StatelessWidget {
  double width;
  final String txt;

  ToolsButtonWidgetHomeSCreen({
    required this.txt,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 11.h,
      width: width,
      padding: EdgeInsets.only(
        left: 1.w,
        right: 1.w,
      ),
      decoration: ShapeDecoration(
        shadows: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(165, 200, 199, 0.4),
            blurRadius: 10,
          )
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 10,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Space(1.5.h),
          const Icon(Icons.person_outline_rounded),
          Space(1.h),
          Text(
            txt,
            style: const TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 10,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.10,
            ),
            maxLines: null,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ColumnWidgetHomeScreen extends StatelessWidget {
  String data;
  String txt;

  ColumnWidgetHomeScreen({
    required this.data,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          data,
          style: const TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 35,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0,
            letterSpacing: 0.35,
          ),
        ),
        Text(
          txt,
          style: const TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 11,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w400,
            height: 0,
            letterSpacing: 0.11,
          ),
        )
      ],
    );
  }
}

class ButtonWidgetHomeScreen extends StatelessWidget {
  final txt;
  bool isActive;
  double height;
  double width;
  double radius;

  ButtonWidgetHomeScreen({
    super.key,
    this.txt,
    required this.isActive,
    this.height = 1,
    this.width = 1,
    this.radius = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height == 1 ? 41 : height,
      width: width == 1 ? 125 : width,
      decoration: ShapeDecoration(
        shadows: isActive == true
            ? [
                BoxShadow(
                    offset: Offset(5, 6),
                    spreadRadius: 0.1,
                    color: Color.fromRGBO(232, 128, 55, 0.5),
                    blurRadius: 10)
              ]
            : [],
        color: isActive
            ? const Color.fromRGBO(250, 110, 0, 1)
            : Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: radius == 1 ? 10 : radius,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Center(
          child: Text(
        txt,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xff0A4C61),
          fontSize: 14,
          fontFamily: 'Product Sans',
          fontWeight: FontWeight.w700,
          height: 0,
          letterSpacing: 0.30,
        ),
      )),
    );
  }
}
