import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Performance extends StatefulWidget {
  const Performance({super.key});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Space(2.h),
        Text(
          'Manage your menu',
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 20,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            height: 0.05,
            letterSpacing: 0.60,
          ),
        ),
        Space(2.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Make_Update_ListWidget(
              onTap: () {
                AppWideBottomSheet().showSheet(
                    context,
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Space(1.h),
                          Text(
                            '  Scan your menu',
                            style: TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 26,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600,
                              height: 0.03,
                              letterSpacing: 0.78,
                            ),
                          ),
                          Space(3.h),
                          TouchableOpacity(
                            onTap: () async {
                              AppWideLoadingBanner().loadingBanner(context);
                              dynamic data = await ScanMenu('Gallery');
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              if (data == 'file size very large') {
                                TOastNotification().showErrorToast(
                                    context, 'file size very large');
                              } else if (data != 'No image picked' &&
                                  data != '') {
                                ScannedMenuBottomSheet(context, data);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.photo_album_outlined),
                                  Space(isHorizontal: true, 15),
                                  Text(
                                    'Upload from gallery',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 0.10,
                                      letterSpacing: 0.36,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          TouchableOpacity(
                            onTap: () async {
                              AppWideLoadingBanner().loadingBanner(context);
                              dynamic data = await ScanMenu('Camera');
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              print(data);
                              if (data == 'file size very large') {
                                TOastNotification().showErrorToast(
                                    context, 'file size very large');
                              } else if (data != 'No image picked' &&
                                  data != '') {
                                ScannedMenuBottomSheet(context, data);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.camera),
                                  Space(isHorizontal: true, 15),
                                  Text(
                                    'Click photo',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 0.10,
                                      letterSpacing: 0.36,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    25.h);
              },
              txt: 'Add products',
            ),
            Make_Update_ListWidget(
              onTap: () {},
              txt: 'Edit product',
            )
          ],
        ),
      ],
    );
  }
}
