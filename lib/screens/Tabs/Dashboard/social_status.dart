// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';

import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/rating_widget.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/profile_setting_view.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_progress_bar.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:fine_bar_chart/fine_bar_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SocialStatusContent extends StatefulWidget {
  const SocialStatusContent({
    super.key,
  });

  @override
  State<SocialStatusContent> createState() => _SocialStatusContentState();
}

class _SocialStatusContentState extends State<SocialStatusContent>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    // bool _isLoading = false;
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // print('counter: $counter ');
    // TODO: implement initState
    super.initState();
  }

  PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  // bool _isLoading = false;

  List<String> _dailyList = ['Daily', 'Weekly', "monthly"];
  int _dailyIndex = 0;
  List<double> barValue = [50, 30, 90, 60, 80, 25];
  List<Color> barColors = [
    Color(0xFFFA6E00),
    Color(0xFFFA6E00),
    Color(0xFFFA6E00),
    Color(0xFFFA6E00),
    Color(0xFFFA6E00),
    Color(0xFFFA6E00),
    // Color(0xFFFA6E00),
  ];
  List<String> bottomBarName = ["Mon", "Tue", "Wed", "Thu", "Sat", "Sun"];
  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Auth>(context, listen: true)
                .userData?['pincode'] ==
            ''
        ? 1
        : Provider.of<Auth>(context, listen: true).userData?['pan_number'] == ''
            ? 2
            : Provider.of<Auth>(context, listen: true).userData?['bank_name'] ==
                    ''
                ? 3
                : 4;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space(2.h),
          const Center(
            child: Text(
              'Create post',
              style: TextStyle(
                color: Color(0xFF094B60),
                fontSize: 20,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                height: 0.05,
                letterSpacing: 0.60,
              ),
            ),
          ),
          Space(3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Make_Update_ListWidget(
                txt: 'From gallery',
                onTap: () async {
                  AppWideLoadingBanner().loadingBanner(context);
                  List<String> url =
                      await Provider.of<Auth>(context, listen: false)
                          .pickMultipleImagesAndUpoad();
                  List<dynamic> menuList =
                      await Provider.of<Auth>(context, listen: false).getMenu(
                          Provider.of<Auth>(context, listen: false)
                              .userData?['user_id']);
                  Navigator.of(context).pop();
                  if (url.length == 0) {
                    TOastNotification()
                        .showErrorToast(context, 'Error While Uploading Image');
                  } else if (url.contains('file size very large'))
                    TOastNotification()
                        .showErrorToast(context, 'file size very large');
                  else if (!url.contains('element'))
                    CreateFeed()
                        .showModalSheetForNewPost(context, url, menuList);
                  else {
                    TOastNotification()
                        .showErrorToast(context, 'Error While Uploading Image');
                  }
                },
              ),
             const Space(
              25,
              isHorizontal: true,
            ),
              Make_Update_ListWidget(
                txt: 'Click photo',
                onTap: () async {
                  AppWideLoadingBanner().loadingBanner(context);
                  List<String> url = [];
                  url.add(await Provider.of<Auth>(context, listen: false)
                      .pickImageAndUpoad(src: 'Camera', context));
                  List<dynamic> menuList =
                      await Provider.of<Auth>(context, listen: false).getMenu(
                          Provider.of<Auth>(context, listen: false)
                              .userData?['user_id']);
                  print('object');
                  print(url[0]);
                  Navigator.of(context).pop();
                  if (url.length == 0) {
                    TOastNotification()
                        .showErrorToast(context, 'Error While Uploading Image');
                  } else if (url.contains('file size very large'))
                    TOastNotification()
                        .showErrorToast(context, 'file size very large');
                  else if (!url.contains('element') && url[0] != '')
                    CreateFeed()
                        .showModalSheetForNewPost(context, url, menuList);
                  else {
                    TOastNotification()
                        .showErrorToast(context, 'Error While Uploading Image');
                  }
                },
              ),
            ],
          ),
          Space(4.h),

          Row(
            children: [
              const BoldTextWidgetHomeScreen(
                txt: 'Customer visits',
              ),
              Spacer(),
              IconButton(
                  onPressed: () {
                    if (_dailyIndex == 0)
                      return null;
                    else {
                      setState(() {
                        _dailyIndex--;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 14,
                    color: Color(0xFFFA6E00),
                  )),
              SizedBox(
                width: 14.w,
                child: Center(
                  child: Text(
                    _dailyList[_dailyIndex],
                    style: TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      height: 0.14,
                      letterSpacing: 0.36,
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    if (_dailyIndex == _dailyList.length - 1)
                      return null;
                    else {
                      setState(() {
                        _dailyIndex++;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFFFA6E00),
                  ))
            ],
          ),
          Space(1.h),
          Container(
            //  height: 27.h,
            width: double.infinity,
            decoration: GlobalVariables().ContainerDecoration(
              offset: Offset(0, 4),
              blurRadius: 25,
              boxColor: Colors.white,
              cornerRadius: 20,
              shadowColor: Color.fromRGBO(165, 200, 199, 0.6),
            ),
            child: Column(
              children: [
                Space(2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Space(
                      10.w,
                      isHorizontal: true,
                    ),
                    CustomerVisitWidget(
                      title: 'Total visits',
                      number: '345',
                      text: 'Vs 221 visits',
                      date: 'last mon, Jan 29',
                    ),
                    CustomerVisitWidget(
                      title: 'Unique visits',
                      number: '+34',
                      text: 'Vs 221 visits',
                      date: 'last mon, Jan 29',
                    ),
                  ],
                ),
                Space(1.5.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  width: double.infinity,
                  height: 2,
                  decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                ),
                Space(1.5.h),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Space(
                      10.w,
                      isHorizontal: true,
                    ),
                    CustomerVisitWidget(
                      title: 'Total \nconversion',
                      number: '+34',
                      text: 'Vs 221 visits',
                      date: 'last mon, Jan 29',
                    ),
                    CustomerVisitWidget(
                      title: 'Conversion from\n unique visit',
                      number: '+34',
                      text: 'Vs 221 visits',
                      date: 'last mon, Jan 29',
                    ),
                  ],
                ),
                Space(2.h),
              ],
            ),
          ),
          Space(4.h),
          const BoldTextWidgetHomeScreen(
            txt: 'Top 3 performing posts',
          ),
          Space(1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TopPerformingPostWidget(),
              TopPerformingPostWidget(),
              TopPerformingPostWidget(),
            ],
          ),
          Space(4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BoldTextWidgetHomeScreen(
                txt: 'Customer’s review',
              ),
              SeeAllWidget(),
            ],
          ),
          Space(1.h),
          CustomerReviewWidget(),
          CustomerReviewWidget(),
          CustomerReviewWidget(),
          Space(2.h),

          const BoldTextWidgetHomeScreen(
            txt: 'Most activities on store (views)',
          ),

          Space(1.h),

          Container(
            //height: 34.h,
            width: double.infinity,
            decoration: GlobalVariables().ContainerDecoration(
              offset: Offset(0, 4),
              blurRadius: 15,
              boxColor: Colors.white,
              cornerRadius: 15,
              shadowColor: Color.fromRGBO(177, 202, 202, 0.6),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          if (_dailyIndex == 0)
                            return null;
                          else {
                            setState(() {
                              _dailyIndex--;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 14,
                          color: Color(0xFFFA6E00),
                        )),
                    SizedBox(
                      width: 14.w,
                      child: Center(
                        child: Text(
                          _dailyList[_dailyIndex],
                          style: TextStyle(
                            color: Color(0xFF094B60),
                            fontSize: 12,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w700,
                            height: 0.14,
                            letterSpacing: 0.36,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          if (_dailyIndex == _dailyList.length - 1)
                            return null;
                          else {
                            setState(() {
                              _dailyIndex++;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFFFA6E00),
                        ))
                  ],
                ),
                FineBarChart(
                    barWidth: 25,
                    barHeight: 20.h,
                    backgroundColors: Colors.white,
                    isBottomNameDisable: false,
                    isValueDisable: false,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    barBackgroundColors: Colors.grey.withOpacity(0.3),
                    barValue: barValue,
                    barColors: barColors,
                    barBottomName: bottomBarName),
                Space(1.h),
              ],
            ),
          ),
          Space(4.h),
          // const BoldTextWidgetHomeScreen(txt: 'Tools & essentials'),
          // Space(2.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     TouchableOpacity(
          //         onTap: () async {
          //           final prefs = await SharedPreferences.getInstance();

          //           final counter = prefs.getInt('counter') ?? 1;

          //           if (counter < 4) {
          //             return SlidingSheet().showAlertDialog(context, counter);
          //           } else {
          //             TOastNotification().showSuccesToast(context, 'All Set ');
          //           }
          //         },
          //         child: ToolsButtonWidgetHomeSCreen(
          //             width: 15.w, txt: 'Setup Store')),
          //     ToolsButtonWidgetHomeSCreen(
          //       width: 15.w,
          //       txt: 'Photos & Videos',
          //     ),
          //     TouchableOpacity(
          //         onTap: () {
          //           return Navigator.of(context)
          //               .pushNamed(InventoryHub.routeName);
          //         },
          //         child: ToolsButtonWidgetHomeSCreen(
          //           width: 15.w,
          //           txt: 'Inventory Manage',
          //         )),
          //     TouchableOpacity(
          //       onTap: () {
          //         return showModalBottomSheet(
          //           // useSafeArea: true,
          //           context: context,
          //           isScrollControlled: true,
          //           builder: (BuildContext context) {
          //             return StatefulBuilder(
          //               builder: (BuildContext context, StateSetter setState) {
          //                 return Container(
          //                   decoration: const ShapeDecoration(
          //                     color: Colors.white,
          //                     shape: SmoothRectangleBorder(
          //                       borderRadius: SmoothBorderRadius.only(
          //                           topLeft: SmoothRadius(
          //                               cornerRadius: 35, cornerSmoothing: 1),
          //                           topRight: SmoothRadius(
          //                               cornerRadius: 35, cornerSmoothing: 1)),
          //                     ),
          //                   ),
          //                   height: MediaQuery.of(context).size.height * 0.3,
          //                   width: double.infinity,
          //                   padding: EdgeInsets.only(
          //                       left: 10.w, right: 10.w, top: 2.h, bottom: 2.h),
          //                   child: SingleChildScrollView(
          //                     child: Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         TouchableOpacity(
          //                           onTap: () {
          //                             return Navigator.of(context).pop();
          //                           },
          //                           child: Center(
          //                             child: Container(
          //                               padding: EdgeInsets.symmetric(
          //                                   vertical: 1.h, horizontal: 3.w),
          //                               width: 65,
          //                               height: 9,
          //                               decoration: ShapeDecoration(
          //                                 color: const Color(0xFFFA6E00),
          //                                 shape: RoundedRectangleBorder(
          //                                     borderRadius:
          //                                         BorderRadius.circular(6)),
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                         Space(6.h),
          //                         const Text(
          //                           'Scan your menu',
          //                           style: TextStyle(
          //                             color: Color(0xFF094B60),
          //                             fontSize: 26,
          //                             fontFamily: 'Jost',
          //                             fontWeight: FontWeight.w600,
          //                             height: 0.03,
          //                             letterSpacing: 0.78,
          //                           ),
          //                         ),
          //                         Space(4.h),
          //                         Row(
          //                           mainAxisAlignment: MainAxisAlignment.start,
          //                           children: [
          //                             TouchableOpacity(
          //                               onTap: !_isLoading
          // ? () async {
          //     setState(() {
          //       _isLoading = true;
          //     });
          //     dynamic data =
          //         await ScanMenu('Gallery');
          //     // print(data);
          //     Navigator.of(context).pop();
          //     ScannedMenuBottomSheet(
          //         context, data);
          //     setState(() {
          //       _isLoading = false;
          //     });
          //   }
          //                                   : null,
          //                               child: StocksMayBeNeedWidget(
          //                                   url: '',
          //                                   txt: 'Upload from gallery'),
          //                             ),
          //                             TouchableOpacity(
          //                                 onTap: !_isLoading
          //                                     ? () async {
          //                                         setState(() {
          //                                           _isLoading = true;
          //                                         });
          //                                         final data =
          //                                             await ScanMenu('Camera');
          //                                         Navigator.of(context).pop();
          //                                         ScannedMenuBottomSheet(
          //                                             context, data);
          //                                         setState(() {
          //                                           _isLoading = false;
          //                                         });
          //                                       }
          //                                     : null,
          //                                 child: StocksMayBeNeedWidget(
          //                                     url: '', txt: 'Click photo')),
          //                             Space(isHorizontal: true, 5.w),
          //                             if (_isLoading)
          //                               const Center(
          //                                 child: CircularProgressIndicator(),
          //                               ),
          //                           ],
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 );
          //               },
          //             );
          //           },
          //         );
          //       },
          //       child: ToolsButtonWidgetHomeSCreen(
          //         width: 15.w,
          //         txt: 'Upload Menu',
          //       ),
          //     ),
          //     ToolsButtonWidgetHomeSCreen(
          //       width: 15.w,
          //       txt: 'Dashboard',
          //     ),
          //   ],
          // ),
          // Space(3.h),
          // Center(
          //   child: Card(
          //     elevation: 10,
          //     child: Container(
          //         height: 6.h,
          //         width: 75.w,
          //         padding: EdgeInsets.only(left: 1.w, right: 1.w),
          //         decoration: ShapeDecoration(
          //           color: Colors.white,
          //           shape: SmoothRectangleBorder(
          //             borderRadius: SmoothBorderRadius(
          //               cornerRadius: 10,
          //               cornerSmoothing: 1,
          //             ),
          //           ),
          //         ),
          //         child: const Center(
          //           child: Text.rich(
          //             TextSpan(
          //               children: [
          //                 TextSpan(
          //                   text: 'Gaon',
          //                   style: TextStyle(
          //                     color: Color(0xFF0A4C61),
          //                     fontSize: 24,
          //                     fontFamily: 'Jost',
          //                     fontWeight: FontWeight.w700,
          //                     letterSpacing: 0.24,
          //                   ),
          //                 ),
          //                 TextSpan(
          //                   text: 'FRESH',
          //                   style: TextStyle(
          //                     color: Color(0xFF63AFC7),
          //                     fontSize: 24,
          //                     fontFamily: 'Jost',
          //                     fontWeight: FontWeight.w700,
          //                     letterSpacing: 0.24,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         )),
          //   ),
          // ),
          // Space(3.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const BoldTextWidgetHomeScreen(txt: 'Inventory forecasting'),
          //     Column(
          //       children: [
          //         Text(
          //           'Expand',
          //           style: GoogleFonts.ptSans(
          //               color: const Color.fromRGBO(10, 76, 97, 1),
          //               fontWeight: FontWeight.w700,
          //               fontSize: 12),
          //         ),
          //         Container(
          //           height: 2,
          //           width: 45,
          //           color: const Color.fromRGBO(250, 110, 0, 1),
          //         )
          //       ],
          //     )
          //   ],
          // ),
          // Space(2.h),
          // InventoryForcastingWidget(isBuy: true),
          // Space(3.h),
          // const BoldTextWidgetHomeScreen(txt: 'Inventory based recipe'),
          // Space(1.5.h),
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: SizedBox(
          //     height: 18.h,
          //     child: Center(
          //       child: Row(
          //         children: [
          //           InvetoryBasedReciepeWidget(),
          //           InvetoryBasedReciepeWidget(),
          //           InvetoryBasedReciepeWidget(),
          //           InvetoryBasedReciepeWidget(),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Space(3.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const BoldTextWidgetHomeScreen(txt: 'Inventory wastage'),
          //     Column(
          //       children: [
          //         Text(
          //           'Expand',
          //           style: GoogleFonts.ptSans(
          //               color: const Color.fromRGBO(10, 76, 97, 1),
          //               fontWeight: FontWeight.w700,
          //               fontSize: 12),
          //         ),
          //         Container(
          //           height: 2,
          //           width: 45,
          //           color: const Color.fromRGBO(250, 110, 0, 1),
          //         )
          //       ],
          //     )
          //   ],
          // ),
          // Space(2.h),
          // InventoryForcastingWidget(
          //   isBuy: false,
          // ),
          // Space(3.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const BoldTextWidgetHomeScreen(txt: 'Reselling marketplace'),
          //     Column(
          //       children: [
          //         Text(
          //           'Expand',
          //           style: GoogleFonts.ptSans(
          //               color: const Color.fromRGBO(10, 76, 97, 1),
          //               fontWeight: FontWeight.w700,
          //               fontSize: 12),
          //         ),
          //         Container(
          //           height: 2,
          //           width: 45,
          //           color: const Color.fromRGBO(250, 110, 0, 1),
          //         )
          //       ],
          //     )
          //   ],
          // ),
          // Space(1.h),
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: SizedBox(
          //     height: 18.h,
          //     child: Center(
          //       child: Row(
          //         children: [
          //           InvetoryBasedReciepeWidget(
          //             isResell: true,
          //           ),
          //           InvetoryBasedReciepeWidget(
          //             isResell: true,
          //           ),
          //           InvetoryBasedReciepeWidget(
          //             isResell: true,
          //           ),
          //           InvetoryBasedReciepeWidget(
          //             isResell: true,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class CustomerReviewWidget extends StatelessWidget {
  const CustomerReviewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 2.h),
          height: 10.h,
          width: double.infinity,
          decoration: GlobalVariables().ContainerDecoration(
            offset: Offset(0, 4),
            blurRadius: 15,
            boxColor: Colors.white,
            cornerRadius: 15,
            shadowColor: Color.fromRGBO(177, 202, 202, 0.6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Space(isHorizontal: true, 4.w),
              Container(
                decoration: GlobalVariables().ContainerDecoration(
                  offset: Offset(0, 4),
                  blurRadius: 20,
                  boxColor: Colors.white,
                  cornerRadius: 10,
                  shadowColor: Color.fromRGBO(124, 193, 191, 0.3),
                ),
                height: 50,
                width: 50,
                child: ClipRRect(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 8,
                    cornerSmoothing: 1,
                  ),
                  child: Image.network(
                    'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=600',
                    fit: BoxFit.cover,
                    loadingBuilder: GlobalVariables().loadingBuilderForImage,
                    errorBuilder: GlobalVariables().ErrorBuilderForImage,
                  ),
                ),
              ),
              Space(isHorizontal: true, 3.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Naveen',
                            style: TextStyle(
                              color: Color(0xFF0A4C61),
                              fontSize: 16,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.16,
                            ),
                          ),
                          Space(isHorizontal: true, 2.w),
                          Text(
                            '22 hrs ago',
                            style: TextStyle(
                              color: Color(0xFFFA6E00),
                              fontSize: 10,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                              letterSpacing: 0.10,
                            ),
                          ),
                        ],
                      ),

                      //Spacer(),
                      Space(
                        20.w,
                        isHorizontal: true,
                      ),
                      RatingIcons(rating: 4.5),
                    ],
                  ),
                  Text(
                    'Food is good how ever it can be done better,\nit breaks my heart to write...',
                    style: TextStyle(
                      color: Color(0xFF0A4C61),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.12,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        Positioned(
            right: 0,
            bottom: 5,
            child: Container(
                decoration: GlobalVariables().ContainerDecoration(
                  offset: Offset(0, 4),
                  blurRadius: 20,
                  boxColor: Color.fromRGBO(10, 76, 97, 1),
                  cornerRadius: 10,
                  shadowColor: Color.fromRGBO(124, 193, 191, 0.3),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                child: Text(
                  'Reply',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.10,
                  ),
                ))),
      ],
    );
  }
}

class TopPerformingPostWidget extends StatelessWidget {
  const TopPerformingPostWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 97,
      height: 104,
      decoration: GlobalVariables().ContainerDecoration(
        offset: Offset(0, 4),
        blurRadius: 20,
        boxColor: Colors.white,
        cornerRadius: 10,
        shadowColor: Color.fromRGBO(124, 193, 191, 0.3),
      ),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Container(
          decoration: GlobalVariables().ContainerDecoration(
            offset: Offset(0, 4),
            blurRadius: 20,
            boxColor: Colors.white,
            cornerRadius: 10,
            shadowColor: Color.fromRGBO(124, 193, 191, 0.3),
          ),
          height: 68,
          width: 78,
          child: ClipRRect(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 8,
              cornerSmoothing: 1,
            ),
            child: Image.network(
              'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=600',
              fit: BoxFit.cover,
              loadingBuilder: GlobalVariables().loadingBuilderForImage,
              errorBuilder: GlobalVariables().ErrorBuilderForImage,
            ),
          ),
        ),
        Text(
          '10.2k Likes',
          style: TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0,
            letterSpacing: 0.12,
          ),
        )
      ]),
    );
  }
}

class CustomerVisitWidget extends StatelessWidget {
  String title;
  String number;
  String text;
  String date;
  CustomerVisitWidget({
    super.key,
    required this.text,
    required this.date,
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            number,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFFFA6E00),
              fontSize: 20,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 10,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            date,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 10,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}

class AddCoverImageOrLogoSheetContent extends StatelessWidget {
  bool isProfile;
  bool isLogo;
  AddCoverImageOrLogoSheetContent({
    super.key,
    required this.isLogo,
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    Color boxShadowColor;
 String userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Space(1.h),
        if(userType !='Customer')
        Text(
          isLogo ? '  Add logo' : 'Add Cover Image',
          style: TextStyle(
            color: boxShadowColor,
            fontSize: isProfile ? 17 : 26,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            height: 0.03,
            letterSpacing: 0.78,
          ),
        ),
        if(userType =='Customer')
        Text(
          isLogo ? '  Add profile photo' : 'Add Cover Image',
          style: TextStyle(
            color: boxShadowColor,
            fontSize: isProfile ? 17 : 26,
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
            final _url = await Provider.of<Auth>(context, listen: false)
                .pickImageAndUpoad(context);
            if (_url == 'file size very large') {
              TOastNotification()
                  .showErrorToast(context, 'file size very large');
            } else if (_url != '') {
              String code = isLogo
                  ? await Provider.of<Auth>(context, listen: false)
                      .updateProfilePhoto(_url)
                  : await Provider.of<Auth>(context, listen: false)
                      .updateCoverImage(_url, context);
              if (code == '200') {
                if (isLogo) {
                  Provider.of<Auth>(context, listen: false).setUserData({
                    ...Provider.of<Auth>(context, listen: false).userData!,
                    'profile_photo': _url
                  });
                } else {
                  Provider.of<Auth>(context, listen: false).setUserData({
                    ...Provider.of<Auth>(context, listen: false).userData!,
                    'cover_image': _url
                  });
                }
                TOastNotification().showSuccesToast(context,
                    '${isLogo ? 'Store logo' : 'Cover Image'}  updated');
              } else {
                TOastNotification().showErrorToast(
                    context, 'Error happened while updating image');
              }
            }
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child:  Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.photo_album_outlined),
                Space(isHorizontal: true, 15),
                Text(
                  'Upload from gallery',
                  style: TextStyle(
                    color: boxShadowColor,
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
        
        // TouchableOpacity(
        //   onTap: () async {
        //     AppWideLoadingBanner().loadingBanner(context);
        //     final _url = await Provider.of<Auth>(context, listen: false)
        //         .pickImageAndUpoad(context, src: 'Camera');
        //     if (_url == 'file size very large') {
        //       TOastNotification()
        //           .showErrorToast(context, 'file size very large');
        //     } else if (_url != '') {
        //       String code = isLogo
        //           ? await Provider.of<Auth>(context, listen: false)
        //               .updateProfilePhoto(_url)
        //           : await Provider.of<Auth>(context, listen: false)
        //               .updateCoverImage(_url, context);
        //       if (code == '200') {
        //         if (isLogo) {
        //           Provider.of<Auth>(context, listen: false).logo_url = _url;
        //         } else {
        //           Provider.of<Auth>(context, listen: false)
        //               .userData?['cover_image'] = _url;
        //         }
        //         TOastNotification().showSuccesToast(context,
        //             '${isLogo ? 'Store logo' : 'Cover Image'}  updated');
        //         // Navigator.of(context)
        //         // .pushNamed(Tabs.routeName);
        //       } else {
        //         TOastNotification().showErrorToast(
        //             context, 'Error happend while updating image');
        //       }
        //       // Provider.of<Auth>(context, listen: false).logo_url=
        //     }

        //     Navigator.of(context).pop();
        //     Navigator.of(context).pop();
        //   },
        //   child: const Padding(
        //     padding: EdgeInsets.all(8.0),
        //     child: Row(
        //       children: [
        //         Icon(Icons.camera),
        //         Space(isHorizontal: true, 15),
        //         Text(
        //           'Click photo',
        //           style: TextStyle(
        //             color: Color(0xFF094B60),
        //             fontSize: 12,
        //             fontFamily: 'Product Sans',
        //             fontWeight: FontWeight.w700,
        //             height: 0.10,
        //             letterSpacing: 0.36,
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
      TouchableOpacity(
          onTap: () async {
            AppWideLoadingBanner().loadingBanner(context);
            final _url = await Provider.of<Auth>(context, listen: false)
                .pickImageAndUpoad(context,src: 'Camera');
            if (_url == 'file size very large') {
              TOastNotification()
                  .showErrorToast(context, 'file size very large');
            } else if (_url != '') {
              String code = isLogo
                  ? await Provider.of<Auth>(context, listen: false)
                      .updateProfilePhoto(_url)
                  : await Provider.of<Auth>(context, listen: false)
                      .updateCoverImage(_url, context);
              if (code == '200') {
                if (isLogo) {
                  Provider.of<Auth>(context, listen: false).setUserData({
                    ...Provider.of<Auth>(context, listen: false).userData!,
                    'profile_photo': _url
                  });
                } else {
                  Provider.of<Auth>(context, listen: false).setUserData({
                    ...Provider.of<Auth>(context, listen: false).userData!,
                    'cover_image': _url
                  });
                }
                TOastNotification().showSuccesToast(context,
                    '${isLogo ? 'Store logo' : 'Cover Image'}  updated');
              } else {
                TOastNotification().showErrorToast(
                    context, 'Error happened while updating image');
              }
            }
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child:  Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.camera),
                Space(isHorizontal: true, 15),
                Text(
                  'Click Photo',
                  style: TextStyle(
                    color: boxShadowColor,
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
        
      ],
    );
  }
}

class AddSomething_EnhaceWidget extends StatelessWidget {
  String heading;
  String text;
  AddSomething_EnhaceWidget({
    super.key,
    required this.heading,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 12.w),
      width: double.infinity,
      decoration: const ShapeDecoration(
        shadows: [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(124, 193, 191, 0.1),
            blurRadius: 20,
          )
        ],
        color: Color.fromRGBO(207, 245, 245, 1),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 25, cornerSmoothing: 1)),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 149,
          child: Text(
            heading,
            style: const TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 16,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              height: 0,
              letterSpacing: 0.16,
            ),
          ),
        ),
        Space(1.h),
        SizedBox(
          width: double.infinity,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: const TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 10,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.10,
            ),
          ),
        )
      ]),
    );
  }
}
