// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
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
  void _launchURL(String url) async {
    Uri googleSheetUrl = Uri.parse(url);
    if (!await launchUrl(googleSheetUrl, mode: LaunchMode.inAppBrowserView)) {
      TOastNotification().showErrorToast(context, 'Error while opening Sheet');
      throw Exception('Could not launch $url');
    }
  }

  // bool _isSyncLoading = false;
  List<dynamic> lowStockItems = [];
  List<dynamic> allStocks = [];
  List<dynamic> nearExpiryItems = [];
  List<dynamic> stocksYouMayNeed = [];
  bool _isUpdateLoading = false;
  Future<void> _getLowStockData() async {
    lowStockItems = [];

    final data = await getInventoryData();

    lowStockItems = findLowStockItems(data['data'][0]['inventory_data']);
    print(lowStockItems);
    lowStockItems.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      if (runwayComparison != 0) {
        return runwayComparison;
      } else {
        return a['VOLUME LEFT'].compareTo(b['VOLUME LEFT']);
      }
    });
  }

  Future<void> _getStocksYouMayNeed() async {
    stocksYouMayNeed = [];

    final data = await getInventoryData();

    stocksYouMayNeed = data['data'][0]['inventory_data'];

    List<dynamic> temp = [];
    stocksYouMayNeed.forEach((element) {
      if (element['shelf_life'] != null) {
        element['runway'] = calculateDaysUntilRunOut(element['PURCHASE DATE'],
            int.parse(element['shelf_life']), element['EXP DATE']);
        temp.add(element);
      }
    });
    stocksYouMayNeed = temp;

    stocksYouMayNeed.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      if (runwayComparison != 0) {
        return runwayComparison;
      } else {
        return a['VOLUME LEFT'].compareTo(b['VOLUME LEFT']);
      }
    });
    allStocks.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      if (runwayComparison != 0) {
        return runwayComparison;
      } else {
        return a['VOLUME LEFT'].compareTo(b['VOLUME LEFT']);
      }
    });
  }

  Future<void> _getNearExpiryStocks() async {
    nearExpiryItems = [];
    dynamic data = await getInventoryData();
    print(data);
    final int thresholdDays = 3;
    final currentDate = DateTime.now();
    final dateFormat = DateFormat('dd-MM-yyyy');

    data = data['data'][0]['inventory_data'];
    data.forEach((item) {
      if (item['shelf_life'] != null) {
        var daysUntilExpiry;
        var expiryDate;
        if (item['EXP DATE'] != '-' && item['EXP DATE'].isNotEmpty) {
          expiryDate = dateFormat.parse(item['EXP DATE']);
        } else {
          expiryDate =
              currentDate.add(Duration(days: int.parse(item['shelf_life'])));
        }
        daysUntilExpiry = expiryDate.difference(currentDate).inDays;
        if (daysUntilExpiry <= thresholdDays) {
          item['runway'] = calculateDaysUntilRunOut(
            item['PURCHASE DATE'],
            int.parse(item['shelf_life']),
            item['EXP DATE'],
          );
          nearExpiryItems.add(item);
        }
      }
    });

    nearExpiryItems.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      return runwayComparison;
    });
  }

  List<dynamic> findLowStockItems(List<dynamic> inventoryData) {
    List<dynamic> lowstocks = [];
    allStocks = [];
    for (var item in inventoryData) {
      if (item['shelf_life'] != null) {
        double volumeLeft = double.parse(item['VOLUME LEFT']);
        item['runway'] = calculateDaysUntilRunOut(
          item['PURCHASE DATE'],
          int.parse(item['shelf_life']),
          item['EXP DATE'] ?? '-',
        );

        if (volumeLeft / double.parse(item['VOLUME PURCHASED']) <= 0.3) {
          lowstocks.add(item);
        }
        allStocks.add(item);
      }
    }

    return lowstocks;
  }

  int calculateDaysUntilRunOut(
      String purchaseDateStr, int shelfLife, String expiry) {
    DateTime currentDate = DateTime.now();
    if (expiry == '-') {
      final DateFormat dateFormat = DateFormat("dd-MM-yyyy");
      DateTime purchaseDate = dateFormat.parse(purchaseDateStr);

      DateTime expirationDate = purchaseDate.add(Duration(days: shelfLife));
      int daysUntilRunOut = expirationDate.difference(currentDate).inDays;
      return daysUntilRunOut + 1;
    } else {
      DateTime expirationDate = DateFormat('dd-MM-yyyy').parse(expiry);
      int daysUntilRunOut = expirationDate.difference(currentDate).inDays;

      return daysUntilRunOut + 1;
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
                AppWideLoadingBanner().loadingBanner(context);
                final data = await getSheetUrl();
                Navigator.of(context).pop();
                _launchURL(data['sheet_url']);
              },
            ),
            TouchableOpacity(
              onTap: () async {
                AppWideLoadingBanner().loadingBanner(context);
                final newData = await SyncInventory();
                Navigator.of(context).pop();
                if (newData['data'] != null) {
                  TOastNotification().showSuccesToast(context, 'List Synced!');
                }
              },
              child: Icon(Icons.refresh),
            ),
            _isUpdateLoading
                ? SizedBox(
                    width: 30.w,
                    height: 5.h,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Make_Update_ListWidget(
                    txt: 'Update List',
                    onTap: () async {
                      AppWideLoadingBanner().loadingBanner(context);
                      // if (_isUpdateLoading)
                      //   AppWideLoadingBanner().loadingBanner(context);
                      final data = await getInventoryData();
                      Navigator.of(context).pop();
                      setState(() {
                        _isUpdateLoading = false;
                      });
                      if ((data['data'] as List<dynamic>).length != 0) {
                        UpdateListBottomSheet(
                            context, data['data'][0]['inventory_data']);
                      }
                      // print(data);
                    },
                  ),
          ],
        ),
        Space(3.h),
        Row(
          children: [
            const BoldTextWidgetHomeScreen(
              txt: 'Stocks you may need',
            ),
            Spacer(),
            TouchableOpacity(
                onTap: () {
                  AppWideBottomSheet().showSheet(
                      context,
                      // Container(),
                      Column(
                        children: [
                          const BoldTextWidgetHomeScreen(
                            txt: 'Stocks you may need',
                          ),
                          Space(2.h),
                          SizedBox(
                            width: double.infinity,
                            child: GridView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable scrolling
                              shrinkWrap:
                                  true, // Allow the GridView to shrink-wrap its content
                              addAutomaticKeepAlives: true,

                              padding: EdgeInsets.symmetric(
                                  vertical: 0.8.h, horizontal: 3.w),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 0.8,
                                crossAxisCount: 4, // Number of items in a row
                                crossAxisSpacing:
                                    4.w, // Spacing between columns
                                mainAxisSpacing: 1.5.h, // Spacing between rows
                              ),
                              itemCount:
                                  allStocks.length, // Total number of items
                              itemBuilder: (context, index) {
                                // You can replace this container with your custom item widget
                                return StocksMayBeNeedWidget(
                                    txt: allStocks[index]['NAME'],
                                    url: allStocks[index]['image_url'] ?? '');
                              },
                            ),
                          ),
                        ],
                      ),
                      60.h);
                },
                child: const SeeAllWidget()),
          ],
        ),
        Space(2.h),
        FutureBuilder(
            future: _getStocksYouMayNeed(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(stocksYouMayNeed.isEmpty
                      ? 'No Item in Inventory'
                      : 'Error happend while fetching data , try again later !'),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int index = 0;
                        index <
                            (stocksYouMayNeed.length > 5
                                ? 5
                                : stocksYouMayNeed.length);
                        index++)
                      StocksMayBeNeedWidget(
                        txt: stocksYouMayNeed[index]['NAME'],
                        url: stocksYouMayNeed[index]['image_url'] ?? '',
                      ),
                  ],
                ),
              );
            }),
        // Space(2.h),
        // Center(
        //   child: ButtonWidgetHomeScreen(
        //     width: 33.w,
        //     txt: 'Add to cart',
        //     isActive: true,
        //   ),
        // ),
        Space(3.h),
        Row(
          children: [
            BoldTextWidgetHomeScreen(
              txt: 'Low stocks',
            ),
            Spacer(),
            TouchableOpacity(
                onTap: () {
                  AppWideBottomSheet().showSheet(
                      context,
                      // Container(),
                      Column(
                        children: [
                          BoldTextWidgetHomeScreen(
                            txt: 'Low stocks',
                          ),
                          Space(2.h),
                          Container(
                            width: double.infinity,
                            child: ListView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable scrolling
                              shrinkWrap:
                                  true, // Allow the GridView to shrink-wrap its content
                              addAutomaticKeepAlives: true,

                              padding: EdgeInsets.symmetric(
                                  vertical: 0.8.h, horizontal: 3.w),

                              itemCount: allStocks.length,
                              itemBuilder: (context, index) {
                                int runway = allStocks[index]['runway'];

                                return LowStocksWidget(
                                    isSheet: true,
                                    amountLeft:
                                        '${allStocks[index]['VOLUME LEFT']}  ${allStocks[index]['PRODUCT TYPE']} left',
                                    item: allStocks[index]['NAME'],
                                    percentage: double.parse(
                                            allStocks[index]['VOLUME LEFT']) /
                                        double.parse(allStocks[index]
                                            ['VOLUME PURCHASED']),
                                    text: runway < 0
                                        ? 'Expired'
                                        : '${runway} days runway',
                                    url: allStocks[index]['image_url'] ?? '');
                              },
                            ),
                          ),
                        ],
                      ),
                      60.h);
                },
                child: SeeAllWidget()),
          ],
        ),
        Space(2.h),
        SizedBox(
          child: FutureBuilder(
            future: _getLowStockData(),
            builder: (context, snapshot) {
              print(lowStockItems.length == 0);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(lowStockItems.length == 0
                      ? 'No Item in Inventory'
                      : 'Error happend while fetching data , try again later !'),
                );
              } else {
                if (lowStockItems.length == 0)
                  return Center(
                    child: Text('No Item in Low Stocks'),
                  );
                else {
                  return Container(
                    child: Column(
                      children: List.generate(
                          lowStockItems.length > 5 ? 5 : lowStockItems.length,
                          (index) {
                        int runway = lowStockItems[index]['runway'];
                        return LowStocksWidget(
                          // url: lowStockItems[index]['image_url'],
                          amountLeft:
                              '${lowStockItems[index]['VOLUME LEFT']}  ${lowStockItems[index]['PRODUCT TYPE']} left',
                          item: lowStockItems[index]['NAME'],
                          percentage: double.parse(
                                  lowStockItems[index]['VOLUME LEFT']) /
                              double.parse(
                                  lowStockItems[index]['VOLUME PURCHASED']),
                          text:
                              runway < 0 ? 'Expired' : '${runway} days runway',
                          url: lowStockItems[index]['image_url'] ?? '',
                        );
                      }),
                    ),
                  );
                }
              }
            },
          ),
        ),
        Space(2.h),
        Row(
          children: [
            BoldTextWidgetHomeScreen(
              txt: 'Stocks near expiry',
            ),
            Spacer(),
            TouchableOpacity(
                onTap: () {
                  AppWideBottomSheet().showSheet(
                      context,
                      // Container(),
                      Column(
                        children: [
                          BoldTextWidgetHomeScreen(
                            txt: 'Stocks near expiry',
                          ),
                          Space(2.h),
                          Container(
                            width: double.infinity,
                            child: GridView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable scrolling
                              shrinkWrap:
                                  true, // Allow the GridView to shrink-wrap its content
                              addAutomaticKeepAlives: true,

                              padding: EdgeInsets.symmetric(
                                  vertical: 0.8.h, horizontal: 3.w),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 0.7,
                                crossAxisCount: 3, // Number of items in a row
                                crossAxisSpacing:
                                    4.w, // Spacing between columns
                                mainAxisSpacing: 1.5.h, // Spacing between rows
                              ),
                              itemCount: nearExpiryItems
                                  .length, // Total number of items
                              itemBuilder: (context, index) {
                                // You can replace this container with your custom item widget
                                return StocksNearExpiryWidget(
                                  name: nearExpiryItems[index]['NAME'],
                                  volume: nearExpiryItems[index]
                                          ['VOLUME LEFT'] +
                                      ' ' +
                                      nearExpiryItems[index]['PRODUCT TYPE'],
                                  url:
                                      nearExpiryItems[index]['image_url'] ?? '',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      60.h);
                },
                child: SeeAllWidget()),
          ],
        ),
        Space(2.h),
        FutureBuilder(
            future: _getNearExpiryStocks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(nearExpiryItems.length == 0
                      ? 'No Item in Inventory'
                      : 'Error happend while fetching data , try again later !'),
                );
              } else {
                if (nearExpiryItems.length == 0)
                  return Center(
                    child: Text('No Near Expiring Items in Your Inventory'),
                  );
                else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int index = 0;
                            index <
                                (nearExpiryItems.length > 5
                                    ? 5
                                    : nearExpiryItems.length);
                            index++)
                          StocksNearExpiryWidget(
                            name: nearExpiryItems[index]['NAME'],
                            volume: nearExpiryItems[index]['VOLUME LEFT'] +
                                ' ' +
                                nearExpiryItems[index]['PRODUCT TYPE'],
                            url: nearExpiryItems[index]['image_url'] ?? '',
                          ),
                      ],
                    ),
                  );
                }
              }
            }),
        Space(2.h),
      ],
    );
  }

  Future<dynamic> UpdateListBottomSheet(BuildContext context, dynamic data) {
    // dynamic UiData = data;
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
                    const Divider(
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
                          txt: 'Vol left',
                          width: 20.w,
                        ),
                      ],
                    ),
                    Space(1.h),
                    const Divider(
                      color: Color(0xFFFA6E00),
                    ),
                    Space(2.h),
                    Container(
                      height: 60.h,
                      // ma: EdgeInsets.symmetric(vertical: 6.h),
                      child: ListView.builder(
                        itemCount: (data as List<dynamic>).length,
                        itemBuilder: (context, index) {
                          return BottomSheetRowWidget(
                              id: data[index]['ID'],
                              name: data[index]['NAME'],
                              price: data[index]['TOTAL PRICE( Rs)'] ?? '-',
                              volume: data[index]['VOLUME LEFT'] ?? '-',
                              type: data[index]['PRODUCT TYPE']);
                        },
                      ),
                    ),
                    Space(2.h),
                    AppWideButton(
                        onTap: () async {
                          AppWideLoadingBanner().loadingBanner(context);
                          final newData = await SyncInventory();
                          Navigator.of(context).pop();
                          setState(() {
                            data = newData['data']['inventory_data'];
                            // print('ui');
                            // print(UiData);
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
  String name;
  String volume;
  String url;
  StocksNearExpiryWidget({
    super.key,
    required this.name,
    required this.volume,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    String newUrl = '';
    if (url != '') {
      String originalLink = url;
      String fileId = originalLink.substring(
          originalLink.indexOf('/d/') + 3, originalLink.indexOf('/view'));
      newUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
    }
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
        const Space(3),
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
            color: const Color.fromRGBO(200, 233, 233, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: newUrl != ''
              ? ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                  child: Image(
                    fit: BoxFit.cover,
                    image: NetworkImage(newUrl),
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Error loading image'),
                      );
                    },
                  ),
                )
              : null,
        ),
        const Space(5),
        Text(
          name,
          maxLines: 2,
          style: const TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0,
            letterSpacing: 0.12,
          ),
        ),
        Text(
          volume,
          style: const TextStyle(
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
  bool isSheet;
  String url;
  // String url;
  LowStocksWidget({
    super.key,
    required this.amountLeft,
    required this.text,
    required this.percentage,
    required this.item,
    this.isSheet = false,
    required this.url,
    // required this.url,
  });

  @override
  Widget build(BuildContext context) {
    String newUrl = '';
    if (url != '') {
      String originalLink = url;
      String fileId = originalLink.substring(
          originalLink.indexOf('/d/') + 3, originalLink.indexOf('/view'));
      newUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    print(newUrl);

    double widhth = !isSheet ? 50.w : 40.w;
    Color color = percentage < 0.1
        ? const Color(0xFFF54B4B)
        : percentage < 0.2
            ? const Color(0xFFFA6E00)
            : percentage < 0.3
                ? const Color.fromARGB(255, 237, 172, 123)
                : const Color(0xFF8EE239);

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
              color: const Color.fromRGBO(200, 233, 233, 1),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 10,
                  cornerSmoothing: 1,
                ),
              ),
            ),
            // child: Image.network(url),
            child: newUrl != ''
                ? ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                    child: Image(
                      fit: BoxFit.cover,
                      image: NetworkImage(newUrl),
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Error loading image'),
                        );
                      },
                    ),
                  )
                : null,
          ),
          Space(isHorizontal: true, 3.w),
          SizedBox(
            width: 20.w,
            child: Text(
              item,
              style: const TextStyle(
                color: Color(0xFF0A4C61),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0.05,
                letterSpacing: 0.14,
              ),
            ),
          ),
          !isSheet
              ? Space(isHorizontal: true, 7.w)
              : Space(isHorizontal: true, 2.w),
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
                  color: const Color.fromRGBO(223, 244, 248, 1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                width: widhth,
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
                  color: text == 'Expired' ? Colors.red : color,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                width: percentage < 0.1
                    ? widhth * percentage + 7.w
                    : percentage < 0.2
                        ? widhth * percentage + 5.w
                        : widhth * percentage,
              ),
              Positioned(
                  left: 5,
                  top: 5,
                  child: Text(
                    amountLeft,
                    style: const TextStyle(
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
                    style: const TextStyle(
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
  String url;
  String txt;
  StocksMayBeNeedWidget({super.key, this.txt = 'chicken', this.url = ''});

  @override
  Widget build(BuildContext context) {
    String newUrl = '';
    if (url != '') {
      String originalLink = url;
      String fileId = originalLink.substring(
          originalLink.indexOf('/d/') + 3, originalLink.indexOf('/view'));
      newUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
    }
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
              color: const Color.fromRGBO(200, 233, 233, 1),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 10,
                  cornerSmoothing: 1,
                ),
              ),
            ),
            child: url != ''
                ? ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                    child: Image(
                      fit: BoxFit.cover,
                      image: NetworkImage(newUrl),
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Error loading image'),
                        );
                      },
                    ),
                  )
                : null,
          ),
          Space(1.h),
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
        const Text(
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
        const Icon(
          Icons.arrow_forward_ios,
          size: 13,
          color: Color(0xFFFA6E00),
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
              style: const TextStyle(
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
              style: const TextStyle(
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
              style: const TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                height: 0.13,
              ),
            ),
          ),
          Container(
            width: 20.w,
            child: Text(
              volume + ' ' + type,
              style: const TextStyle(
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
        style: const TextStyle(
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
            color: const Color.fromRGBO(84, 166, 193, 1),
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
              style: const TextStyle(
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
