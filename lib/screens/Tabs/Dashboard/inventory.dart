// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/graphs.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory_bottom_sheet.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/make_list_inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Inventory extends StatefulWidget {
  const Inventory({
    super.key,
  });

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  // bool _isSyncLoading = false;
  List<dynamic> lowStockItems = [];
  List<dynamic> allStocks = [];
  List<dynamic> nearExpiryItems = [];
  List<dynamic> stocksYouMayNeed = [];
  bool _isUpdateLoading = false;
  bool _somethingmissing = false;

  String iframeUrl = "";
  var _iframeController;

  @override
  void initState() {
    String temp = _generateTokenAndLaunchDashboard();
    _setWebviewController(temp);
    // TODO: implement initState
    super.initState();
  }

  void _setWebviewController(String url) {
    _iframeController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  String _generateTokenAndLaunchDashboard() {
    final String METABASE_SITE_URL = "https://metabase.cloudbelly.in";
    final String METABASE_SECRET_KEY =
        "efdd99d7d0b5d40cac89a83bf3a9c0ada50377c09b586d3aceb71078c1234b43";

    final payload = JWT({
      "resource": {"dashboard": 8},
      "params": {
        'email': Provider.of<Auth>(context, listen: false).user_email,
        'item_id': '1',
      },
    });

    String token = payload.sign(SecretKey(METABASE_SECRET_KEY));

    String iframeUrl =
        '$METABASE_SITE_URL/embed/dashboard/$token#bordered=true&titled=false';

    // print('iframe: $iframeUrl');

    return iframeUrl;
  }

  // void _launchURL(String url) async {
  //   Uri googleSheetUrl = Uri.parse(url);
  //   if (!await launchUrl(googleSheetUrl, mode: LaunchMode.inAppBrowserView)) {
  //     TOastNotification().showErrorToast(context, 'Error while opening Sheet');
  //     throw Exception('Could not launch $url');
  //   }
  // }

  Future<void> _getLowStockData() async {
    lowStockItems = [];

    final data =
        await Provider.of<Auth>(context, listen: false).getInventoryData();
    // print(data);
    lowStockItems = findLowStockItems(data['inventory_data']);

    // print(lowStockItems);
    lowStockItems.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      if (runwayComparison != 0) {
        return runwayComparison;
      } else {
        return a['volumeLeft'].compareTo(b['volumeLeft']);
      }
    });
    // lowStockItems = lowStockItems.sublist(0, 4).toList();
    print(lowStockItems);
    // print(lowStockItems);
  }

  Future<void> _getStocksYouMayNeed() async {
    stocksYouMayNeed = [];

    final data =
        await Provider.of<Auth>(context, listen: false).getInventoryData();

    stocksYouMayNeed = data['inventory_data'];
    _somethingmissing = false;
    List<dynamic> temp = [];
    stocksYouMayNeed.forEach((element) {
      if (element['shelf_life'] == null ||
          element['volumeLeft'] == null ||
          element['purchaseDate'] == null ||
          element['volumePurchased'] == null) {
        print(element);
        _somethingmissing = true;
      }
      // print('object: $_somethingmissing');
      if (element['shelf_life'] != null &&
          element['volumeLeft'] != null &&
          element['purchaseDate'] != null &&
          element['volumePurchased'] != null) {
        element['runway'] = calculateDaysUntilRunOut(
            element['purchaseDate'], int.parse(element['shelf_life']));
        temp.add(element);
      }
    });
    // print('something');
    if (_somethingmissing) {
      // print(_somethingmissing);
      TOastNotification()
          .showErrorToast(context, 'Some fields are missing in Sheet data');
    }
    stocksYouMayNeed = temp;

    stocksYouMayNeed.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      if (runwayComparison != 0) {
        return runwayComparison;
      } else {
        return a['volumeLeft'].compareTo(b['volumeLeft']);
      }
    });
    allStocks.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      if (runwayComparison != 0) {
        return runwayComparison;
      } else {
        return a['volumeLeft'].compareTo(b['volumeLeft']);
      }
    });
    // print('all: $allStocks');
  }

  Future<void> _getNearExpiryStocks() async {
    nearExpiryItems = [];
    dynamic data =
        await Provider.of<Auth>(context, listen: false).getInventoryData();
    // print(data);
    final int thresholdDays = 3;
    final currentDate = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    data = data['inventory_data'];
    data.forEach((item) {
      if (item['shelf_life'] != null &&
          item['volumeLeft'] != null &&
          item['purchaseDate'] != null &&
          item['volumePurchased'] != null) {
        var daysUntilExpiry;
        var expiryDate;

        expiryDate =
            currentDate.add(Duration(days: int.parse(item['shelf_life'])));

        daysUntilExpiry = expiryDate.difference(currentDate).inDays;
        // print(daysUntilExpiry);
        if (daysUntilExpiry <= thresholdDays) {
          item['runway'] = calculateDaysUntilRunOut(
            item['purchaseDate'],
            int.parse(item['shelf_life']),
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
      if (item['shelf_life'] != null &&
          item['volumeLeft'] != null &&
          item['purchaseDate'] != null &&
          item['volumePurchased'] != null) {
        // print(item);
        double volumeLeft = double.parse(item['volumeLeft']);
        item['runway'] = calculateDaysUntilRunOut(
          item['purchaseDate'],
          int.parse(item['shelf_life']),
        );

        if (volumeLeft / double.parse(item['volumePurchased']) <= 0.3) {}
        lowstocks.add(item);

        allStocks.add(item);
      }
    }
    // print(lowstocks);
    // print('all');/
    // print(allStocks);
    return lowstocks;
  }

  int calculateDaysUntilRunOut(String purchaseDateStr, int shelfLife) {
    DateTime currentDate = DateTime.now();

    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime purchaseDate = dateFormat.parse(purchaseDateStr);

    DateTime expirationDate = purchaseDate.add(Duration(days: shelfLife));
    int daysUntilRunOut = expirationDate.difference(currentDate).inDays;
    return daysUntilRunOut + 1;
  }

  @override
  Widget build(BuildContext context) {
    // print('iframeUrl: $iframeUrl');
    // print(_iframeController);/
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Space(5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MakeListInventoryButton(),
            // TouchableOpacity(
            //   onTap: () async {
            //     // AppWideLoadingBanner().loadingBanner(context);
            //     // final newData = await Provider.of<Auth>(context, listen: false)
            //     //     .SyncInventory();
            //     // Navigator.of(context).pop();
            //     // if (newData['data'] != null) {
            //     //   TOastNotification().showSuccesToast(context, 'List Synced!');
            //     // }
            //   },
            //   child: Icon(Icons.refresh),
            // ),
            _isUpdateLoading
                ? SizedBox(
                    width: 30.w,
                    height: 5.h,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Make_Update_ListWidget(
                    txt: 'Preview List',
                    onTap: () async {
                      AppWideLoadingBanner().loadingBanner(context);

                      final data =
                          await Provider.of<Auth>(context, listen: false)
                              .getInventoryData();
                      Navigator.of(context).pop();
                      setState(() {
                        _isUpdateLoading = false;
                      });

                      if ((data['inventory_data'] as List<dynamic>).length !=
                          0) {
                        List<dynamic> _dataList = data['inventory_data'];
                        // print(_dataList);
                        _dataList
                            .sort((a, b) => a["itemId"].compareTo(b["itemId"]));
                        // print('object: ${data['inventory_data']}');
                        InventoryBottomSheets()
                            .UpdateListBottomSheet(context, _dataList);
                      }
                      // print(data);
                    },
                  ),
          ],
        ),
        Space(3.h),
        Center(
          child: Make_Update_ListWidget(
            txt: 'KPI',
            onTap: () async {
              if (allStocks.length == 0) {
                TOastNotification()
                    .showErrorToast(context, 'No Item in inventory for KIP');
              } else {
                Navigator.of(context)
                    .pushNamed(GraphsScreen.routeName, arguments: {
                  'items': allStocks,
                });
              }
            },
          ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 4.w),
                            child: const BoldTextWidgetHomeScreen(
                              txt: 'Stocks you may need',
                            ),
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
                                    txt: allStocks[index]['itemName'],
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
                        txt: stocksYouMayNeed[index]['itemName'],
                        url: stocksYouMayNeed[index]['image_url'] ?? '',
                      ),
                  ],
                ),
              );
            }),

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 3.w),
                            child: BoldTextWidgetHomeScreen(
                              txt: 'Low stocks',
                            ),
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
                                // print('object');
                                print(allStocks[index]);
                                int runway = allStocks[index]['runway'];
                                return LowStocksWidget(
                                    isSheet: true,
                                    amountLeft:
                                        '${allStocks[index]['volumeLeft']}  ${allStocks[index]['unitType']} left',
                                    item: allStocks[index]['itemName'],
                                    percentage: double.parse(
                                            allStocks[index]['volumeLeft']) /
                                        double.parse(allStocks[index]
                                            ['volumePurchased']),
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
              // print(lowStockItems.length == 0);
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
                          lowStockItems.length > 4 ? 4 : lowStockItems.length,
                          (index) {
                        int runway = lowStockItems[index]['runway'];
                        return LowStocksWidget(
                          // url: lowStockItems[index]['image_url'],
                          amountLeft:
                              '${lowStockItems[index]['volumeLeft']}  ${lowStockItems[index]['unitType']} left',
                          item: lowStockItems[index]['itemName'],
                          percentage:
                              double.parse(lowStockItems[index]['volumeLeft']) /
                                  double.parse(
                                      lowStockItems[index]['volumePurchased']),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: BoldTextWidgetHomeScreen(
                              txt: 'Stocks near expiry',
                            ),
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
                                  name: nearExpiryItems[index]['itemName'],
                                  volume: nearExpiryItems[index]['volumeLeft'] +
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
                            name: nearExpiryItems[index]['itemName'],
                            volume: nearExpiryItems[index]['volumeLeft'] +
                                ' ' +
                                nearExpiryItems[index]['unitType'],
                            url: nearExpiryItems[index]['image_url'] ?? '',
                          ),
                      ],
                    ),
                  );
                }
              }
            }),

        Space(3.h),
      ],
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
    // print(newUrl);/

    double widhth = !isSheet ? 50.w : 40.w;
    Color color = percentage < 0.1
        ? const Color.fromRGBO(245, 75, 75, 1)
        : percentage < 0.2
            ? const Color.fromRGBO(250, 110, 0, 1)
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
                // height: 0.05,
                letterSpacing: 0.14,
              ),
            ),
          ),
          !isSheet
              ? Space(isHorizontal: true, 3.w)
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
                  left: 10,
                  top: 5,
                  child: Text(
                    amountLeft,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w700,
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
