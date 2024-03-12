// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class InventoryBottomSheets {
  Future<dynamic> UpdateListBottomSheet(BuildContext context, dynamic data) {
    // print('data: $data');
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
                    // Space(1.h),
                    DateWidgetSHeet(),
                    Space(3.h),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Preview List',
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
                    // Space(0.5.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SheetLabelWidget(
                          txt: 'Product',
                          width: 20.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Purchase price/unit',
                          width: 25.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Volume',
                          width: 20.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Selling price',
                          width: 20.w,
                        ),
                      ],
                    ),
                    // Space(0.5.h),
                    const Divider(
                      color: Color(0xFFFA6E00),
                    ),
                    Space(2.h),
                    Container(
                      height: 70.h,
                      // ma: EdgeInsets.symmetric(vertical: 6.h),
                      child: ListView.builder(
                        itemCount: (data as List<dynamic>).length,
                        itemBuilder: (context, index) {
                          return BottomSheetRowWidget(
                              sellPrice: data[index]['sellingPrice'] == ""
                                  ? '-'
                                  : data[index]['sellingPrice'],
                              name: data[index]['itemName'],
                              price: data[index]['pricePerUnit'] ?? '-',
                              volume: data[index]['volumeLeft'] ?? '-',
                              type: data[index]['unitType']);
                        },
                      ),
                    ),
                    Space(2.h),
                    // AppWideButton(
                    //     onTap: () async {
                    //       AppWideLoadingBanner().loadingBanner(context);
                    //       // final newData =
                    //       //     await Provider.of<Auth>(context, listen: false)
                    //       //         .SyncInventory();
                    //       // print(newData);
                    //       Navigator.of(context).pop();
                    //       // setState(() {
                    //       //   data = newData['data']['inventory_data'];
                    //       //   // print('ui');
                    //       //   // print(UiData);
                    //       // });
                    //     },
                    //     num: 1,
                    //     txt: 'Sync the inventory items')
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

class DateWidgetSHeet extends StatelessWidget {
  const DateWidgetSHeet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
            height: 4.h,
            width: 30.w,
            decoration: GlobalVariables().ContainerDecoration(
                blurRadius: 20,
                offset: Offset(5, 6),
                boxColor: Color.fromRGBO(177, 217, 216, 1),
                cornerRadius: 10,
                shadowColor: Color.fromRGBO(124, 193, 191, 0.44)),
            child: Center(
              child: Text(
                DateFormat('dd MMMM, yyyy').format(DateTime.now()).toString(),
                style: const TextStyle(
                  color: Color(0xFF094B60),
                  fontSize: 12,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w400,
                  height: 0.14,
                  letterSpacing: 0.36,
                ),
              ),
            )),
      ],
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: Text(
            txt,
            maxLines: 2,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF094B60),
              fontSize: 18,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class BottomSheetRowWidget extends StatelessWidget {
  String sellPrice;
  String name;

  String price;
  String volume;
  String type;
  BottomSheetRowWidget({
    super.key,
    required this.sellPrice,
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
            width: 20.w,
            child: Text(
              name,
              maxLines: null,
              style: const TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.13,
              ),
            ),
          ),
          Container(
            width: 25.w,
            child: Text(
              'Rs  ' + price,
              maxLines: null,
              style: const TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.13,
              ),
            ),
          ),
          Container(
            width: 20.w,
            child: Text(
              volume + ' ' + type,
              maxLines: null,
              style: const TextStyle(
                color: Color(0xFF094B60),
                fontSize: 13,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                // height: 0.15,/
              ),
            ),
          ),
          Container(
            width: 20.w,
            child: Text(
              'Rs  ' + sellPrice,
              maxLines: null,
              style: const TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.13,
              ),
            ),
          ),
        ],
      ),
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
