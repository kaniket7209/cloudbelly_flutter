import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/inventory.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/inventory_hub.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/store_setup_sheets.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialStatusContent extends StatefulWidget {
  const SocialStatusContent({
    super.key,
  });

  @override
  State<SocialStatusContent> createState() => _SocialStatusContentState();
}

class _SocialStatusContentState extends State<SocialStatusContent> {
  @override
  void dispose() {
    // bool _isLoading = false;
    // TODO: implement dispose
    super.dispose();
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: 100.w <= 420
          ? EdgeInsets.only(left: 5.w, right: 5.w)
          : EdgeInsets.only(left: 0.5.w, right: 0.5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoldTextWidgetHomeScreen(txt: 'Tools & essentials'),
          Space(2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TouchableOpacity(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setInt('counter', 1);
                    final counter = prefs.getInt('counter') ?? 1;

                    if (counter < 4) {
                      return SlidingSheet().showAlertDialog(context, counter);
                    } else {
                      TOastNotification().showSuccesToast(context, 'All Set ');
                    }
                  },
                  child: ToolsButtonWidgetHomeSCreen(
                      width: 100.w > 420 ? 4.w : 15.w, txt: 'Setup Store')),
              ToolsButtonWidgetHomeSCreen(
                width: 100.w > 420 ? 4.w : 15.w,
                txt: 'Photos & Videos',
              ),
              TouchableOpacity(
                  onTap: () {
                    return Navigator.of(context)
                        .pushNamed(InventoryHub.routeName);
                  },
                  child: ToolsButtonWidgetHomeSCreen(
                    width: 100.w > 420 ? 4.w : 15.w,
                    txt: 'Inventory Manage',
                  )),
              TouchableOpacity(
                onTap: () {
                  return showModalBottomSheet(
                    // useSafeArea: true,
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius.only(
                                    topLeft: SmoothRadius(
                                        cornerRadius: 35, cornerSmoothing: 1),
                                    topRight: SmoothRadius(
                                        cornerRadius: 35, cornerSmoothing: 1)),
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: double.infinity,
                            padding: EdgeInsets.only(
                                left: 10.w, right: 10.w, top: 2.h, bottom: 2.h),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TouchableOpacity(
                                    onTap: () {
                                      return Navigator.of(context).pop();
                                    },
                                    child: Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.h, horizontal: 3.w),
                                        width: 65,
                                        height: 9,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFFA6E00),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Space(6.h),
                                  const Text(
                                    'Scan your menu',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 26,
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.w600,
                                      height: 0.03,
                                      letterSpacing: 0.78,
                                    ),
                                  ),
                                  Space(4.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TouchableOpacity(
                                        onTap: !_isLoading
                                            ? () async {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                dynamic data =
                                                    await ScanMenu('Gallery');
                                                // print(data);
                                                Navigator.of(context).pop();
                                                ScannedMenuBottomSheet(
                                                    context, data);
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              }
                                            : null,
                                        child: StocksMayBeNeedWidget(
                                            txt: 'Upload from gallery'),
                                      ),
                                      TouchableOpacity(
                                          onTap: !_isLoading
                                              ? () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });
                                                  final data =
                                                      await ScanMenu('Camera');
                                                  Navigator.of(context).pop();
                                                  ScannedMenuBottomSheet(
                                                      context, data);
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                }
                                              : null,
                                          child: StocksMayBeNeedWidget(
                                              txt: 'Click photo')),
                                      Space(isHorizontal: true, 5.w),
                                      if (_isLoading)
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: ToolsButtonWidgetHomeSCreen(
                  width: 100.w > 420 ? 4.w : 15.w,
                  txt: 'Upload Menu',
                ),
              ),
              ToolsButtonWidgetHomeSCreen(
                width: 100.w > 420 ? 4.w : 15.w,
                txt: 'Dashboard',
              ),
            ],
          ),
          Space(3.h),
          Center(
            child: Card(
              elevation: 10,
              child: Container(
                  height: 6.h,
                  width: 75.w,
                  padding: EdgeInsets.only(left: 1.w, right: 1.w),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Gaon',
                            style: TextStyle(
                              color: Color(0xFF0A4C61),
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.24,
                            ),
                          ),
                          TextSpan(
                            text: 'FRESH',
                            style: TextStyle(
                              color: Color(0xFF63AFC7),
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
          Space(3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BoldTextWidgetHomeScreen(txt: 'Inventory forecasting'),
              Column(
                children: [
                  Text(
                    'Expand',
                    style: GoogleFonts.ptSans(
                        color: const Color.fromRGBO(10, 76, 97, 1),
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                  Container(
                    height: 2,
                    width: 45,
                    color: const Color.fromRGBO(250, 110, 0, 1),
                  )
                ],
              )
            ],
          ),
          Space(2.h),
          InventoryForcastingWidget(isBuy: true),
          Space(3.h),
          const BoldTextWidgetHomeScreen(txt: 'Inventory based recipe'),
          Space(1.5.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 18.h,
              child: Center(
                child: Row(
                  children: [
                    InvetoryBasedReciepeWidget(),
                    InvetoryBasedReciepeWidget(),
                    InvetoryBasedReciepeWidget(),
                    InvetoryBasedReciepeWidget(),
                  ],
                ),
              ),
            ),
          ),
          Space(3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BoldTextWidgetHomeScreen(txt: 'Inventory wastage'),
              Column(
                children: [
                  Text(
                    'Expand',
                    style: GoogleFonts.ptSans(
                        color: const Color.fromRGBO(10, 76, 97, 1),
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                  Container(
                    height: 2,
                    width: 45,
                    color: const Color.fromRGBO(250, 110, 0, 1),
                  )
                ],
              )
            ],
          ),
          Space(2.h),
          InventoryForcastingWidget(
            isBuy: false,
          ),
          Space(3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BoldTextWidgetHomeScreen(txt: 'Reselling marketplace'),
              Column(
                children: [
                  Text(
                    'Expand',
                    style: GoogleFonts.ptSans(
                        color: const Color.fromRGBO(10, 76, 97, 1),
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                  Container(
                    height: 2,
                    width: 45,
                    color: const Color.fromRGBO(250, 110, 0, 1),
                  )
                ],
              )
            ],
          ),
          Space(1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 18.h,
              child: Center(
                child: Row(
                  children: [
                    InvetoryBasedReciepeWidget(
                      isResell: true,
                    ),
                    InvetoryBasedReciepeWidget(
                      isResell: true,
                    ),
                    InvetoryBasedReciepeWidget(
                      isResell: true,
                    ),
                    InvetoryBasedReciepeWidget(
                      isResell: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
