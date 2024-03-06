// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<dynamic> dataList = [];
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

  Future<dynamic> _bottomSheet(BuildContext context, List<dynamic> data) {
    // bool isEditing = false;/
    // TextEditingController textEditingController = TextEditingController();
    // String text = 'Click me to edit';

    List<dynamic> dataList = data;

    return showModalBottomSheet(
      // useSafeArea: true,
      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        // print(data);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TouchableOpacity(
                            onTap: () {
                              print('march');
                            },
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
                                    '05 March, 2024',
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
                        // updateDataList: dataList,
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

class SheetWidget extends StatefulWidget {
  List<dynamic> dataList;
  // final Function(dynamic) updateDataList;
  SheetWidget({
    super.key,
    required this.dataList,
    // required this.updateDataList,
  });

  @override
  State<SheetWidget> createState() => _SheetWidgetState();
}

class _SheetWidgetState extends State<SheetWidget> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> list = widget.dataList;
    return Column(
      children: [
        Space(3.h),
        Scrollbar(
          trackVisibility: true,
          thumbVisibility: true,
          radius: const Radius.circular(10),
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.top,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Space(1.h),
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
                  width: 138.w,
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        bool _editedToday = false;
                        double _volumeSold = 0.0;
                        if (list[index]['sellingDate'] != '') {
                          DateTime dateToCheck = DateFormat('yyyy-MM-dd')
                              .parse(list[index]['sellingDate']);
                          DateTime currentDate = DateTime.now();

                          if (dateToCheck.year == currentDate.year &&
                              dateToCheck.month == currentDate.month &&
                              dateToCheck.day == currentDate.day) {
                            _editedToday = true;
                            _volumeSold =
                                double.parse(list[index]['volumeSold']);
                          }
                        }

                        if (list[index]['new'] == null &&
                            list[index]['sold'] == null &&
                            !_editedToday) {
                          list[index]['sellingPrice'] = "";
                          list[index]['volumeSold'] = '0';
                        }

                        TextEditingController nameController =
                            TextEditingController(
                          text: list[index]['itemName'],
                        );
                        TextEditingController unitController =
                            TextEditingController(
                          text: list[index]['unitType'],
                        );
                        TextEditingController volumePurchasedController =
                            TextEditingController(
                          text: list[index]['volumePurchased'],
                        );
                        TextEditingController purchasePriceController =
                            TextEditingController(
                          text: list[index]['pricePerUnit'],
                        );
                        TextEditingController sellingPriceController =
                            TextEditingController(
                          text: list[index]['sellingPrice'] == ""
                              ? '-'
                              : list[index]['sellingPrice'],
                        );
                        TextEditingController volumeSoldController =
                            TextEditingController(
                          text: list[index]['volumeSold'] == ""
                              ? '0'
                              : list[index]['volumeSold'],
                        );
                        TextEditingController volumeLeftController =
                            TextEditingController(
                          text: list[index]['volumeLeft'],
                        );

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 1.4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22.w,
                                child: MakeListTextField(
                                  isStringEntry: true,
                                  editable: list[index]['new'] != null,
                                  controller: nameController,
                                  onChanged: (newValue) async {
                                    setState(() {
                                      list[index]['itemName'] = newValue;
                                      nameController.text = newValue;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 13.w,
                                child: MakeListTextField(
                                  isStringEntry: true,
                                  editable: list[index]['new'] != null,
                                  controller: unitController,
                                  onChanged: (newValue) async {
                                    setState(() {
                                      list[index]['unitType'] = newValue;
                                      unitController.text = newValue;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 22.w,
                                child: MakeListTextField(
                                  editable: list[index]['new'] != null,
                                  controller: purchasePriceController,
                                  onChanged: (newValue) async {
                                    setState(() {
                                      list[index]['pricePerUnit'] = newValue;
                                      purchasePriceController.text = newValue;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TouchableOpacity(
                                      onTap: () {
                                        // String newValue = '';
                                        return showModalBottomSheet(
                                          // useSafeArea: true,
                                          context: context,
                                          isScrollControlled: true,

                                          builder: (BuildContext context) {
                                            // print(data);
                                            return StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                                return SingleChildScrollView(
                                                  child: Container(
                                                    decoration:
                                                        const ShapeDecoration(
                                                      color: Colors.white,
                                                      shape:
                                                          SmoothRectangleBorder(
                                                        borderRadius: SmoothBorderRadius.only(
                                                            topLeft: SmoothRadius(
                                                                cornerRadius:
                                                                    35,
                                                                cornerSmoothing:
                                                                    1),
                                                            topRight: SmoothRadius(
                                                                cornerRadius:
                                                                    35,
                                                                cornerSmoothing:
                                                                    1)),
                                                      ),
                                                    ),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.6,
                                                    width: double.infinity,
                                                    padding: EdgeInsets.only(
                                                        left: 6.w,
                                                        right: 6.w,
                                                        top: 2.h,
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TouchableOpacity(
                                                            onTap: () {
                                                              return Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Center(
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            1.h,
                                                                        horizontal:
                                                                            3.w),
                                                                width: 65,
                                                                height: 9,
                                                                decoration:
                                                                    ShapeDecoration(
                                                                  color: const Color(
                                                                      0xFFFA6E00),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6)),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Column(
                                                              children: [
                                                                const Center(
                                                                  child: Text(
                                                                    'Update volume',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color(
                                                                          0xFF094B60),
                                                                      fontSize:
                                                                          24,
                                                                      fontFamily:
                                                                          'Jost',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      // height: 0.03,
                                                                      letterSpacing:
                                                                          0.72,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Space(4.h),
                                                                AppwideTextField(
                                                                  hintText:
                                                                      'Enter new volume',
                                                                  onChanged:
                                                                      (p0) {
                                                                    print(p0);
                                                                    // newValue = p0;
                                                                  },
                                                                  onSubmitted:
                                                                      (newValue) {
                                                                    list[index][
                                                                        'volumePurchased'] = (double.parse(list[index]['volumePurchased']) +
                                                                            double.parse(newValue))
                                                                        .toString();
                                                                    // newValue =
                                                                    //     newValue;
                                                                  },
                                                                ),
                                                                Space(5.h),
                                                              ],
                                                            ),
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
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0.5.w),
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: Color(0xFFFA6E00),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 14.w,
                                      child: MakeListTextField(
                                        editable: list[index]['new'] != null,
                                        controller: volumePurchasedController,
                                        onChanged: (newValue) async {
                                          setState(() {
                                            list[index]['volumePurchased'] =
                                                newValue;
                                            volumePurchasedController.text =
                                                newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                                child: MakeListTextField(
                                  editable: true,
                                  controller: sellingPriceController,
                                  onChanged: (newValue) {
                                    setState(() {
                                      list[index]['sellingPrice'] = newValue;
                                      sellingPriceController.text = newValue;
                                      // if (list[index]['sold'] == null) {
                                      //   list[index]['sellingDate'] =
                                      //       DateFormat('yyyy-MM-dd')
                                      //           .format(DateTime.now())
                                      //           .toString();
                                      // }
                                      list[index]['sold'] = true;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                                child: MakeListTextField(
                                  editable: true,
                                  controller: volumeSoldController,
                                  onChanged: (newValue) {
                                    setState(() {
                                      list[index]['volumeSold'] = newValue;
                                      volumeSoldController.text = newValue;
                                      // if (list[index]['sold'] == null) {
                                      //   list[index]['sellingDate'] =
                                      //       DateFormat('yyyy-MM-dd')
                                      //           .format(DateTime.now())
                                      //           .toString();
                                      // }

                                      list[index]['sold'] = true;
                                      list[index]['volumeLeft'] = (double.parse(
                                                  list[index]['volumeLeft']) -
                                              double.parse(newValue) +
                                              _volumeSold)
                                          .toString();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                                child: MakeListTextField(
                                  editable: false,
                                  controller: volumeLeftController,
                                  onChanged: (newValue) async {
                                    setState(() {
                                      list[index]['volumeLeft'] = newValue;
                                      volumeLeftController.text = newValue;
                                    });
                                    print(newValue);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
        Space(1.h),
        Center(
          child: TouchableOpacity(
            onTap: () {
              print('object');
              setState(() {
                dynamic newItem = {
                  "itemId": '${list.length + 1}',
                  "itemName": "Name",
                  "pricePerUnit": "10",
                  "purchaseDate": DateFormat('yyyy-MM-dd')
                      .format(DateTime.now())
                      .toString(),
                  "sellingDate": "",
                  "sellingPrice": "",
                  // "shelf_life": "",
                  "unitType": "kg",
                  "volumeLeft": "10",
                  "volumePurchased": "10",
                  "volumeSold": "0",
                  "new": true,
                };
                list.insert(0, newItem);
              });
              // widget.updateDataList(newItem);
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
        AppWideButton(
            onTap: () async {
              String msg = "";
              RegExp digitRegExp = RegExp(r'^[0-9]+$');
              list.forEach((element) {
                if (element['sellingPrice'] == "" &&
                    element['volumeSold'] != "0") {
                  msg = "Plese enter selling price";
                }
                if (element['sellingPrice'] != "" &&
                    element['volumeSold'] == "0") {
                  msg = "Plese enter Vol. sold";
                }
                if (element['sellingPrice'] != "" &&
                    element['volumeSold'] != "0") {
                  element['sellingDate'] = DateFormat('yyyy-MM-dd')
                      .format(DateTime.now())
                      .toString();
                }

                // if (!checkString(element['pricePerUnit']) ||
                //     !checkString(element['volumePurchased']) ||
                //     !checkString(element['sellingPrice']) ||
                //     !checkString(element['volumeSold'])) {
                //   msg = 'inappropriate adata entered in some fields';
                // }
              });

              if (msg == '') {
                AppWideLoadingBanner().loadingBanner(context);
                final _data = await Provider.of<Auth>(context, listen: false)
                    .saveInventoryData(list);
                if (_data['code'] == 200) {
                  TOastNotification().showSuccesToast(
                      context, 'Inventory updated successfully');
                } else {
                  TOastNotification().showErrorToast(context, _data['body']);
                }
                Navigator.of(context).pop();
              } else {
                TOastNotification().showErrorToast(context, msg);
              }
            },
            num: 1,
            txt: 'Update the list'),
      ],
    );
  }

  // bool checkString(String s) {
  //   for (int i = 0; i < s.length; i++) {
  //     // Check if the character is not a digit
  //     if (s.codeUnitAt(i) < 48 || s.codeUnitAt(i) > 57) {
  //       return false; // Return false if any non-digit character found
  //     }
  //   }
  //   return true;
  // }

  Future<void> AddVolumeSheet(BuildContext context) {
    return AppWideBottomSheet().showSheet(
        context,
        Container(
          child: Column(
            children: [
              Center(
                child: Text(
                  'Update volume',
                  style: TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 24,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                    height: 0.03,
                    letterSpacing: 0.72,
                  ),
                ),
              ),
              Space(4.h),
              AppwideTextField(
                  hintText: 'Enter new volume', onChanged: (newValue) {})
            ],
          ),
        ),
        30.h);
  }
}

class MakeListTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool editable;
  final bool isStringEntry;

  // double height;
//
  MakeListTextField({
    required this.controller,
    required this.onChanged,
    required this.editable,
    this.isStringEntry = false,
  });

  @override
  State<MakeListTextField> createState() => _MakeListTextFieldState();
}

class _MakeListTextFieldState extends State<MakeListTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null,
      readOnly: !widget.editable,
      textAlign: TextAlign.start,
      style: const TextStyle(
        color: Color(0xFF094B60),
        fontSize: 14,
        fontFamily: 'Product Sans',
        fontWeight: FontWeight.w400,
      ),
      inputFormatters:
          widget.isStringEntry ? [] : [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.done,
      controller: widget.controller,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
      ),
      onSubmitted: widget.onChanged,
    );
  }
}
