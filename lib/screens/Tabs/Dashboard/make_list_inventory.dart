import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MakeListInventoryButton extends StatefulWidget {
  const MakeListInventoryButton({super.key});

  @override
  State<MakeListInventoryButton> createState() =>
      _MakeListInventoryButtonState();
}

class _MakeListInventoryButtonState extends State<MakeListInventoryButton> {
  @override
  Widget build(BuildContext context) {
    return Make_Update_ListWidget(
      txt: 'Make List',
      onTap: () async {
        AppWideLoadingBanner().loadingBanner(context);
        final _data = await Provider.of<Auth>(context, listen: false)
            .getdataInventory(
                Provider.of<Auth>(context, listen: false).user_id);
        Navigator.of(context).pop();
        dataList = _data['inventory_data'];
        _bottomSheet(context, dataList);
      },
    );
  }

  Future<dynamic> _bottomSheet(BuildContext context, List<dynamic> dataList) {
    return showModalBottomSheet(
      // useSafeArea: true,

      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        return Container(
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.only(
                  topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.9,
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
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
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
                Space(2.h),
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
                SheetWidget(
                  dataList: dataList,
                  updateDataList: updateDataList,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> dataList = [];
  void updateDataList(dynamic newItem) {
    setState(() {
      dataList.add(newItem);
    });
  }
}

class SheetWidget extends StatefulWidget {
  List<dynamic> dataList;
  final Function(dynamic) updateDataList;
  SheetWidget({
    super.key,
    required this.dataList,
    required this.updateDataList,
  });

  @override
  State<SheetWidget> createState() => _SheetWidgetState();
}

class _SheetWidgetState extends State<SheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Space(3.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                width: 150.w,
                height: 1.2,
                decoration: const BoxDecoration(color: Color(0xC1FA6E00)),
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
                decoration: const BoxDecoration(color: Color(0xC1FA6E00)),
              ),
              // Space(2.h),
              SizedBox(
                height: 53.h,
                width: 145.w,
                child: ListView.builder(
                    itemCount: widget.dataList.length,
                    itemBuilder: (context, index) {
                      TextEditingController nameController =
                          TextEditingController(
                        text: widget.dataList[index]['itemName'],
                      );
                      TextEditingController unitController =
                          TextEditingController(
                        text: widget.dataList[index]['unitType'],
                      );
                      TextEditingController volumePurchasedController =
                          TextEditingController(
                        text: widget.dataList[index]['volumePurchased'],
                      );
                      TextEditingController sellingPriceController =
                          TextEditingController(
                        text: widget.dataList[index]['sellingPrice'] == ""
                            ? '-'
                            : widget.dataList[index]['sellingPrice'],
                      );
                      TextEditingController volumeSoldController =
                          TextEditingController(
                        text: widget.dataList[index]['volumeSold'] == ""
                            ? '0'
                            : widget.dataList[index]['volumeSold'],
                      );
                      TextEditingController volumeLeftController =
                          TextEditingController(
                        text: widget.dataList[index]['volumeLeft'],
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
                            //     widget.dataList[index]['unitType'],
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
                                      textInputAction: TextInputAction.done,
                                      controller: volumePurchasedController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (newValue) async {},
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
                                      textInputAction: TextInputAction.done,
                                      controller: volumePurchasedController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (newValue) async {},
                                    ),
                                  ),
                                  MakeListTextWidget(
                                    text: unitController.text,
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
                                      textInputAction: TextInputAction.done,
                                      controller: sellingPriceController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (newValue) async {},
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
                                      textInputAction: TextInputAction.done,
                                      controller: volumeSoldController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (newValue) async {},
                                    ),
                                  ),
                                  MakeListTextWidget(
                                    text: unitController.text,
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
                                      textInputAction: TextInputAction.done,
                                      controller: volumeLeftController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (newValue) async {
                                        print(newValue);
                                      },
                                    ),
                                  ),
                                  MakeListTextWidget(
                                    text: unitController.text,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                                width: 7.w,
                                child: const Icon(
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
              print('object');
              dynamic newItem = {
                "itemId": '${widget.dataList.length + 1}',
                "itemName": "Name",
                "pricePerUnit": "10",
                "purchaseDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
                "sellingDate": "",
                "sellingPrice": "",
                "shelf_life": "",
                "unitType": "kg",
                "volumeLeft": "10",
                "volumePurchased": "10",
                "volumeSold": "0",
              };
              widget.updateDataList(newItem);
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                // margin: EdgeInsets.only(bottom: 2.h),

                decoration: GlobalVariables().ContainerDecoration(
                  offset: const Offset(0, 4),
                  blurRadius: 15,
                  boxColor: const Color.fromRGBO(84, 166, 193, 1),
                  cornerRadius: 10,
                  shadowColor: const Color.fromRGBO(177, 202, 202, 0.6),
                ),
                child: const Text(
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
        AppWideButton(onTap: () async {}, num: 1, txt: 'Update the list'),
      ],
    );
  }
}
