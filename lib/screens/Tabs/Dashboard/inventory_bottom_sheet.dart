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
