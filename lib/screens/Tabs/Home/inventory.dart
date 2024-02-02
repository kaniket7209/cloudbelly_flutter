// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    _getStockData();
    _getInventoryData();
    super.initState();
  }

  void _launchURL(String url) async {
    Uri googleSheetUrl = Uri.parse(url);
    if (!await launchUrl(googleSheetUrl, mode: LaunchMode.inAppBrowserView)) {
      TOastNotification().showErrorToast(context, 'Error while opening Sheet');
      throw Exception('Could not launch $url');
    }
  }

  List<dynamic> lowStockItems = [];
  List<Map<String, dynamic>> nearExpiryItems = [];

  Future<void> _getStockData() async {
    final data = await SyncInventory();
    print('low');
    print(data);
    lowStockItems = findLowStockItems(data['data']['inventory_data']);
    print('low stocks');
  }

  Future<void> _getInventoryData() async {
    final data = await getInventoryData();
    print(data);
  }

  List<dynamic> findLowStockItems(List<dynamic> inventoryData) {
    List<dynamic> lowstocks = [];
    for (var item in inventoryData) {
      double volumeLeft = double.parse(item['VOLUME LEFT']);

      if (volumeLeft /
              double.parse(item['VOLUME'] ?? item['VOLUME PURCHASED'] ?? 100) <=
          1) {
        lowstocks.add(item);
      }
      // print(item);
    }
    return lowstocks;
  }

  int calculateDaysUntilRunOut(double volumeLeft, int shelfLife) {
    DateTime currentDate = DateTime.now();
    DateTime expirationDate = currentDate.add(Duration(days: shelfLife));
    int daysUntilRunOut = expirationDate.difference(currentDate).inDays;
    return daysUntilRunOut;
  }

  Future<void> getNearExpiryStocks() async {
    final data = await SyncInventory();
    final int thresholdDays = 100;

    final currentDate = DateTime.now();

    final dateFormat = DateFormat('dd-MM-yyyy');

    data.forEach((item) {
      if (item['EXP DATE'] != '-' && item['EXP DATE'].isNotEmpty) {
        final expiryDate = dateFormat.parse(item['EXP DATE']);

        final daysUntilExpiry = expiryDate.difference(currentDate).inDays;

        if (daysUntilExpiry <= thresholdDays) {
          nearExpiryItems.add(item);
        }
      }
    });
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
                final data = await getSheetUrl();
                _launchURL(data['sheet_url']);
              },
            ),
            Make_Update_ListWidget(
              txt: 'Update List',
              onTap: () async {
                final data = await SyncInventory();
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

        for (int index = 0; index < lowStockItems.length; index++)
          LowStocksWidget(
            // url: lowStockItems[index]['image_url'],
            amountLeft:
                '${lowStockItems[index]['VOLUME LEFT']}  ${lowStockItems[index]['PRODUCT TYPE']} left',
            item: lowStockItems[index]['NAME'],
            percentage: double.parse(lowStockItems[index]['VOLUME LEFT']) /
                double.parse(lowStockItems[index]['VOLUME PURCHASED']),
            text:
                '${calculateDaysUntilRunOut(double.parse(lowStockItems[index]['VOLUME LEFT']), int.parse(lowStockItems[index]['shelf_life'])).toString()} days runway',
          ),
        // SizedBox(
        //   height: 9.h * lowStockItems.length,
        //   child:
        //   FutureBuilder(
        //     future: _getStockData(),
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Center(
        //           child: CircularProgressIndicator(),
        //         ); // Show loading indicator while fetching data
        //       }
        //       if (snapshot.hasError) {
        //         return Text('Error: ${snapshot.error}');
        //       }
        //       return ListView.builder(
        //         physics: NeverScrollableScrollPhysics(),
        //         itemCount: lowStockItems.length,
        //         itemBuilder: (context, index) {
        //           int daysLeft = calculateDaysUntilRunOut(
        //               double.parse(lowStockItems[index]['VOLUME LEFT']),
        //               int.parse(lowStockItems[index]['shelf_life']));
        //           double percentage = double.parse(
        //                   lowStockItems[index]['VOLUME LEFT']) /
        //               double.parse(lowStockItems[index]['VOLUME PURCHASED']);
        //           print('item $index : $percentage');
        //           return LowStocksWidget(
        //             amountLeft:
        //                 '${lowStockItems[index]['VOLUME LEFT']}  ${lowStockItems[index]['PRODUCT TYPE']} left',
        //             item: lowStockItems[index]['NAME'],
        //             percentage: percentage,
        //             text: '${daysLeft.toString()} days runway',
        //           );
        //         },
        //       );
        //     },
        //   ),
        // ),
        Space(3.h),
        Row(
          children: [
            BoldTextWidgetHomeScreen(
              txt: 'Stocks near expiry',
            ),
            Spacer(),
            SeeAllWidget(),
          ],
        ),
        FutureBuilder(
            future: null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int index = 0; index < 10; index++)
                      StocksNearExpiryWidget(),
                  ],
                ),
              );
            }),
        Space(2.h),
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
                    Space(2.h),
                    AppWideButton(
                        onTap: () async {
                          final newData = await SyncInventory();
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

class StocksNearExpiryWidget extends StatelessWidget {
  const StocksNearExpiryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 120,
      width: 90,
      decoration: ShapeDecoration(
        shadows: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(124, 193, 191, 0.3),
            blurRadius: 15 + 5,
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
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Space(3),
        Container(
          height: 75,
          width: 73,
          decoration: ShapeDecoration(
            shadows: const [
              BoxShadow(
                offset: Offset(0, 4),
                color: Color.fromRGBO(124, 193, 191, 0.3),
                blurRadius: 15 + 5,
              )
            ],
            color: Color.fromRGBO(200, 233, 233, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
        ),
        Space(5),
        Text(
          'Chicken',
          style: TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0,
            letterSpacing: 0.12,
          ),
        ),
        Text(
          '15.3 kg',
          style: TextStyle(
            color: Color(0xFFFA6E00),
            fontSize: 9,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w400,
            height: 0,
            letterSpacing: 0.09,
          ),
        )
      ]),
    );
  }
}

class LowStocksWidget extends StatelessWidget {
  double percentage;
  String text;
  String amountLeft;
  String item;
  // String url;
  LowStocksWidget({
    super.key,
    required this.amountLeft,
    required this.text,
    required this.percentage,
    required this.item,
    // required this.url,
  });

  @override
  Widget build(BuildContext context) {
    Color color = percentage < 0.1
        ? Color(0xFFF54B4B)
        : percentage < 0.2
            ? Color(0xFFFA6E00)
            : percentage < 0.3
                ? Color.fromARGB(255, 237, 172, 123)
                : Color(0xFF8EE239);

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
            ),
            // child: Image.network(url),
          ),
          Space(isHorizontal: true, 3.w),
          SizedBox(
            width: 20.w,
            child: Text(
              item,
              style: TextStyle(
                color: Color(0xFF0A4C61),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0.05,
                letterSpacing: 0.14,
              ),
            ),
          ),
          Space(isHorizontal: true, 7.w),
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
                width: 50.w,
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
                  color: color,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                width: percentage < 0.1
                    ? 50.w * percentage + 7.w
                    : percentage < 0.2
                        ? 50.w * percentage + 5.w
                        : 50.w * percentage,
              ),
              Positioned(
                  left: 5,
                  top: 5,
                  child: Text(
                    amountLeft,
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
                    text,
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
  String txt;
  StocksMayBeNeedWidget({super.key, this.txt = 'chicken'});

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
            txt,
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
