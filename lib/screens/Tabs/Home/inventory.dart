import 'package:cloudbelly_app/screens/Tabs/Home/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Inventory extends StatefulWidget {
  const Inventory({
    super.key,
  });

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  void _launchURL(String url) async {
    // url = 'https://rgbacolorpicker.com/hex-to-rgba';
    Uri googleSheetUrl = Uri.parse(url);
    if (!await launchUrl(googleSheetUrl, mode: LaunchMode.inAppBrowserView)) {
      TOastNotification().showErrorToast(context, 'Error while opening Sheet');
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Make_Update_ListWidget(
              txt: 'Make List',
              onTap: () async {
                final data = await HomeApi().getSheetUrl();
                _launchURL(data['sheet_url']);
              },
            ),
            Make_Update_ListWidget(
              txt: 'Update List',
              onTap: () async {
                final data = await HomeApi().SyncInventory();
                print(data);
                UpdateListBottomSheet(context, data);
              },
            ),
          ],
        ),
        Space(3.h),
        Row(
          children: [
            BoldTextWidgetHomeScreen(
              txt: 'Stocks you may need',
            ),
            Spacer(),
            SeeAllWidget(),
          ],
        ),
        Space(2.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
              StocksMayBeNeedWidget(),
            ],
          ),
        ),
        Space(2.h),
        Center(
          child: ButtonWidgetHomeScreen(
            width: 33.w,
            txt: 'Add to cart',
            isActive: true,
          ),
        ),
        Space(3.h),
        Row(
          children: [
            BoldTextWidgetHomeScreen(
              txt: 'Low stocks',
            ),
            Spacer(),
            SeeAllWidget(),
          ],
        ),
        Space(2.h),
        LowStocksWidget(),
        LowStocksWidget(),
        LowStocksWidget(),
        LowStocksWidget(),
      ],
    );
  }

  Future<dynamic> UpdateListBottomSheet(BuildContext context, dynamic data) {
    dynamic UiData = data;
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
                      topLeft:
                          SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                      topRight:
                          SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.9,
              width: double.infinity,
              padding:
                  EdgeInsets.only(left: 6.w, right: 6.w, top: 2.h, bottom: 2.h),
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
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                    Space(6.h),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Inventory List',
                          style: TextStyle(
                            color: Color(0xFF094B60),
                            fontSize: 30,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.02,
                            letterSpacing: 0.90,
                          ),
                        ),
                        Text(
                          'Powered by BellyAI',
                          style: TextStyle(
                            color: Color(0xFFFA6E00),
                            fontSize: 13,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w400,
                            height: 0.15,
                          ),
                        )
                      ],
                    ),
                    Space(3.h),
                    Divider(
                      color: Color(0xFFFA6E00),
                    ),
                    Space(1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SheetLabelWidget(
                          txt: 'ID',
                          width: 7.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Item name',
                          width: 23.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Price',
                          width: 15.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Volume',
                          width: 16.w,
                        ),
                      ],
                    ),
                    Space(1.h),
                    Divider(
                      color: Color(0xFFFA6E00),
                    ),
                    Space(2.h),
                    Container(
                      height: 60.h,
                      // ma: EdgeInsets.symmetric(vertical: 6.h),
                      child: ListView.builder(
                        itemCount:
                            (UiData['data']['inventory_data'] as List<dynamic>)
                                .length,
                        itemBuilder: (context, index) {
                          return BottomSheetRowWidget(
                              id: UiData['data']['inventory_data'][index]['ID'],
                              name: UiData['data']['inventory_data'][index]
                                  ['NAME'],
                              price: UiData['data']['inventory_data'][index]
                                      ['TOTAL PRICE( Rs)'] ??
                                  '-',
                              volume: UiData['data']['inventory_data'][index]
                                      ['VOLUME PURCHASED'] ??
                                  '-',
                              type: UiData['data']['inventory_data'][index]
                                  ['PRODUCT TYPE']);
                        },
                      ),
                    ),
                    Space(3.h),
                    AppWideButton(
                        onTap: () async {
                          final newData = await HomeApi().SyncInventory();
                          setState(() {
                            UiData = newData;
                            print('ui');
                            print(UiData);
                          });
                        },
                        num: 1,
                        txt: 'Sync the inventory items')
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class LowStocksWidget extends StatelessWidget {
  const LowStocksWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      width: double.infinity,
      height: 7.h,
      decoration: ShapeDecoration(
        shadows: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(177, 202, 202, 0.6),
            blurRadius: 15,
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
      child: Row(
        children: [
          Space(isHorizontal: true, 3.w),
          Container(
              height: 35,
              width: 35,
              decoration: ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    offset: Offset(0, 4),
                    color: Color.fromRGBO(124, 193, 191, 0.3),
                    blurRadius: 20,
                  )
                ],
                color: Color.fromRGBO(200, 233, 233, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                ),
              )),
          Space(isHorizontal: true, 3.w),
          Text(
            'Wheat',
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              height: 0.05,
              letterSpacing: 0.14,
            ),
          ),
          Space(isHorizontal: true, 12.w),
          Stack(
            children: [
              Container(
                height: 20,
                decoration: ShapeDecoration(
                  shadows: const [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(124, 193, 191, 0.3),
                      blurRadius: 20,
                    )
                  ],
                  color: Color.fromRGBO(223, 244, 248, 1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                width: 60.w * (5 / (5 + 1)),
              ),
              Container(
                height: 20,
                decoration: ShapeDecoration(
                  shadows: const [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(124, 193, 191, 0.3),
                      blurRadius: 20,
                    )
                  ],
                  color: Color.fromRGBO(245, 75, 75, 1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                width: 60.w * (1 / (5 + 1)),
              ),
              Positioned(
                  left: 10,
                  top: 5,
                  child: Text(
                    '5kg left',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                      letterSpacing: 0.08,
                    ),
                  )),
              Positioned(
                  right: 10,
                  top: 5,
                  child: Text(
                    '1 days runway',
                    style: TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 8,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                      letterSpacing: 0.08,
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class StocksMayBeNeedWidget extends StatelessWidget {
  const StocksMayBeNeedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          Container(
              height: 60,
              width: 60,
              decoration: ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    offset: Offset(0, 4),
                    color: Color.fromRGBO(124, 193, 191, 0.3),
                    blurRadius: 20,
                  )
                ],
                color: Color.fromRGBO(200, 233, 233, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                ),
              )),
          Space(1.h),
          Text(
            'Chicken',
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 11,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              height: 0,
              letterSpacing: 0.11,
            ),
          )
        ],
      ),
    );
  }
}

class SeeAllWidget extends StatelessWidget {
  const SeeAllWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'See all',
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0.14,
            letterSpacing: 0.36,
          ),
        ),
        Space(isHorizontal: true, 2.w),
        Icon(
          Icons.arrow_forward_ios,
          size: 13,
          color: const Color(0xFFFA6E00),
        ),
      ],
    );
  }
}

class BottomSheetRowWidget extends StatelessWidget {
  String id;
  String name;

  String price;
  String volume;
  String type;
  BottomSheetRowWidget({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.volume,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 7.w,
            child: Text(
              id,
              style: TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0.13,
              ),
            ),
          ),
          Container(
            width: 23.w,
            child: Text(
              name,
              style: TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0.13,
              ),
            ),
          ),
          Container(
            width: 15.w,
            child: Text(
              'Rs  ' + price,
              style: TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0.13,
              ),
            ),
          ),
          Container(
            width: 16.w,
            child: Text(
              volume + ' ' + type,
              style: TextStyle(
                color: Color(0xFF094B60),
                fontSize: 13,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                height: 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetLabelWidget extends StatelessWidget {
  String txt;
  double width;
  SheetLabelWidget({
    super.key,
    required this.txt,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        txt,
        style: TextStyle(
          color: Color(0xFF094B60),
          fontSize: 18,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w600,
          height: 0.06,
        ),
      ),
    );
  }
}

class Make_Update_ListWidget extends StatelessWidget {
  String txt;
  final Function? onTap;
  Make_Update_ListWidget({
    super.key,
    required this.txt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Container(
          height: 5.h,
          width: 30.w,
          decoration: ShapeDecoration(
            shadows: const [
              BoxShadow(
                offset: Offset(5, 6),
                color: Color.fromRGBO(72, 138, 136, 0.5),
                blurRadius: 20,
              )
            ],
            color: Color.fromRGBO(84, 166, 193, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              txt,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                height: 0,
                letterSpacing: 0.14,
              ),
            ),
          )),
    );
  }
}
