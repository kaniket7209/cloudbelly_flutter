import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/supplier/components/components.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StocksYouMayNeedBottomSheet {
   Future<dynamic> StockYouMayNeedSheet(
      BuildContext context, List<dynamic> stocksYouMayNeed) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            TextEditingController productController = TextEditingController();
            TextEditingController volumeController = TextEditingController();
            TextEditingController unitTypeController = TextEditingController();
            Map<int, TextEditingController> volumeEditControllers = {};
            Map<int, TextEditingController> unitTypeEditControllers = {};

            print("stocksYouMayNeed  $stocksYouMayNeed");

            void addItem() {
              String name = productController.text;
              String volume = volumeController.text;
              String unitType = unitTypeController.text;
              print('Product: $name, Volume: $volume, Unit: $unitType');
              setState(() {
                stocksYouMayNeed.add({
                  'itemName': name,
                  'volume': volume,
                  'volumeLeft': volume,
                  'unitType': unitType,
                  'isEditing': false,
                });
              });
              Navigator.pop(context);
            }

            void showAddItemModal() {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      decoration: const ShapeDecoration(
                        shadows: [
                          BoxShadow(
                            color: Color(0x7FB1D9D8),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                        color: Colors.white,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.only(
                            topLeft: SmoothRadius(
                                cornerRadius: 40, cornerSmoothing: 1),
                            topRight: SmoothRadius(
                                cornerRadius: 40, cornerSmoothing: 1),
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name of the product',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0A4C61)),
                          ),
                          TextField(
                            controller: productController,
                            decoration: InputDecoration(
                                hintText:
                                    'Enter the name of the product you need',
                                hintStyle: TextStyle(
                                    color: Color(0xff0A4C61).withOpacity(0.5))),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            'Volume needed',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0A4C61)),
                          ),
                          TextField(
                            controller: volumeController,
                            decoration: InputDecoration(
                                hintText: 'Mention the volume here',
                                hintStyle: TextStyle(
                                    color: Color(0xff0A4C61).withOpacity(0.5))),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            'Unit Type',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0A4C61)),
                          ),
                          TextField(
                            controller: unitTypeController,
                            decoration: InputDecoration(
                                hintText: 'Mention the unit type here',
                                hintStyle: TextStyle(
                                    color: Color(0xff0A4C61).withOpacity(0.5))),
                          ),
                          SizedBox(height: 40.0),
                          GestureDetector(
                            onTap: addItem,
                            child: Center(
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 1.h),
                                  // margin: EdgeInsets.only(bottom: 2.h),
                                  decoration: ShapeDecoration(
                                    shadows: [
                                      BoxShadow(
                                        offset: const Offset(1, 4),
                                        color:
                                            Color(0xff0A4C61).withOpacity(0.45),
                                        blurRadius: 30,
                                      ),
                                    ],
                                    color: Color(0xff0A4C61),
                                    shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                      cornerRadius: 13,
                                      cornerSmoothing: 1,
                                    )),
                                  ),
                                  child: Text(
                                    'Add Item',
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16),
                                  )),
                            ),
                          ),
                          SizedBox(height: 25.0),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: Color(0x7FB1D9D8),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                        topLeft:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                        topRight:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                      ),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Stocks you may need",
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w800,
                            color: Color(0xff0A4C61),
                            fontSize: 26,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: stocksYouMayNeed.length,
                          itemBuilder: (context, index) {
                            final item = stocksYouMayNeed[index];
                            item['isEditing'] = item['isEditing'] ?? false;

                            if (!volumeEditControllers.containsKey(index)) {
                              print("indexvolumeEditControllers  $index");
                              volumeEditControllers[index] =
                                  TextEditingController(
                                text: item['volumeLeft'],
                              );
                            }
                            if (!unitTypeEditControllers.containsKey(index)) {
                              print("indexunitTypeEditControllers $index");
                              unitTypeEditControllers[index] =
                                  TextEditingController(text: item['unitType']);
                            }

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    color: Color(0xffDBF5F5),
                                    blurRadius: 20,
                                    offset: Offset(0, 12),
                                    spreadRadius: 0,
                                  ),
                                ],
                                color: const Color(0xffD3EEEE),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 13,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  item['itemName'],
                                  style: const TextStyle(
                                    color: Color(0xff0A4C61),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Ubuntu',
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    item['isEditing']
                                        ? Container(
                                            height: 4.h,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  child: Center(
                                                    child: TextField(
                                                      cursorColor:
                                                          Color(0xff0A4C61),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Product Sans',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      controller:
                                                          volumeEditControllers[
                                                              index],
                                                      onChanged: (value) {
                                                        item['volumeLeft'] =
                                                            value;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                          
                                                        filled:
                                                            true, // Add this line
                                                        fillColor: Color(
                                                            0xff70BAD2), // Set your desired background color here
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        0),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0xff70BAD2),
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0xff70BAD2),
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0xff70BAD2),
                                                          ),
                                                        ),
                                                      ),
                                                   
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10,),
                                                SizedBox(
                                                  width: 80,
                                                  child: Center(
                                                    child: TextField(
                                                      cursorColor:
                                                          Color(0xff0A4C61),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Product Sans',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      controller:
                                                          unitTypeEditControllers[
                                                              index],
                                                      onChanged: (value) {
                                                        item['unitType'] =
                                                            value;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        filled:
                                                            true, // Add this line
                                                        fillColor: Color(
                                                            0xff70BAD2), // Set your desired background color here
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        0),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0xff70BAD2),
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0xff70BAD2),
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0xff70BAD2),
                                                          ),
                                                        ),
                                                      ),
                                                   
                                                    ),
                                                  ),
                                                ),
                                               
                                                IconButton(
                                                  icon: Icon(Icons.check,
                                                      color: Colors.green),
                                                  onPressed: () {
                                                    setState(() {
                                                      item['isEditing'] = false;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                item['isEditing'] = true;
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 1),
                                              width: 20.w,
                                              height: 4.h,
                                              decoration: ShapeDecoration(
                                                shadows: [
                                                  BoxShadow(
                                                    color: Color(0xff5BA9C3)
                                                        .withOpacity(0.5),
                                                    blurRadius: 20,
                                                    offset: Offset(0, 4),
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                                color: const Color(0xff5BA9C3),
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius(
                                                    cornerRadius: 13,
                                                    cornerSmoothing: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "${item['volumeLeft']} ${item['unitType'] ?? ''}",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete_outlined, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          stocksYouMayNeed.removeAt(index);
                                          volumeEditControllers.remove(index);
                                          unitTypeEditControllers.remove(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: showAddItemModal,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 1.h),
                                // margin: EdgeInsets.only(bottom: 2.h),
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      offset: const Offset(1, 4),
                                      color:
                                          Color(0xff0A4C61).withOpacity(0.45),
                                      blurRadius: 30,
                                    ),
                                  ],
                                  color: Color(0xff0A4C61),
                                  shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                    cornerRadius: 13,
                                    cornerSmoothing: 1,
                                  )),
                                ),
                                child: Text(
                                  'Add Item',
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16),
                                )),
                          ),
                          GestureDetector(
                            onTap: () async {
                              List<Map<String, dynamic>> formattedStocks =
                                  stocksYouMayNeed.map((item) {
                                return {
                                  "item_name": item['itemName'],
                                  "qty": int.parse(item['volumeLeft']),
                                  "unit_type": item['unitType']
                                };
                              }).toList();
                              print('Stocks to be submitted: $formattedStocks');
                              final resData = await Provider.of<Auth>(context,
                                      listen: false)
                                  .cartInventory(formattedStocks);
                              if (resData['code'] == 200) {
                                print("Updated");
                                TOastNotification().showSuccesToast(
                                    context, "Successfully saved");
                                Navigator.of(context).pop();
                              } else {
                                TOastNotification().showErrorToast(
                                    context, resData['message']);
                              }
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 1.h),
                                // margin: EdgeInsets.only(bottom: 2.h),
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      offset: const Offset(1, 4),
                                      color:
                                          Color(0xffFA6E00).withOpacity(0.45),
                                      blurRadius: 30,
                                    ),
                                  ],
                                  color: Color(0xffFA6E00),
                                  shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                    cornerRadius: 13,
                                    cornerSmoothing: 1,
                                  )),
                                ),
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

}

class ItemsView extends StatefulWidget {
  const ItemsView({super.key});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
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
      height: MediaQuery.of(context).size.height * 0.90,
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
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: Row(children: [
                      ImageWidgetInventory(
                          height: 40,
                          radius: 12,
                          url: /*stocksYouMayNeed[index]['image_url'] ??*/
                              'https://drive.google.com/file/d/12-9XoJVr5w0DzuHXkeWdJOq_ZO_JHWMt/view?usp=drive_link'),
                      const Space(
                        14,
                        isHorizontal: true,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Milk",
                            //" stocksYouMayNeed[index]['itemName']",
                            style: TextStyle(
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
                          Text(
                            "5kg for next 3 days"
                            /*stocksYouMayNeed[index]['runway'] < 0
                                                  ? '${stocksYouMayNeed[index]['volumeLeft']} ${stocksYouMayNeed[index]['unitType']} left and ${"expired 8 days before"}'
                                                  : '${stocksYouMayNeed[index]['volumeLeft']} ${stocksYouMayNeed[index]['unitType']} for next ${stocksYouMayNeed[index]['runway']} days',*/
                            ,
                            style: TextStyle(
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
                          AppWideLoadingBanner().featurePending(context);
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
                          child: const Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
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
                      const Text(
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
                      )
                    ]),
                  ),
                ],
              );
            },
            /* separatorBuilder: (context, _) {
                  return Space(30);
                },*/
            itemCount: 1,
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