// ignore_for_file: must_be_immutable, use_build_context_synchronously, unused_field, unused_local_variable

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/bellyMart_sheet.dart';
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
    nearExpiryItems = [];
    _setWebviewController(temp);
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    nearExpiryItems = [];

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
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
        'email':
            Provider.of<Auth>(context, listen: false).userData?['user_email'],
        'item_id': '1',
      },
    });

    String token = payload.sign(SecretKey(METABASE_SECRET_KEY));

    String iframeUrl =
        '$METABASE_SITE_URL/embed/dashboard/$token#bordered=true&titled=false';

    return iframeUrl;
  }

  Future<void> _getLowStockData() async {
    lowStockItems = [];

    final data =
        await Provider.of<Auth>(context, listen: false).getInventoryData();

    lowStockItems = findLowStockItems(data['inventory_data']);

    lowStockItems.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      if (runwayComparison != 0) {
        return runwayComparison;
      } else {
        return a['volumeLeft'].compareTo(b['volumeLeft']);
      }
    });
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
        _somethingmissing = true;
      }

      if (element['shelf_life'] != null &&
          element['volumeLeft'] != null &&
          element['purchaseDate'] != null &&
          element['volumePurchased'] != null) {
        element['runway'] = calculateDaysUntilRunOut(
            element['purchaseDate'], int.parse(element['shelf_life']));
        temp.add(element);
      }
    });

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
  }

  Future<void> _getNearExpiryStocks() async {
    nearExpiryItems = [];

    dynamic data =
        await Provider.of<Auth>(context, listen: false).getInventoryData();
    log("data:: $data");

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

        if (daysUntilExpiry <= thresholdDays) {
          item['runway'] = calculateDaysUntilRunOut(
            item['purchaseDate'],
            int.parse(item['shelf_life']),
          );
          print("nearExpiryItems:: ${nearExpiryItems.length}");

          if (!nearExpiryItems
              .any((element) => element['itemId'] == item['itemId'])) {
            nearExpiryItems.add(item);
            print("nearExpiryItems:: ${nearExpiryItems.length}");
          }

          nearExpiryItems =
              allStocks.where((element) => element['runway'] < 0).toList();
        }
      }
    });

    nearExpiryItems.sort((a, b) {
      int runwayComparison = a['runway'].compareTo(b['runway']);
      return runwayComparison;
    });
  }

  List<dynamic> findLowStockItems(List<dynamic> inventoryData) {
    List<dynamic> lowStocks = [];
    allStocks = [];
    DateTime today = DateTime.now();

    for (var item in inventoryData) {
      if (item['shelf_life'] != null &&
          item['volumeLeft'] != null &&
          item['purchaseDate'] != null &&
          item['volumePurchased'] != null) {
        double volumeLeft = double.parse(item['volumeLeft']);
        double volumePurchased = double.parse(item['volumePurchased']);
        int shelfLife = int.parse(item['shelf_life']);
        DateTime purchaseDate = DateTime.parse(item['purchaseDate']);
        int daysSincePurchase = today.difference(purchaseDate).inDays;

        int runway = calculateDaysUntilRunOut(
          item['purchaseDate'],
          int.parse(item['shelf_life']),
        );
        item['runway'] = runway;

        double lowStockThreshold;
        if (shelfLife > 30) {
          lowStockThreshold = 0.3;
        } else {
          lowStockThreshold = 0.5;
        }

        if (volumeLeft / volumePurchased < lowStockThreshold) {
          lowStocks.add(item);
        }
        allStocks.add(item);
      }
    }

    print("lowStocks:: ${allStocks.length}");

    return lowStocks;
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
    List<dynamic> dataList = [];
    print('all: $allStocks');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Manage your inventory",
            style: TextStyle(
              color: Color.fromRGBO(10, 76, 97, 1),
              fontSize: 20,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
              height: 0,
              letterSpacing: 0.14,
            ),
          ),
        ),
        const Space(14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Make_Update_ListWidget(
              txt: 'Make List',
              onTap: () async {
                AppWideLoadingBanner().loadingBanner(context);
                final _data = await Provider.of<Auth>(context, listen: false)
                    .getInventoryData();
                Navigator.of(context).pop();
                dataList = _data['inventory_data'] ?? [];
                makeListSheet().bottomSheet(context, dataList).then((value) {
                  setState(() {});
                });
              },
            ),
            const Space(
              25,
              isHorizontal: true,
            ),
            _isUpdateLoading
                ? SizedBox(
                    width: 30.w,
                    height: 5.h,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Make_Update_ListWidget(
                    txt: 'BellyMart',
                    color: const Color.fromRGBO(10, 76, 97, 1),
                    onTap: () async {
                      context.read<TransitionEffect>().setBlurSigma(5.0);
                      BellyMartBottomSheet().BellyMartSheet(context);
                      /*AppWideLoadingBanner().loadingBanner(context);

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

                        _dataList
                            .sort((a, b) => a["itemId"].compareTo(b["itemId"]));

                        InventoryBottomSheets()
                            .UpdateListBottomSheet(context, _dataList);
                      }*/
                    },
                  ),
          ],
        ),

        // Space(3.h),
        // Center(
        //   child: Make_Update_ListWidget(
        //     txt: 'KPI',
        //     onTap: () async {
        //       if (allStocks.length == 0) {
        //         TOastNotification()
        //             .showErrorToast(context, 'No Item in inventory for KIP');
        //       } else {
        //         Navigator.of(context)
        //             .pushNamed(GraphsScreen.routeName, arguments: {
        //           'items': allStocks,
        //         });
        //       }
        //     },
        //   ),
        // ),
        Space(3.h),
        Row(
          children: [
            const BoldTextWidgetHomeScreen(
              txt: 'Stocks you may need',
            ),
            const Spacer(),
            TouchableOpacity(
                onTap: () {
                  return StockYouMayNeedSheet(context);
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
            const BoldTextWidgetHomeScreen(
              txt: 'Low stocks',
            ),
            const Spacer(),
            TouchableOpacity(
                onTap: () {
                  print("allStocksItem :: $allStocks");
                  return LowStocksSheet(context);
                },
                child: const SeeAllWidget()),
          ],
        ),
        Space(2.h),
        SizedBox(
          child: FutureBuilder(
            future: _getLowStockData(),
            builder: (context, snapshot) {
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
                  return const Center(
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
            const BoldTextWidgetHomeScreen(
              txt: 'Stocks near expiry',
            ),
            const Spacer(),
            TouchableOpacity(
                onTap: () {
                  /* var tempList = allStocks.where((element) => element['runway'] <0).toList();
                  setState(() {
                    nearExpiryItems.add(tempList);
                  });*/
                  print(
                      "stocks near:: ${allStocks.where((element) => element['runway'] < 0).toList()}");
                  StockNearExpirySheet(context);
                },
                child: const SeeAllWidget()),
          ],
        ),
        Space(2.h),
        FutureBuilder(
            future: _getNearExpiryStocks(),
            builder: (context, snapshot) {
              var tempList = stocksYouMayNeed
                  .where((element) => element['runway'] < 0)
                  .toList();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(tempList.length == 0
                      ? 'No Item in Inventory'
                      : 'Error happend while fetching data , try again later !'),
                );
              } else {
                if (tempList.length == 0)
                  return const Center(
                    child: Text('No Near Expiring Items in Your Inventory'),
                  );
                else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int index = 0;
                            index < (tempList.length > 5 ? 5 : tempList.length);
                            index++)
                          StocksNearExpiryWidget(
                            name: tempList[index]['itemName'],
                            volume: tempList[index]['volumeLeft'] +
                                ' ' +
                                tempList[index]['unitType'],
                            url: tempList[index]['image_url'] ?? '',
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

  Future<void> StockNearExpirySheet(BuildContext context) {
    var tempList = allStocks.where((element) => element['runway'] < 0).toList();
    return AppWideBottomSheet().showSheet(
        context,
        // Container(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: const BoldTextWidgetHomeScreen(
                txt: 'Stocks near expiry',
              ),
            ),
            Space(2.h),
            tempList.isNotEmpty
                ? Container(
                    width: double.infinity,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      addAutomaticKeepAlives: true,
                      padding: EdgeInsets.symmetric(
                          vertical: 0.8.h, horizontal: 3.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.7,
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 1.5.h,
                      ),
                      itemCount: tempList.length ?? 1,
                      itemBuilder: (context, index) {
                        print("nearstocksExpire:: ${tempList.length}");
                        return StocksNearExpiryWidget(
                          name: tempList[index]['itemName'],
                          volume: tempList[index]['volumeLeft'] +
                              ' ' +
                              tempList[index]['unitType'],
                          url: tempList[index]['image_url'] ?? '',
                        );
                      },
                    ),
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text('No Near Expiring Items in Your Inventory'),
                      ),
                    ],
                  ),
          ],
        ),
        60.h);
  }

  Future<dynamic> LowStocksSheet(BuildContext context) {
    return showModalBottomSheet(
      // useSafeArea: true,
      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
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
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                padding: EdgeInsets.only(
                    left: 6.w,
                    right: 6.w,
                    top: 2.h,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            height: 6,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFA6E00),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                      Space(2.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BoldTextWidgetHomeScreen(
                            txt: 'Low stocks',
                          ),
                          Space(1.h),
                          Container(
                            width: double.infinity,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              // Disable scrolling
                              shrinkWrap: true,
                              // Allow the GridView to shrink-wrap its content
                              addAutomaticKeepAlives: true,

                              padding: EdgeInsets.symmetric(
                                  vertical: 0.8.h, horizontal: 0),

                              itemCount: allStocks.length,
                              itemBuilder: (context, index) {
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<dynamic> StockYouMayNeedSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            TextEditingController productController = TextEditingController();
            TextEditingController volumeController = TextEditingController();
            TextEditingController quantityController = TextEditingController();
            List<Map<String, dynamic>> stocksYouMayNeed = [
              {
                'itemName': 'Green cabbage',
                'image_url': '',
                'runway': 3,
                'volumeLeft': 5,
                'unitType': 'kg',
                'isAdding': false,
                'quantity': 0,
              },
              {
                'itemName': 'cabbage',
                'image_url': '',
                'runway': 5,
                'volumeLeft': 10,
                'unitType': 'kg',
                'isAdding': false,
                'quantity': 0,
              },
            ];

            void handleAddQuantity(int index) {
              setState(() {
                stocksYouMayNeed[index]['isAdding'] = true;
                quantityController.text =
                    stocksYouMayNeed[index]['quantity'].toString();
              });
            }

            void handleSaveQuantity(int index) {
              setState(() {
                stocksYouMayNeed[index]['quantity'] =
                    int.tryParse(quantityController.text) ?? 0;
                stocksYouMayNeed[index]['isAdding'] = false;
              });
            }

            void handleCancelQuantity(int index) {
              setState(() {
                stocksYouMayNeed[index]['isAdding'] = false;
              });
            }

            return SingleChildScrollView(
              child: Container(
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                      topLeft:
                          SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                      topRight:
                          SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                    ),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        width: 65,
                        height: 6,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFA6E00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Stocks you may need',
                      style: TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        for (int index = 0;
                            index < stocksYouMayNeed.length;
                            index++)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(children: [
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stocksYouMayNeed[index]['itemName'],
                                    style: const TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    stocksYouMayNeed[index]['runway'] < 0
                                        ? '${stocksYouMayNeed[index]['volumeLeft']} ${stocksYouMayNeed[index]['unitType']} left and expired 8 days before'
                                        : '${stocksYouMayNeed[index]['volumeLeft']} ${stocksYouMayNeed[index]['unitType']} for next ${stocksYouMayNeed[index]['runway']} days',
                                    style: const TextStyle(
                                      color: Color(0xFFFA6E00),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (stocksYouMayNeed[index]['isAdding'] ==
                                  true) ...[
                                Container(
                                  width: 50,
                                  height: 30,
                                  child: TextFormField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () {
                                    handleSaveQuantity(index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () {
                                    handleCancelQuantity(index);
                                  },
                                ),
                              ] else ...[
                                GestureDetector(
                                  onTap: () {
                                    handleAddQuantity(index);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromRGBO(84, 166, 193, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${stocksYouMayNeed[index]['quantity']} kg',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFFFA6E00)),
                                  onPressed: () {
                                    handleAddQuantity(index);
                                  },
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.orange),
                                onPressed: () {
                                  setState(() {
                                    stocksYouMayNeed.removeAt(index);
                                  });
                                },
                              ),
                            ]),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: productController,
                                      decoration: const InputDecoration(
                                        labelText: 'Name of the product',
                                      ),
                                    ),
                                    TextField(
                                      controller: volumeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Volume needed',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          stocksYouMayNeed.add({
                                            'itemName': productController.text,
                                            'image_url': '',
                                            'runway': 0,
                                            'volumeLeft': 0,
                                            'unitType': 'kg',
                                            'isAdding': false,
                                            'quantity': 0,
                                          });
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Add item'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Add Item'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle submit logic here
                      },
                      child: const Text('Submit'),
                    ),
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

class ImageWidgetInventory extends StatelessWidget {
  double height;
  String url;
  double radius;

  ImageWidgetInventory({
    super.key,
    required this.height,
    required this.url,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    String newUrl = '';
    if (url != '') {
      print(url);
      String originalLink = url;
      String fileId = originalLink.substring(
          originalLink.indexOf('/d/') + 3, originalLink.indexOf('/view'));
      newUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return Container(
      height: height,
      width: height,
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
            cornerRadius: radius,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: url != ''
          ? ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: radius,
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
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Error loading image'),
                  );
                },
              ),
            )
          : null,
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
        ImageWidgetInventory(height: 75, url: url, radius: 15),
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
          ImageWidgetInventory(height: 35, url: url, radius: 10),
          const Space(isHorizontal: true, 11),
          SizedBox(
            width: 20.w,
            child: Text(
              item,
              style: const TextStyle(
                color: Color(0xFF0A4C61),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w600,
                // height: 0.05,
                letterSpacing: 0.14,
              ),
            ),
          ),
          const Space(isHorizontal: true, 17),
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
  String icon;

  StocksMayBeNeedWidget(
      {super.key, this.txt = 'chicken', this.url = '', this.icon = ''});

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
            width:60,
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
            child: url != '' && icon == ''
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
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Error loading image'),
                        );
                      },
                    ),
                  )
                : url == '' && icon != ''
                    ? ClipSmoothRect(
  radius: SmoothBorderRadius(
    cornerRadius: 15,
    cornerSmoothing: 1,
  ),
  child: Container(
    child: Center(
      child: Container(
        width: 30,  // Half of the container width
        height: 30, // Half of the container height
        child: Image.asset(
          icon,
          fit: BoxFit.cover,
        ),
      ),
    ),
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
  Color? color;

  Make_Update_ListWidget({
    super.key,
    required this.txt,
    required this.onTap,
    this.color,
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
            color: color ?? const Color.fromRGBO(84, 166, 193, 1),
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
