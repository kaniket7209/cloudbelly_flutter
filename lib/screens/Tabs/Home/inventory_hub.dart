// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class InventoryHub extends StatefulWidget {
  static const routeName = '/profile/inventory-hub';

  @override
  State<InventoryHub> createState() => _InventoryHubState();
}

class _InventoryHubState extends State<InventoryHub> {
  // int _activeButtonIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800, // Set your maximum width here
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppwideBanner(),
                  Column(
                    children: [
                      Space(10.h),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomIconButton(
                              color: Color.fromRGBO(250, 110, 0, 1),
                              ic: Icons.arrow_back_ios_new_outlined,
                              onTap: () {
                                return Navigator.of(context).pop();
                              },
                            ),
                            Text(
                              'Inventory Hub',
                              style: TextStyle(
                                color: Color(0xFF094B60),
                                fontSize: 26,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                                height: 0.04,
                                letterSpacing: 0.78,
                              ),
                            ),
                            CustomIconButton(
                              color: Color.fromRGBO(250, 110, 0, 1),
                              ic: Icons.more_horiz,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      Space(4.h),
                      Center(
                          child: Container(
                        height: 20.h,
                        width: 90.w,
                        decoration: ShapeDecoration(
                          shadows: const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: Color.fromRGBO(165, 200, 199, 0.6),
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
                        child: Column(
                          children: [
                            Space(3.5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ColumnWidgetHomeScreen(
                                  data: (4.9).toString(),
                                  txt: 'Rating',
                                ),
                                ColumnWidgetHomeScreen(
                                  data: (789).toString(),
                                  txt: 'Followers',
                                ),
                                ColumnWidgetHomeScreen(
                                  data: '+${43}',
                                  txt: 'New followers',
                                )
                              ],
                            ),
                            Space(3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TouchableOpacity(
                                  onTap: () {},
                                  child: ButtonWidgetHomeScreen(
                                      txt: 'Add items', isActive: true),
                                ),
                                TouchableOpacity(
                                  onTap: () {},
                                  child: ButtonWidgetHomeScreen(
                                    txt: 'Quick View',
                                    isActive: true,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ))
                    ],
                  )
                ],
              ),
              Space(3.h),
            ],
          ),
        ),
      ),
    );
  }
}

class CommonButtonProfile extends StatelessWidget {
  bool isActive;
  String txt;
  CommonButtonProfile({
    super.key,
    required this.isActive,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 5.h,
        width: 25.w,
        decoration: isActive
            ? ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    offset: Offset(5, 6),
                    color: Color.fromRGBO(124, 193, 191, 0.44),
                    blurRadius: 20,
                  )
                ],
                color: Color.fromRGBO(177, 217, 216, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                ),
              )
            : ShapeDecoration(shape: SmoothRectangleBorder()),
        child: Center(
          child: Text(
            txt,
            style: TextStyle(
              color: isActive ? Colors.white : Color(0xFF094B60),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              height: 0.10,
              letterSpacing: 0.42,
            ),
          ),
        ));
  }
}
