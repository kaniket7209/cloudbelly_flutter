import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class InventoryBottomSheets {
  Future<dynamic> MakeListBottomSheet(BuildContext context, dynamic data) {
    List<dynamic> dataList = data['inventory_data'];
    // Future<void> _getData() async {
    //   final _data = await Provider.of<Auth>(context)
    //       .getdataInventory(Provider.of<Auth>(context).user_id);
    //   dataList = _data['inventory_data'] as List<dynamic>;
    // }

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
                    topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                    topRight:
                        SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                  ),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.9,
              width: double.infinity,
              padding:
                  EdgeInsets.only(left: 6.w, right: 6.w, top: 2.h, bottom: 2.h),
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
                  Space(1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TouchableOpacity(
                        onTap: () {},
                        child: Container(
                            height: 4.h,
                            width: 30.w,
                            decoration: const ShapeDecoration(
                              color: Color.fromRGBO(177, 217, 216, 1),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius.all(
                                  SmoothRadius(
                                      cornerRadius: 15, cornerSmoothing: 1),
                                ),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '04 March, 2024',
                                style: TextStyle(
                                  color: Color(0xFF094B60),
                                  fontSize: 12,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 0.14,
                                  letterSpacing: 0.36,
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                  Space(3.h),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Make your list',
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Container(
                          width: 150.w,
                          height: 1.2,
                          decoration: BoxDecoration(color: Color(0xC1FA6E00)),
                        ),
                        Space(1.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SheetLabelWidget(
                              txt: 'Product',
                              width: 22.w,
                            ),
                            SheetLabelWidget(
                              txt: 'Unit',
                              width: 13.w,
                            ),
                            SheetLabelWidget(
                              txt: 'Purchase Price/unit',
                              width: 22.w,
                            ),
                            SheetLabelWidget(
                              txt: 'Volume',
                              width: 20.w,
                            ),
                            SheetLabelWidget(
                              txt: 'Selling price',
                              width: 20.w,
                            ),
                            SheetLabelWidget(
                              txt: 'Volume sold',
                              width: 20.w,
                            ),
                            SheetLabelWidget(
                              txt: 'Volume left',
                              width: 20.w,
                            ),
                            Container(
                              width: 7.w,
                            ),
                          ],
                        ),
                        Space(1.h),
                        Container(
                          width: 150.w,
                          height: 1.2,
                          decoration: BoxDecoration(color: Color(0xC1FA6E00)),
                        ),
                        // Space(2.h),
                        SizedBox(
                          height: 53.h,
                          width: 145.w,
                          child: ListView.builder(
                              itemCount: dataList.length,
                              itemBuilder: (context, index) {
                                TextEditingController nameController =
                                    TextEditingController(
                                  text: dataList[index]['itemName'],
                                );
                                TextEditingController unitController =
                                    TextEditingController(
                                  text: dataList[index]['unitType'],
                                );
                                TextEditingController priceController =
                                    TextEditingController(
                                  text: dataList[index]['pricePerUnit'],
                                );
                                TextEditingController
                                    volumePurchasedController =
                                    TextEditingController(
                                  text: dataList[index]['volumePurchased'],
                                );
                                TextEditingController sellingPriceController =
                                    TextEditingController(
                                  text: dataList[index]['sellingPrice'] == ""
                                      ? '-'
                                      : dataList[index]['sellingPrice'],
                                );
                                TextEditingController volumeSoldController =
                                    TextEditingController(
                                  text: dataList[index]['volumeSold'] == ""
                                      ? '0'
                                      : dataList[index]['volumeSold'],
                                );
                                TextEditingController volumeLeftController =
                                    TextEditingController(
                                  text: dataList[index]['volumeLeft'],
                                );

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 1.4.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 22.w,
                                        child: TextField(
                                          maxLines: null,
                                          style: const TextStyle(
                                            color: Color(0xFF094B60),
                                            fontSize: 14,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textInputAction: TextInputAction.done,
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.zero,
                                            border: InputBorder.none,
                                          ),
                                          onSubmitted: (newValue) async {},
                                        ),
                                      ),
                                      SizedBox(
                                        width: 13.w,
                                        child: TextField(
                                          maxLines: null,
                                          style: const TextStyle(
                                            color: Color(0xFF094B60),
                                            fontSize: 14,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textInputAction: TextInputAction.done,
                                          controller: unitController,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.zero,
                                            border: InputBorder.none,
                                          ),
                                          onSubmitted: (newValue) async {},
                                        ),
                                      ),
                                      // Container(
                                      //   width: 13.w,
                                      //   child: Text(
                                      //     dataList[index]['unitType'],
                                      //     maxLines: null,
                                      //     textAlign: TextAlign.left,
                                      //     style: const TextStyle(
                                      //       color: Color(0xFF094B60),
                                      //       fontSize: 14,
                                      //       fontFamily: 'Product Sans',
                                      //       fontWeight: FontWeight.w400,
                                      //       height: 0.13,
                                      //     ),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        width: 22.w,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 10.w,
                                              child: TextField(
                                                maxLines: null,
                                                style: const TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller:
                                                    volumePurchasedController,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                ),
                                                onSubmitted:
                                                    (newValue) async {},
                                              ),
                                            ),
                                            MakeListTextWidget(
                                              text: '/${unitController.text}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20.w,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              // fit: FlexFit.,
                                              width: 7.w,
                                              child: TextField(
                                                maxLines: null,
                                                style: const TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller:
                                                    volumePurchasedController,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                ),
                                                onSubmitted:
                                                    (newValue) async {},
                                              ),
                                            ),
                                            MakeListTextWidget(
                                              text: '${unitController.text}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20.w,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 10.w,
                                              child: TextField(
                                                maxLines: null,
                                                style: const TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller:
                                                    sellingPriceController,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                ),
                                                onSubmitted:
                                                    (newValue) async {},
                                              ),
                                            ),
                                            MakeListTextWidget(
                                              text: '/${unitController.text}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20.w,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              // fit: FlexFit.,
                                              width: 7.w,
                                              child: TextField(
                                                maxLines: null,
                                                style: const TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller:
                                                    volumeSoldController,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                ),
                                                onSubmitted:
                                                    (newValue) async {},
                                              ),
                                            ),
                                            MakeListTextWidget(
                                              text: '${unitController.text}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20.w,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              // fit: FlexFit.,
                                              width: 7.w,
                                              child: TextField(
                                                maxLines: null,
                                                style: const TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller:
                                                    volumeLeftController,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                ),
                                                onSubmitted:
                                                    (newValue) async {},
                                              ),
                                            ),
                                            MakeListTextWidget(
                                              text: '${unitController.text}',
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                          width: 7.w,
                                          child: Icon(
                                            Icons.edit_note,
                                          )),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  Space(1.h),
                  Center(
                    child: TouchableOpacity(
                      onTap: () {
                        dataList.add({
                          "itemId": '${dataList.length + 1}',
                          "itemName": "Name",
                          "pricePerUnit": "10",
                          "purchaseDate":
                              '${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                          "sellingDate": "",
                          "sellingPrice": "",
                          "shelf_life": "",
                          "unitType": "kg",
                          "volumeLeft": "10",
                          "volumePurchased": "10",
                          "volumeSold": "0",
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          // margin: EdgeInsets.only(bottom: 2.h),

                          decoration: GlobalVariables().ContainerDecoration(
                            offset: Offset(0, 4),
                            blurRadius: 15,
                            boxColor: Color.fromRGBO(84, 166, 193, 1),
                            cornerRadius: 10,
                            shadowColor: Color.fromRGBO(177, 202, 202, 0.6),
                          ),
                          child: Text(
                            'Add Item',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w700,
                              // height: 0,
                              letterSpacing: 0.14,
                            ),
                          )),
                    ),
                  ),
                  // Space(2.h),
                  Space(1.h),
                  AppWideButton(
                      onTap: () async {}, num: 1, txt: 'Update the list')
                ],
              ),
            );
          },
        );
      },
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
                    topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                    topRight:
                        SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                  ),
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
                          final newData =
                              await Provider.of<Auth>(context, listen: false)
                                  .SyncInventory();
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

class MakeListTextWidget extends StatelessWidget {
  const MakeListTextWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: null,
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Color(0xFF094B60),
        fontSize: 14,
        fontFamily: 'Product Sans',
        fontWeight: FontWeight.w400,
        // height: 0.13,
      ),
    );
  }
}
