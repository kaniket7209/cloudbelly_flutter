// ignore_for_file: must_be_immutable, use_build_context_synchronously, override_on_non_overriding_member

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class makeListSheet {
  Future<dynamic> bottomSheet(BuildContext context, List<dynamic> data) {
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
                            height: 6,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFA6E00),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                      DateWidgetSHeet(),
                      Space(29),
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
                      SizedBox(height: 20,),
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

ScrollController _scrollController = ScrollController();

class _SheetWidgetState extends State<SheetWidget> {
  void _setState() {
    setState(() {});
  }

  bool _isKeyboardVisible = false;

  @override
  void didChangeMetrics() {
    setState(() {
      _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = widget.dataList;
    return Column(
      children: [
        Space(1.h),
        Scrollbar(
          controller: _scrollController,
          trackVisibility: true,
          thumbVisibility: true,
          radius: const Radius.circular(10),
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.top,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: _isKeyboardVisible ?Axis.vertical  :Axis.horizontal,
            child: Column(
              children: [
                Column(
                  children: [
                    Space(20),
                    Container(
                      width: 153.w,
                      height: 1.2,
                      decoration: const BoxDecoration(color: Color(0xC1FA6E00)),
                    ),
                    Space(1.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SheetLabelWidget(
                          txt: 'Product Name',
                          width: 22.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Unit Type',
                          width: 13.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Purchase Price/unit',
                          width: 24.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Volume Purchased',
                          width: 25.w,
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
                        SizedBox(
                          width: 8.w,
                        )
                      ],
                    ),
                    Space(1.h),
                    Container(
                      width: 153.w,
                      height: 1.2,
                      decoration: const BoxDecoration(color: Color(0xC1FA6E00)),
                    ),
                  ],
                ),

                // Space(2.h),
                SizedBox(
                 // height: 53.h,
                  width: 153.w,
                  child: ListView.builder(
                      itemCount: list.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                          margin: EdgeInsets.symmetric(vertical: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22.w,
                                child: MakeListTextField(
                                  hintText: 'Name',
                                  isStringEntry: true,
                                  editable: list[index]['new'] != null,
                                  controller: nameController,
                                  onChanged: (newValue) async {
                                    // setState(() {
                                    list[index]['itemName'] =
                                        newValue.toString();
                                    // nameController.text = newValue;
                                    // });/
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 13.w,
                                child: MakeListTextField(
                                  hintText: 'Kg',
                                  isStringEntry: true,
                                  editable: list[index]['new'] != null,
                                  controller: unitController,
                                  onChanged: (newValue) async {
                                    // setState(() {
                                    list[index]['unitType'] = newValue;
                                    unitController.text = newValue;
                                    // });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 24.w,
                                child: MakeListTextField(
                                  hintText: '10',
                                  editable: list[index]['new'] != null,
                                  controller: purchasePriceController,
                                  onChanged: (newValue) async {
                                    // setState(() {
                                    list[index]['pricePerUnit'] = newValue;
                                    purchasePriceController.text = newValue;
                                    // });/
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 25.w,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 10.w,
                                      child: MakeListTextField(
                                        hintText: "100",
                                        editable: list[index]['new'] != null,
                                        controller: volumePurchasedController,
                                        onChanged: (newValue) async {
                                          // setState(() {
                                          list[index]['volumePurchased'] =
                                              newValue;
                                          volumePurchasedController.text =
                                              newValue;
                                          // });
                                          // setState(() {
                                          list[index]['volumeLeft'] =
                                              (double.parse(newValue) -
                                                      double.parse(list[index]
                                                          ['volumeSold']))
                                                  .toString();
                                          volumeLeftController.text = newValue;
                                          // });
                                        },
                                      ),
                                    ),
                                    TouchableOpacity(
                                      onTap: () {
                                        String newValue = '';
                                        TextEditingController _cotrolller =
                                            TextEditingController();

                                        showModalBottomSheet(
                                          // useSafeArea: true,
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                                return Container(
                                                  decoration:
                                                      const ShapeDecoration(
                                                    color: Colors.white,
                                                    shape:
                                                        SmoothRectangleBorder(
                                                      borderRadius:
                                                          SmoothBorderRadius
                                                              .only(
                                                        topLeft: SmoothRadius(
                                                            cornerRadius: 35,
                                                            cornerSmoothing: 1),
                                                        topRight: SmoothRadius(
                                                            cornerRadius: 35,
                                                            cornerSmoothing: 1),
                                                      ),
                                                    ),
                                                  ),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      (_isKeyboardVisible
                                                          ? 0.32
                                                          : 0.6),
                                                  width: double.infinity,
                                                  padding: EdgeInsets.only(
                                                      left: 6.w,
                                                      right: 6.w,
                                                      top: 2.h,
                                                      bottom: 2.h),
                                                  child: SingleChildScrollView(
                                                    child: Column(
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
                                                        // Space(1.h),
                                                        Container(
                                                          child: Column(
                                                            children: [
                                                              Space(2.h),
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
                                                              Space(2.5.h),
                                                              AppwideTextField(
                                                                userType: Provider.of<Auth>(context, listen: false).userData?['user_type'],
                                                                controller:
                                                                    _cotrolller,
                                                                hintText:
                                                                    'Enter new volume',
                                                                onChanged:
                                                                    (p0) {
                                                                  newValue = p0;
                                                                },
                                                              ),
                                                              Space(6.h),
                                                              AppWideButton(
                                                                  onTap: () {
                                                                    list[index][
                                                                        'volumePurchased'] = (double.parse(list[index]['volumePurchased']) +
                                                                            double.parse(newValue))
                                                                        .toString();
                                                                    list[index][
                                                                        'volumeLeft'] = (double.parse(list[index]['volumeLeft']) +
                                                                            double.parse(newValue))
                                                                        .toString();
                                                                    volumePurchasedController
                                                                        .text = list[
                                                                            index]
                                                                        [
                                                                        'volumePurchased'];
                                                                    _cotrolller
                                                                        .clear();
                                                                    _setState();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  num: 1,
                                                                  txt:
                                                                      'Update Volume'),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
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
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                                child: MakeListTextField(
                                  hintText: '-',
                                  editable: list[index]['sold'] != null
                                      ? true
                                      : false,
                                  controller: sellingPriceController,
                                  onChanged: (newValue) {
                                    // setState(() {
                                    list[index]['sellingPrice'] = newValue;
                                    sellingPriceController.text = newValue;
                                    // if (list[index]['sold'] == null) {
                                    //   list[index]['sellingDate'] =
                                    //       DateFormat('yyyy-MM-dd')
                                    //           .format(DateTime.now())
                                    //           .toString();
                                    // }
                                    // list[index]['sold'] = true;
                                    // });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                                child: MakeListTextField(
                                  hintText: '0',
                                  editable: true,
                                  controller: volumeSoldController,
                                  onChanged: (newValue) {
                                    list[index]['volumeLeft'] = (double.parse(
                                                list[index]['volumeLeft']) -
                                            double.parse(newValue) +
                                            _volumeSold +
                                            ((list[index]['sold'] != null &&
                                                    _volumeSold == 0)
                                                ? double.parse(
                                                    list[index]['volumeSold'])
                                                : 0))
                                        .toString();
                                    list[index]['volumeSold'] = newValue;
                                    volumeSoldController.text = newValue;

                                    list[index]['sold'] = true;

                                    // });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                                child: MakeListTextField(
                                  hintText: '',
                                  editable: false,
                                  controller: volumeLeftController,
                                  onChanged: (newValue) async {
                                    // setState(() {
                                    list[index]['volumeLeft'] = newValue;
                                    volumeLeftController.text = newValue;
                                    // });
                                    // print(newValue);
                                  },
                                ),
                              ),
                              TouchableOpacity(
                                  onTap: () {
                                    setState(() {
                                      list.removeWhere((element) =>
                                          element['itemId'] ==
                                          list[index]['itemId']);
                                    });
                                  },
                                  child: SizedBox(
                                    width: 8.w,
                                    child: Center(
                                      child: Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Color.fromRGBO(245, 75, 75, 1),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
        Space(1.5.h),
        Center(
          child: TouchableOpacity(
            onTap: () {
              // print('object');
              String msg = "";
              // RegExp digitRegExp = RegExp(r'^[0-9]+$');
              list.forEach((element) {
                if (element['itemName'] == '') {
                  msg = "Product name missing";
                }
                if (element['pricePerUnit'] == '') {
                  msg = "Product price missing";
                }
                if (element['unitType'] == '') {
                  msg = "Unit type missing";
                }
                if (element['volumePurchased'] == '') {
                  msg = "Volume purchased missing";
                }
                if (element['sellingPrice'] == "" &&
                    element['volumeSold'] != "0") {
                  msg = "Plese enter selling price";
                }
              });
              if (msg == '') {
                setState(() {
                  dynamic newItem = {
                    "itemId": '${list.length + 1}',
                    "itemName": "",
                    "pricePerUnit": "",
                    "purchaseDate": DateFormat('yyyy-MM-dd')
                        .format(DateTime.now())
                        .toString(),
                    "sellingDate": "",
                    "sellingPrice": "",
                    // "shelf_life": "",
                    "unitType": "",
                    "volumeLeft": "",
                    "volumePurchased": "",
                    "volumeSold": "0",
                    "new": true,
                  };
                  list.insert(0, newItem);
                });
              } else {
                TOastNotification().showErrorToast(context, msg);
              }

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
        Space(2.5.h),
        AppWideButton(
            onTap: () async {
              String msg = "";
              // RegExp digitRegExp = RegExp(r'^[0-9]+$');
              list.forEach((element) {
                if (element['itemName'] == '') {
                  msg = "Product name missing";
                }
                if (element['pricePerUnit'] == '') {
                  msg = "Product price missing";
                }
                if (element['unitType'] == '') {
                  msg = "Unit type missing";
                }
                if (element['volumePurchased'] == '') {
                  msg = "Volume purchased missing";
                }
                if (element['sellingPrice'] == "" &&
                    element['volumeSold'] != "0") {
                  msg = "Plese enter selling price";
                }

                if (element['sellingPrice'] != "" &&
                    element['volumeSold'] != "0") {
                  element['sellingDate'] = DateFormat('yyyy-MM-dd')
                      .format(DateTime.now())
                      .toString();
                }
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
        Space(1.h)
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
              Space(1.h),
              Center(
                child: Text(
                  'Update volume',
                  style: TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 24,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                    // height: 0.03,
                    letterSpacing: 0.72,
                  ),
                ),
              ),
              Space(4.h),
              AppwideTextField(
                userType: Provider.of<Auth>(context, listen: false).userData?['user_type'],
                  hintText: 'Enter new volume', onChanged: (newValue) {}),
              AppWideButton(num: 1, txt: 'Update Volume'),
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
  final String hintText;

  // double height;
//
  MakeListTextField({
    required this.controller,
    required this.onChanged,
    required this.editable,
    this.isStringEntry = false,
    this.hintText = '',
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
        textAlign:
            widget.hintText == '100' ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          color: Color(0xFF094B60),
          fontSize: 13,
          fontFamily: 'Product Sans',
          fontWeight: FontWeight.w400,
        ),
        inputFormatters: widget.isStringEntry
            ? []
            : [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
        textInputAction: TextInputAction.done,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText == '' ? null : widget.hintText,
          hintStyle: TextStyle(
            color: Color(0x66094B60),
            fontSize: 13,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w400,
// height: 0.15,
          ),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        onChanged: widget.hintText != '0' ? widget.onChanged : (newv) {},
        onSubmitted: widget.hintText == '0' ? widget.onChanged : (newv) {},
        cursorColor: Color(0xFFFA6E00));
  }
}
