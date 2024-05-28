import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/sucess_sheet.dart';
import 'package:cloudbelly_app/screens/Tabs/supplier/components/components.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StocksYouMayNeedBottomSheet {
  Future<dynamic> StocksYouMayNeedSheet(
      BuildContext context, List<dynamic> stocksYouMayNeed) {
    return showModalBottomSheet(
      // useSafeArea: true,

      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        bool _isVendor =
            Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                'Vendor';
        // print(data);
        return PopScope(
          canPop: true,
          onPopInvoked: (_) {
            //context.read<TransitionEffect>().setBlurSigma(0);
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1),
                          topRight: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1)),
                    ),
                  ),
                  //height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  padding: EdgeInsets.only(
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
                              width: 55,
                              height: 5,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFA6E00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                        ItemsView(
                          stocksYouMayNeed: stocksYouMayNeed,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ItemsView extends StatefulWidget {
  List<dynamic>? stocksYouMayNeed = [];

  ItemsView({super.key, this.stocksYouMayNeed});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController volumeController = TextEditingController();
  List<dynamic> tempList = [];

  @override
  void initState() {
    super.initState();
    // _getStocksYouMayNeed();
  }
  bool? isItemDuplicate(String itemName) {
    return widget.stocksYouMayNeed?.any((item) => item['itemName'] == itemName);
  }
  void addNewItem() {
   // String itemName = nameController.text.trim();
    print("hsjhj:: ${widget.stocksYouMayNeed!.any((item) => item['itemName'] == nameController.text.trim())}");
    print("name:: ${nameController.text}");

    if (nameController.text.trim().isEmpty) {
      TOastNotification().showErrorToast(context, "Item name cannot be empty");
      return;
    }

    if (widget.stocksYouMayNeed!.any((item) => item['itemName'] != nameController.text.trim())) {
      //print("hsjhj");
      return;
    }else{
      TOastNotification().showErrorToast(context, "Item with the same name already exists");

    }
    /*widget.stocksYouMayNeed?.add({
      "itemName": nameController.text.trim(),
      "volumeLeft": volumeController.text.trim(),
    });*/
    /*widget.stocksYouMayNeed?.add({
      "itemName": "demo",
      "volumeLeft": "20",
      "unitType": "kg",
    });*/
    print("addItemInNewList:: ${widget.stocksYouMayNeed}");
    setState(() {});
    // Navigator.pop(context);
  }

  Future<void> submit() async {
    /*context.read<TransitionEffect>().setBlurSigma(5.0);
    SuccessSheetBottomSheet().successSheet(context);*/
    if (tempList.isEmpty) {
      TOastNotification().showErrorToast(context, "Please Add Item");
    } else {
      AppWideLoadingBanner().loadingBanner(context);
      String msg = await Provider.of<Auth>(context, listen: false)
          .addInventoryToCart(tempList);
      if (msg == "New Cart created successfully") {
        TOastNotification().showSuccesToast(context, msg);
        Navigator.pop(context);
      } else {
        TOastNotification().showErrorToast(context, msg);
      }
    }
  }

  Future<void> openAddMenuBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                    topRight:
                        SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
              ),
            ),
            //height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 2.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 40,
              right: 40,
            ),
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
                        width: 55,
                        height: 5,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFA6E00),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  ),
                  const Space(31),
                  TextWidgetStoreSetup(label: 'Name of the product'),
                  const Space(9),
                  AppwideTextField(
                    controller: nameController,
                    hintText: 'Enter the name of the product you need',
                    userType: Provider.of<Auth>(context, listen: false)
                        .userData?['user_type'],
                    onChanged: (p0) {
                      // user_name = p0.toString();
                      // print(user_name);
                    },
                  ),
                  const Space(23),
                  TextWidgetStoreSetup(label: 'Volume needed'),
                  const Space(9),
                  AppwideTextField(
                    controller: volumeController,
                    hintText: 'Mention the volume here',
                    userType: Provider.of<Auth>(context, listen: false)
                        .userData?['user_type'],
                    onChanged: (p0) {
                      // user_name = p0.toString();
                      // print(user_name);
                    },
                  ),
                  Space(26),
                  Center(
                    child: TouchableOpacity(
                      onTap: () {
                        addNewItem();
                      },
                      child: Container(
                          height: 37,
                          width: 125,
                          decoration: ShapeDecoration(
                            shadows: const [
                              BoxShadow(
                                offset: Offset(5, 6),
                                color: Color.fromRGBO(72, 138, 136, 0.5),
                                blurRadius: 15,
                              )
                            ],
                            color: const Color.fromRGBO(10, 76, 97, 1),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 10,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Add item",
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
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      /* decoration: const ShapeDecoration(
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
            width: double.infinity,*/
      height: MediaQuery.of(context).size.height * 0.86,
      padding: EdgeInsets.only(
          left: 6.w,
          right: 6.w,
          top: 2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space(2.h),
          const BoldTextWidgetHomeScreen(
            txt: 'Stocks you may need',
          ),
          const Space(25),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 30),
                      margin: const EdgeInsets.symmetric(
                        vertical: 0,
                      ),
                      child: Row(children: [
                        ImageWidgetInventory(
                            height: 40,
                            radius: 12,
                            url: widget.stocksYouMayNeed?[index]['image_url'] ??
                                ''),
                        const Space(
                          14,
                          isHorizontal: true,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.stocksYouMayNeed?[index]['itemName'],
                              style: const TextStyle(
                                color: Color(0xFF0A4C61),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w400,
                                height: 20 / 14.0,
                                // Calculate the line height based on font size
                                letterSpacing: 0.03,
                              ),
                            ),
                            Space(2),
                            if (widget.stocksYouMayNeed?[index]['runway'] !=
                                null)
                              Text(
                                widget.stocksYouMayNeed?[index]['runway'] < 0
                                    ? '${widget.stocksYouMayNeed?[index]['volumeLeft']} ${widget.stocksYouMayNeed?[index]['unitType']} left and ${"expired 8 days before"}'
                                    : '${widget.stocksYouMayNeed?[index]['volumeLeft']} ${widget.stocksYouMayNeed?[index]['unitType']} for next ${widget.stocksYouMayNeed?[index]['runway']} days',
                                style: const TextStyle(
                                  color: Color(0xFFFA6E00),
                                  fontSize: 8,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                          ],
                        ),
                        const Spacer(),
                        TouchableOpacity(
                          onTap: () {
                            tempList.add({
                              "itemName": widget.stocksYouMayNeed?[index]
                                  ['itemName'],
                              "unitType": widget.stocksYouMayNeed?[index]
                                  ['unitType'],
                              "itemId": widget.stocksYouMayNeed?[index]
                                  ['itemId'],
                              "volumeLeft": widget.stocksYouMayNeed?[index]
                                  ['volumeLeft'],
                            });

                            widget.stocksYouMayNeed?[index]['isAdded'] = true;
                            print("tempList:: $tempList");
                            setState(() {});
                          },
                          child: Container(
                            width: 71,
                            height: 30,
                            decoration: GlobalVariables().ContainerDecoration(
                                offset: const Offset(0, 8),
                                blurRadius: 20,
                                shadowColor:
                                    const Color.fromRGBO(152, 202, 201, 0.8),
                                boxColor: const Color.fromRGBO(84, 166, 193, 1),
                                cornerRadius: 10),
                            child: Center(
                              child: Text(
                                widget.stocksYouMayNeed?[index]['isAdded'] ==
                                        true
                                    ? 'Added'
                                    : 'Add',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w700,
                                  height: 18.12 / 14.0,
                                  // Calculate the line height based on font size
                                  letterSpacing: 0.01,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Space(
                          15.79,
                          isHorizontal: true,
                        ),
                        GestureDetector(
                          onTap: () {
                            print(index);
                            setState(() {
                            //  tempList.removeAt(index);
                            //  print("tempList:: $tempList");
                              widget.stocksYouMayNeed?.removeWhere((item) => item['itemName'] ==  widget.stocksYouMayNeed?[index]['itemName']);
                             // widget.stocksYouMayNeed?[index]['isAdded'] = false;
                              print("stocksYouMayNeed:: ${widget.stocksYouMayNeed}");
                            });
                          /*  tempList.removeWhere((item) =>
                                item['itemId'] ==
                                widget.stocksYouMayNeed?[index]['itemId']);*/
                          },
                          child: const Text(
                            "x",
                            style: TextStyle(
                              color: Color(0xFFFA6E00),
                              fontSize: 16,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 20 / 16.0,
                              // Calculate the line height based on font size
                              letterSpacing: 0.03,
                            ),
                          ),
                        )
                      ]),
                    ),
                  ],
                );
              },
              itemCount: widget.stocksYouMayNeed?.length ?? 0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TouchableOpacity(
                  onTap: () {
                    openAddMenuBottomSheet(context);
                  },
                  child: Container(
                      height: 37,
                      width: 125,
                      decoration: ShapeDecoration(
                        shadows: const [
                          BoxShadow(
                            offset: Offset(5, 6),
                            color: Color.fromRGBO(72, 138, 136, 0.5),
                            blurRadius: 15,
                          )
                        ],
                        color: const Color.fromRGBO(10, 76, 97, 1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Add item",
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
                ),
                const Space(
                  26,
                  isHorizontal: true,
                ),
                TouchableOpacity(
                  onTap: () {
                    submit();
                  },
                  child: Container(
                      height: 37,
                      width: 125,
                      decoration: ShapeDecoration(
                        shadows: const [
                          BoxShadow(
                            offset: Offset(5, 6),
                            color: Color.fromRGBO(72, 138, 136, 0.5),
                            blurRadius: 15,
                          )
                        ],
                        color: const Color.fromRGBO(250, 110, 0, 1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Submit",
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
                ),
                /*  AppWideButton(
                  onTap: () {
                  },
                  num: 2,
                  txt: 'Submit',
                  ispop: true,
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*     TouchableOpacity(
                onTap: () {},
                child: Container(
                    height: 37,
                    width: 125,
                    decoration: ShapeDecoration(
                      shadows: const [
                        BoxShadow(
                          offset: Offset(5, 6),
                          color: Color.fromRGBO(72, 138, 136, 0.5),
                          blurRadius: 20,
                        )
                      ],
                      color: const Color.fromRGBO(10, 76, 97, 1),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Add item",
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
              ),
          const Space(26),
          AppWideButton(
            onTap: () {
            },
            num: 2,
            txt: 'Submit',
            ispop: true,
          ),*/
