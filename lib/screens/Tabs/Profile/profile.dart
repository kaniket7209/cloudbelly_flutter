// ignore_for_file: must_be_immutable, prefer_is_empty, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/social_status.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/store_setup_sheets.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/menu.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _activeButtonIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 800, // Set your maximum width here
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppwideBanner(),
                Column(
                  children: [
                    Space(10.h),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 800, // Set the maximum width to 800
                      ),
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomIconButton(
                                ic: Icons.arrow_back_ios_new_outlined,
                                onTap: () {},
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 7.w),
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Space(15),
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: const ShapeDecoration(
                                        shadows: [
                                          BoxShadow(
                                            offset: Offset(0, 4),
                                            color: Color.fromRGBO(
                                                31, 111, 109, 0.6),
                                            blurRadius: 20,
                                          )
                                        ],
                                        shape: SmoothRectangleBorder(),
                                      ),
                                      child: ClipSmoothRect(
                                        radius: SmoothBorderRadius(
                                          cornerRadius: 15,
                                          cornerSmoothing: 1,
                                        ),
                                        child: Image.network(
                                          Auth().logo_url,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Space(2.h),
                                    Text(
                                      Auth().store_name,
                                      style: const TextStyle(
                                        color: Color(0xFF094B60),
                                        fontSize: 14,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 0.10,
                                        letterSpacing: 0.42,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  CustomIconButton(
                                    boxColor:
                                        const Color.fromRGBO(38, 115, 140, 1),
                                    color: Colors.white,
                                    ic: Icons.add,
                                    onTap: () async {
                                      AppWideLoadingBanner()
                                          .loadingBanner(context);

                                      List<String> url =
                                          await pickMultipleImagesAndUpoad();
                                      Navigator.of(context).pop();
                                      if (url.length == 0) {
                                        TOastNotification().showErrorToast(
                                            context,
                                            'Error While Uploading Image');
                                      } else if (url
                                          .contains('file size very large'))
                                        TOastNotification().showErrorToast(
                                            context, 'file size very large');
                                      else if (!url.contains('element'))
                                        CreateFeed().showModalSheetForNewPost(
                                            context, url);
                                      else {
                                        TOastNotification().showErrorToast(
                                            context,
                                            'Error While Uploading Image');
                                      }
                                    },
                                  ),
                                  Space(
                                    3.w,
                                    isHorizontal: true,
                                  ),
                                  CustomIconButton(
                                    ic: Icons.more_horiz,
                                    onTap: () {},
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Space(3.h),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 420, // Set the maximum width to 800
                        ),
                        child: Column(
                          children: [
                            Center(
                                child: Container(
                              height: 20.h,
                              width: 90.w,
                              decoration: ShapeDecoration(
                                shadows: const [
                                  BoxShadow(
                                    offset: Offset(0, 4),
                                    color: Color.fromRGBO(165, 200, 199, 0.6),
                                    blurRadius: 25,
                                  )
                                ],
                                color: Colors.white,
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 15,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Space(3.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ColumnWidgetHomeScreen(
                                        data: Auth().rating,
                                        txt: 'Rating',
                                      ),
                                      ColumnWidgetHomeScreen(
                                        data: (Auth().followers)
                                            .length
                                            .toString(),
                                        txt: 'Followers',
                                      ),
                                      ColumnWidgetHomeScreen(
                                        data: (Auth().followings)
                                            .length
                                            .toString(),
                                        txt: 'Following',
                                      )
                                    ],
                                  ),
                                  Space(3.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TouchableOpacity(
                                        onTap: () {
                                          TextEditingController _controller =
                                              TextEditingController(
                                                  text: Auth().store_name);
                                          AppWideBottomSheet().showSheet(
                                              context,
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Edit Profile',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF094B60),
                                                            fontSize: 26,
                                                            fontFamily: 'Jost',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            height: 0.03,
                                                            letterSpacing: 0.78,
                                                          ),
                                                        ),
                                                        Space(3.h),
                                                        TextWidgetStoreSetup(
                                                            label:
                                                                'Edit Store Name'),
                                                        Space(1.h),
                                                        Container(
                                                          // rgba(165, 200, 199, 1),
                                                          decoration:
                                                              const ShapeDecoration(
                                                            shadows: [
                                                              BoxShadow(
                                                                offset: Offset(
                                                                    0, 4),
                                                                color: Color
                                                                    .fromRGBO(
                                                                        165,
                                                                        200,
                                                                        199,
                                                                        0.6),
                                                                blurRadius: 20,
                                                              )
                                                            ],
                                                            color: Colors.white,
                                                            shape:
                                                                SmoothRectangleBorder(
                                                              borderRadius: SmoothBorderRadius
                                                                  .all(SmoothRadius(
                                                                      cornerRadius:
                                                                          10,
                                                                      cornerSmoothing:
                                                                          1)),
                                                            ),
                                                          ),
                                                          height: 6.h,
                                                          child: Center(
                                                            child: TextField(
                                                              onSubmitted:
                                                                  (newvalue) async {
                                                                AppWideLoadingBanner()
                                                                    .loadingBanner(
                                                                        context);
                                                                final code =
                                                                    await updateStoreName(
                                                                        _controller
                                                                            .text);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                if (code ==
                                                                    '200') {
                                                                  TOastNotification()
                                                                      .showSuccesToast(
                                                                          context,
                                                                          'Store name updated');
                                                                } else {
                                                                  TOastNotification()
                                                                      .showErrorToast(
                                                                          context,
                                                                          'Error!');
                                                                }
                                                              },
                                                              controller:
                                                                  _controller,
                                                              decoration:
                                                                  const InputDecoration(
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left:
                                                                            14),
                                                                // hintText: hintText,
                                                                hintStyle: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF0A4C61),
                                                                    fontFamily:
                                                                        'Product Sans',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                              // onChanged: onChanged,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Space(3.h),
                                                  AddCoverImageOrLogoSheetContent(
                                                      isProfile: true,
                                                      isLogo: true),
                                                ],
                                              ),
                                              75.h);
                                        },
                                        child: ButtonWidgetHomeScreen(
                                            txt: 'Edit profile',
                                            isActive: true),
                                      ),
                                      TouchableOpacity(
                                        onTap: () {},
                                        child: ButtonWidgetHomeScreen(
                                          txt: 'Share profile',
                                          isActive: true,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )),
                            Space(3.h),
                            Center(
                              child: Container(
                                width: 90.w,
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h, horizontal: 4.w),
                                decoration: ShapeDecoration(
                                  shadows: const [
                                    BoxShadow(
                                      offset: Offset(0, 4),
                                      color: Color.fromRGBO(165, 200, 199, 0.6),
                                      blurRadius: 25,
                                    )
                                  ],
                                  color: Colors.white,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 15,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.h, horizontal: 3.w),
                                        width: 55,
                                        height: 9,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFFA6E00),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                        ),
                                      ),
                                      Space(2.h),
                                      Container(
                                        height: 7.h,
                                        width: 90.w,
                                        decoration: ShapeDecoration(
                                          shadows: const [
                                            BoxShadow(
                                              offset: Offset(0, 4),
                                              color: Color.fromRGBO(
                                                  165, 200, 199, 0.6),
                                              blurRadius: 20,
                                            )
                                          ],
                                          color: Colors.white,
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 15,
                                              cornerSmoothing: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TouchableOpacity(
                                                  onTap: () {
                                                    setState(() {
                                                      _activeButtonIndex = 1;
                                                    });
                                                  },
                                                  child: CommonButtonProfile(
                                                      isActive:
                                                          _activeButtonIndex ==
                                                              1,
                                                      txt: 'Content')),
                                              TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 2;
                                                  });
                                                },
                                                child: CommonButtonProfile(
                                                    isActive:
                                                        _activeButtonIndex == 2,
                                                    txt: 'Menu'),
                                              ),
                                              TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 3;
                                                  });
                                                },
                                                child: CommonButtonProfile(
                                                    isActive:
                                                        _activeButtonIndex == 3,
                                                    txt: 'Reviews'),
                                              ),
                                            ]),
                                      ),
                                      Space(4.h),
                                      if (_activeButtonIndex == 1)
                                        Container(
                                          width: 85.w,
                                          child: FutureBuilder(
                                            future: getFeed(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                print(snapshot.data);
                                                final data = snapshot.data
                                                    as List<dynamic>;
                                                return GridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(), // Disable scrolling
                                                  shrinkWrap:
                                                      true, // Allow the GridView to shrink-wrap its content
                                                  addAutomaticKeepAlives: true,

                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 0.8.h,
                                                      horizontal: 3.w),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 1,
                                                    crossAxisCount:
                                                        3, // Number of items in a row
                                                    crossAxisSpacing: 4
                                                        .w, // Spacing between columns
                                                    mainAxisSpacing: 1.5
                                                        .h, // Spacing between rows
                                                  ),
                                                  itemCount: data
                                                      .length, // Total number of items
                                                  itemBuilder:
                                                      (context, index) {
                                                    // You can replace this container with your custom item widget
                                                    return FeedWidget(
                                                        index: index,
                                                        fulldata: data,
                                                        data: data[index]);
                                                  },
                                                );
                                              } else
                                                return Center(
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        const CircularProgressIndicator(),
                                                  ),
                                                );
                                            },
                                          ),
                                        ),
                                      if (_activeButtonIndex == 2) const Menu(),
                                      if (_activeButtonIndex == 3)
                                        const Text('Feature Pending')
                                    ]),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeedWidget extends StatelessWidget {
  FeedWidget({
    super.key,
    required this.data,
    required this.fulldata,
    required this.index,
  });
  final int index;

  final dynamic data;
  final dynamic fulldata;
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    // bool _isMultiple =
    //     data['multiple_files'] != null && data['multiple_files'].length != 0;
    return TouchableOpacity(
      onTap: () async {
        final Data = await getFeed();
        Navigator.of(context).pushNamed(PostsScreen.routeName,
            arguments: {'data': fulldata, 'index': index});
      },
      child: Stack(
        children: [
          Hero(
            tag: data['id'],
            child: Container(
              height: 100,
              width: 100,
              decoration: const ShapeDecoration(
                shadows: [
                  BoxShadow(
                    offset: Offset(3, 4),
                    color: Color.fromRGBO(10, 76, 97, 0.31),
                    blurRadius: 9,
                  )
                ],
                shape: SmoothRectangleBorder(),
              ),
              child: ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 10,
                  cornerSmoothing: 1,
                ),
                child: Image.network(
                  data['file_path'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (data['multiple_files'] != null &&
              data['multiple_files'].length != 0)
            const Positioned(
              top: 05,
              right: 05,
              child: Icon(
                Icons.add_to_photos,
                color: Colors.black, // Change the color as needed
              ),
            ),
        ],
      ),
    );
  }
}

class CommonButtonProfile extends StatelessWidget {
  bool isActive;
  String txt;
  CommonButtonProfile({
    super.key,
    required this.isActive,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 5.h,
        width: 25.w,
        decoration: isActive
            ? ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    offset: Offset(5, 6),
                    color: Color.fromRGBO(124, 193, 191, 0.44),
                    blurRadius: 20,
                  )
                ],
                color: const Color.fromRGBO(177, 217, 216, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                ),
              )
            : const ShapeDecoration(shape: SmoothRectangleBorder()),
        child: Center(
          child: Text(
            txt,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF094B60),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              height: 0.10,
              letterSpacing: 0.42,
            ),
          ),
        ));
  }
}
