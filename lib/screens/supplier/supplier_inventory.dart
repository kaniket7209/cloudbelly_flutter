
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../api_service.dart';
import '../../constants/globalVaribales.dart';
import '../../widgets/appwide_bottom_sheet.dart';
import '../../widgets/appwide_loading_bannner.dart';
import '../../widgets/space.dart';
import '../../widgets/touchableOpacity.dart';
import '../Tabs/Dashboard/dashboard.dart';
import '../Tabs/Dashboard/inventory_bottom_sheet.dart';
import '../Tabs/Dashboard/make_list_inventory.dart';
import 'components/components.dart';
import 'components/constants.dart';
class SupplierInventory extends StatefulWidget {
  const SupplierInventory({
    super.key,
  });

  @override
  State<SupplierInventory> createState() => _SupplierInventoryState();
}

class _SupplierInventoryState extends State<SupplierInventory> {
  // bool _isSyncLoading = false;
  List<dynamic> lowStockItems = [];
  List<dynamic> allStocks = [];
  List<dynamic> nearExpiryItems = [];
  List<dynamic> stocksYouMayNeed = [];
  bool _isUpdateLoading = false;
  bool _somethingmissing = false;
  late List<Map<String, dynamic>> bulkOrderItemsDummyData = [
    {
      'itemName': 'Tomato',
      'volume': '181',
      'imageUrl':
      'https://media.istockphoto.com/id/1450576005/photo/tomato-isolated-tomato-on-white-background-perfect-retouched-tomatoe-side-view-with-clipping.jpg?s=612x612&w=0&k=20&c=lkQa_rpaKpc-ELRRGobYVJH-eMJ0ew9BckCqavkSTA0='
    },
    {
      'itemName': 'Red Cabbage',
      'volume': '62',
      'imageUrl':
      'https://media.istockphoto.com/id/175433477/photo/red-cabbage-leaves.jpg?s=612x612&w=0&k=20&c=CVC-6nTaKtQ0Gw5l8Nk5aGb8oA47Ce6eba2qSYYauq0='
    },
    {
      'itemName': 'Potato',
      'volume': '105',
      'imageUrl':
      'https://dukaan.b-cdn.net/700x700/webp/upload_file_service/asg/7e813d1d-0eac-456f-ba82-4a6b81efa130/Potato.png'
    },
    {
      'itemName': 'Green Cabbage',
      'volume': '35',
      'imageUrl':
      'https://www.shutterstock.com/image-photo/cabbage-isolated-on-white-background-600nw-1556699831.jpg'
    },
    {
      'itemName': 'Karela',
      'volume': '120',
      'imageUrl':
      'https://lazyshoppy.com/cdn/shop/products/Bitter_melon_4f3277d7-4f06-4908-9768-b8baa2e78bfb.png?v=1643607808'
    },
    {
      'itemName': 'Brocolli',
      'volume': '50',
      'imageUrl':
      'https://cdn.pixabay.com/photo/2016/06/11/15/33/broccoli-1450274_640.png'
    },
    {
      'itemName': 'Carrot',
      'volume': '120',
      'imageUrl':
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrMKkDu9OSVJelgM1bSu08TvVJvp_ZtfBIdefBjqCRnA&s'
    },
  ];

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

  //region This section will build and populate data inside new bulk order section in Inventory tab
  Widget _bulkOrderSheetItem(){
    final ScrollController _controller = ScrollController();

    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 2.h),
      padding: EdgeInsets.only(
        top: 2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(
              cornerRadius: 35,
              cornerSmoothing: 1,
            ),
            topRight: SmoothRadius(
              cornerRadius: 35,
              cornerSmoothing: 1,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TouchableOpacity(
              onTap: () {
                context.read<TransitionEffect>().setBlurSigma(0);
                return Navigator.of(context).pop();
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 1.h,
                    horizontal: 3.w,
                  ),
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
            ),
            Space(1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              // crossAxisAlignment: CrossAxisAlignment,// Set mainAxisSize to min
              children: [
                const Text(
                  'Delivery route',
                  style: TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.14,
                    letterSpacing: 0.36,
                  ),
                ),
                Space(isHorizontal: true, 2.w),
                Icon(
                  Icons.double_arrow_outlined,
                  size: 16,
                  color: Color(0xFFFA6E00),
                ),
              ],
            ),
            Space(1.h),
            Row(
              children: [
                Space(
                  1.h,
                  isHorizontal: true,
                ),
                Text(
                  'New Bulk Order',
                  style: const TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 25,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w500,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                ),
              ],
            ),
            Container(
              height: 350,
              child: Scrollbar(
                interactive: true,
                thumbVisibility: true,
                // Set to true to always show scrollbar
                controller: _controller,
                // Pass the controller
                child: ListView.builder(
                  controller: _controller,
                  // Pass the controller to the ListView as well
                  itemCount: bulkOrderItemsDummyData.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        index==0? Space(2.h):SizedBox(),
                        BulkOrderSectionItem(
                            itemData:
                            bulkOrderItemsDummyData[index]),
                        index==0? Space(2.h):SizedBox(),
                        index>0?Space(2.h):SizedBox(),
                      ],
                    );
                  },
                ),
              ),
            ),
            Space(2.h),
            Center(
                child: Container(
                  height: 45,
                  margin: EdgeInsets.symmetric(horizontal: 1.h),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                          offset: Offset(5, 6),
                          spreadRadius: 0.1,
                          color: Color.fromRGBO(232, 128, 55, 0.5),
                          blurRadius: 10)
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
                        'Submit your bid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: 0.30,
                        ),
                      )),
                )),
            Space(1.h)
          ],
        ),
      ),
    );
  }
  //endregion

  //region This section will build and populate data inside modal buttom sheet for Bulk item view all
  Widget _bulkOrderSection(){

    return Container(
      margin: EdgeInsets.symmetric(vertical:1.h, horizontal: 1.h),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Bulk Order',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 25,
                        fontFamily: 'Jost',
                        fontWeight:
                        FontWeight.w500,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    ),
                    Text(
                      'To deliver by -24th May, 2024 by 12PM',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 11,
                        fontFamily:
                        'Product Sans',
                        fontWeight:
                        FontWeight.w200,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    ),
                  ],
                ),
                // Spacer(),
                TouchableOpacity(
                    onTap: () {
                      context.read<TransitionEffect>().setBlurSigma(5.0);
                      customButtomSheetSection(context,_bulkOrderSheetItem());
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.only(
                          top: 8.0),
                      child: Row(
                        children: [
                          const Text(
                            'See all',
                            style: TextStyle(
                              color: Color(
                                  0xFF094B60),
                              fontSize: 12,
                              fontFamily:
                              'Product Sans',
                              fontWeight:
                              FontWeight.w700,
                              // height: 0.14,
                              letterSpacing: 0.36,
                            ),
                          ),
                          Space(
                              isHorizontal: true,
                              2.w),
                          const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 13,
                            color:
                            Color(0xFFFA6E00),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Space(2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BulkOrderItem(
                itemData: {
                  'itemName': 'Green Cabbage',
                  'volume': '120',
                  'imageUrl':
                  'https://www.shutterstock.com/image-photo/cabbage-isolated-on-white-background-600nw-1556699831.jpg'
                },
              ),
              BulkOrderItem(
                itemData: {
                  'itemName': 'Tomato',
                  'volume': '120',
                  'imageUrl':
                  'https://media.istockphoto.com/id/1450576005/photo/tomato-isolated-tomato-on-white-background-perfect-retouched-tomatoe-side-view-with-clipping.jpg?s=612x612&w=0&k=20&c=lkQa_rpaKpc-ELRRGobYVJH-eMJ0ew9BckCqavkSTA0='
                },
              ),
              BulkOrderItem(
                itemData: {
                  'itemName': 'Red Cabbage',
                  'volume': '120',
                  'imageUrl':
                  'https://media.istockphoto.com/id/175433477/photo/red-cabbage-leaves.jpg?s=612x612&w=0&k=20&c=CVC-6nTaKtQ0Gw5l8Nk5aGb8oA47Ce6eba2qSYYauq0='
                },
              ),
              BulkOrderItem(
                itemData: {
                  'itemName': 'Potato',
                  'volume': '120',
                  'imageUrl':
                  'https://dukaan.b-cdn.net/700x700/webp/upload_file_service/asg/7e813d1d-0eac-456f-ba82-4a6b81efa130/Potato.png'
                },
              ),
            ],
          ),
          Space(2.h),
          Center(
              child:Container(
                height: 45,
                margin: EdgeInsets.symmetric(horizontal: 1.h),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                        offset: Offset(5, 6),
                        spreadRadius: 0.1,
                        color: Color.fromRGBO(232, 128, 55, 0.5),
                        blurRadius: 10)
                  ],
                  color:const Color.fromRGBO(250, 110, 0, 1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Center(
                    child: Text(
                      'Place your bid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: 0.30,
                      ),
                    )),
              )
          ),
          Space(1.h)
        ],
      ),
    );
  }
  //endregion

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
    stocksYouMayNeed = [


    ];

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
          if (!nearExpiryItems
              .any((element) => element['itemId'] == item['itemId'])) {
            nearExpiryItems.add(item);
          }
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

    print(allStocks.length);

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
        whiteCardSection(_bulkOrderSection()),
        Space(2.h),
        Center(child: Text(
          'Manage your inventory',
          style: const TextStyle(
            color: Color(0xFF094B60),
            fontSize: 20,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w500,
            // height: 0.06,
            letterSpacing: 0.54,
          ),
        )),
        Space(2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Supplier_Make_Update_ListWidget(
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
            _isUpdateLoading
                ? SizedBox(
              width: 30.w,
              height: 5.h,
              child: Center(child: CircularProgressIndicator()),
            )
                : Supplier_Make_Update_ListWidget(
              txt: 'Update List',
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

                  _dataList
                      .sort((a, b) => a["itemId"].compareTo(b["itemId"]));

                  InventoryBottomSheets()
                      .UpdateListBottomSheet(context, _dataList);
                }
              },
            ),
          ],
        ),
        Space(3.h),
        Space(3.h),
        Row(
          children: [
            const BoldTextWidgetHomeScreen(
              txt: 'Stocks you may need',
            ),
            Spacer(),
            TouchableOpacity(
                onTap: () {
                  return SupplierStockYouMayNeedSheet(context);
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
                  print(allStocks);
                  return LowStocksSheet(context);
                },
                child: SeeAllWidget()),
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
                  StockNearExpirySheet(context);
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

  Future<void> StockNearExpirySheet(BuildContext context) {
    return AppWideBottomSheet().showSheet(
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
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                addAutomaticKeepAlives: true,
                padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 3.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.7,
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 1.5.h,
                ),
                itemCount: nearExpiryItems.length,
                itemBuilder: (context, index) {
                  return StocksNearExpiryWidget(
                    name: nearExpiryItems[index]['itemName'],
                    volume: nearExpiryItems[index]['volumeLeft'] +
                        ' ' +
                        nearExpiryItems[index]['unitType'],
                    url: nearExpiryItems[index]['image_url'] ?? '',
                  );
                },
              ),
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
                          BoldTextWidgetHomeScreen(
                            txt: 'Low stocks',
                          ),
                          Space(1.h),
                          Container(
                            width: double.infinity,
                            child: ListView.builder(
                              physics:
                              const NeverScrollableScrollPhysics(), // Disable scrolling
                              shrinkWrap:
                              true, // Allow the GridView to shrink-wrap its content
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

  Future<dynamic> SupplierStockYouMayNeedSheet(BuildContext context) {
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
                      BoldTextWidgetHomeScreen(
                        txt: 'Stocks you may need',
                      ),
                      Column(
                        children: [
                          for (int index = 0;
                          index < stocksYouMayNeed.length;
                          index++)
                            Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              child: Row(children: [
                                ImageWidgetInventory(
                                    height: 40,
                                    radius: 12,
                                    url: stocksYouMayNeed[index]['image_url'] ??
                                        ''),
                                Space(
                                  14,
                                  isHorizontal: true,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stocksYouMayNeed[index]['itemName'],
                                      style: TextStyle(
                                        color: Color(0xFF094B60),
                                        fontSize: 14,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Space(2),
                                    Text(
                                      '${stocksYouMayNeed[index]['volumeLeft']} ${stocksYouMayNeed[index]['unitType']} for next ${stocksYouMayNeed[index]['runway']} days',
                                      style: TextStyle(
                                        color: Color(0xFFFA6E00),
                                        fontSize: 8,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                                Spacer(),
                                TouchableOpacity(
                                  onTap: () {
                                    AppWideLoadingBanner()
                                        .featurePending(context);
                                  },
                                  child: Container(
                                    width: 71,
                                    height: 30,
                                    decoration: GlobalVariables()
                                        .ContainerDecoration(
                                        offset: Offset(0, 4),
                                        blurRadius: 4,
                                        shadowColor:
                                        Color.fromRGBO(0, 0, 0, 0.25),
                                        boxColor:
                                        Color.fromRGBO(84, 166, 193, 1),
                                        cornerRadius: 10),
                                    child: Center(
                                      child: Text(
                                        'Add',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Product Sans',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                        ],
                      )
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
}


