// ignore_for_file: must_be_immutable, prefer_is_empty, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/social_status.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/edit_profile.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/menu.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/menu_item.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/screens/pitch_deck.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SampleItem { itemOne }

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _activeButtonIndex = 1;
  SampleItem? selectedMenu;
  Future<void> _refreshFeed() async {
    bool _isAvailable = false;
    final prefs = await SharedPreferences.getInstance();

    final temp = await Provider.of<Auth>(context, listen: false).tryAutoLogin();
    setState(() {
      _isAvailable = temp;
    });

    if (_isAvailable) {
      final extractedUserData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

      String msg = await Provider.of<Auth>(context, listen: false)
          .login(extractedUserData['email'], extractedUserData['password']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: SingleChildScrollView(
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
                      Space(6.h),
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
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: CustomIconButton(
                                    ic: Icons.arrow_back_ios_new_outlined,
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed(PitchDeck.routeName);
                                    },
                                  ),
                                ),
                                Container(
                                  width: 40.w,
                                  padding: EdgeInsets.only(left: 10.w),
                                  child: const StoreNameAndLogoWidget(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: Row(
                                    children: [
                                      CustomIconButton(
                                        boxColor: const Color.fromRGBO(
                                            38, 115, 140, 1),
                                        color: Colors.white,
                                        ic: Icons.add,
                                        onTap: () async {
                                          AppWideLoadingBanner()
                                              .loadingBanner(context);

                                          List<String> url =
                                              await Provider.of<Auth>(context,
                                                      listen: false)
                                                  .pickMultipleImagesAndUpoad();
                                          Navigator.of(context).pop();
                                          if (url.length == 0) {
                                            TOastNotification().showErrorToast(
                                                context,
                                                'Error While Uploading Image');
                                          } else if (url
                                              .contains('file size very large'))
                                            TOastNotification().showErrorToast(
                                                context,
                                                'file size very large');
                                          else if (!url.contains('element')) {
                                            CreateFeed()
                                                .showModalSheetForNewPost(
                                                    context, url)
                                                .then((value) {
                                              setState(() {});
                                            });
                                          } else {
                                            TOastNotification().showErrorToast(
                                                context,
                                                'Error While Uploading Image');
                                          }
                                          setState(() {});
                                        },
                                      ),
                                      Space(
                                        3.w,
                                        isHorizontal: true,
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: ShapeDecoration(
                                          shadows: [
                                            const BoxShadow(
                                              offset: Offset(0, 4),
                                              color: Color.fromRGBO(
                                                  31, 111, 109, 0.5),
                                              blurRadius: 20,
                                            )
                                          ],
                                          color: Colors.white,
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 10,
                                              cornerSmoothing: 1,
                                            ),
                                          ),
                                        ),
                                        child: PopupMenuButton<SampleItem>(
                                          icon: const Icon(Icons.more_horiz),
                                          initialValue: selectedMenu,
                                          // Callback that sets the selected popup menu item.
                                          onSelected: (SampleItem item) async {
                                            AppWideLoadingBanner()
                                                .loadingBanner(context);
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.remove('userData');
                                            Navigator.of(context).pop();
                                            Navigator.of(context)
                                                .pushReplacementNamed(
                                                    LoginScreen.routeName);
                                            setState(() {
                                              selectedMenu = item;
                                            });
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<SampleItem>>[
                                            PopupMenuItem<SampleItem>(
                                              value: SampleItem.itemOne,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.logout),
                                                  Space(
                                                    3.w,
                                                    isHorizontal: true,
                                                  ),
                                                  const Text('Logout'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                                          data: Provider.of<Auth>(context,
                                                  listen: false)
                                              .rating,
                                          txt: 'Rating',
                                        ),
                                        ColumnWidgetHomeScreen(
                                          data: (Provider.of<Auth>(context,
                                                      listen: false)
                                                  .followers)
                                              .length
                                              .toString(),
                                          txt: 'Followers',
                                        ),
                                        ColumnWidgetHomeScreen(
                                          data: (Provider.of<Auth>(context,
                                                      listen: false)
                                                  .followings)
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
                                                    text: Provider.of<Auth>(
                                                            context,
                                                            listen: false)
                                                        .store_name);
                                            AppWideBottomSheet().showSheet(
                                                context,
                                                EditProfileWidget(
                                                    controller: _controller),
                                                75.h);
                                          },
                                          child: ButtonWidgetHomeScreen(
                                              txt: 'Edit profile',
                                              isActive: true),
                                        ),
                                        TouchableOpacity(
                                          onTap: () async {
                                            //id user id
                                            //url prefix
                                            //pacakge name

                                            final DynamicLinkParameters
                                                parameters =
                                                DynamicLinkParameters(
                                              uriPrefix:
                                                  'https://api.cloudbelly.in',
                                              link: Uri.parse(
                                                  'https://api.cloudbelly.in/profile/?id=${Provider.of<Auth>(context, listen: false).user_id}&type=profile'),
                                              androidParameters:
                                                  AndroidParameters(
                                                packageName:
                                                    'com.example.cloudbelly_app',
                                              ),
                                              socialMetaTagParameters:
                                                  SocialMetaTagParameters(
                                                description: 'widget.subtitle',
                                                title: 'widget.title',
                                                imageUrl: Uri.parse(
                                                    Provider.of<Auth>(context,
                                                            listen: false)
                                                        .logo_url),
                                              ),
                                            );
                                            // final ShortDynamicLink
                                            //     shortDynamicLink =
                                            //     await parameters.link;
                                            // buildShortLink();
                                            final Uri shortUrl =
                                                parameters.link;
                                            print(shortUrl);
                                            Share.share("${shortUrl}");
                                          },
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
                                        color:
                                            Color.fromRGBO(165, 200, 199, 0.6),
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
                                          height: 6.5.h,
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
                                                          _activeButtonIndex ==
                                                              2,
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
                                                          _activeButtonIndex ==
                                                              3,
                                                      txt: 'Reviews'),
                                                ),
                                              ]),
                                        ),
                                        Space(3.h),
                                        if (_activeButtonIndex == 1)
                                          Container(
                                            width: 85.w,
                                            child: FutureBuilder(
                                              future: Provider.of<Auth>(context,
                                                      listen: false)
                                                  .getFeed(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  // print(snapshot.data);
                                                  List<dynamic> data = snapshot
                                                      .data as List<dynamic>;
                                                  print(data);
                                                  data = data.reversed.toList();
                                                  return GridView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(), // Disable scrolling
                                                    shrinkWrap:
                                                        true, // Allow the GridView to shrink-wrap its content
                                                    addAutomaticKeepAlives:
                                                        true,

                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0.8.h,
                                                            horizontal: 3.w),
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      childAspectRatio: 1,
                                                      crossAxisCount:
                                                          3, // Number of items in a row
                                                      crossAxisSpacing: 2
                                                          .w, // Spacing between columns
                                                      mainAxisSpacing: 1
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
                                        if (_activeButtonIndex == 2)
                                          Container(
                                            width: 85.w,
                                            child: FutureBuilder(
                                              future: Provider.of<Auth>(context,
                                                      listen: false)
                                                  .getMenu(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  List<dynamic> data = snapshot
                                                      .data as List<dynamic>;
                                                  data = data.reversed.toList();
                                                  print(data);
                                                  return ListView.builder(
                                                      padding: const EdgeInsets
                                                          .only(),
                                                      itemCount: (data as List<
                                                              dynamic>)
                                                          .length,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap:
                                                          true, // Allow the GridView to shrink-wrap its content
                                                      addAutomaticKeepAlives:
                                                          true,
                                                      itemBuilder:
                                                          (context, index) {
                                                        data[index]['VEG'] ==
                                                                null
                                                            ? data[index]
                                                                ['VEG'] = true
                                                            : null;
                                                        // data[index]['description'] =
                                                        //     'Indian delicacies served with tasty gravy, all from your very own kitchen...';

                                                        return data[index]
                                                                    ['VEG'] !=
                                                                null
                                                            ? MenuItem(
                                                                data:
                                                                    data[index])
                                                            : SizedBox.shrink();
                                                      });
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
        final Data = await Provider.of<Auth>(context, listen: false).getFeed()
            as List<dynamic>;
        Navigator.of(context).pushNamed(PostsScreen.routeName,
            arguments: {'data': Data, 'index': index});
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
                  cornerRadius: 17,
                  cornerSmoothing: 1,
                ),
                child: Image.network(
                  data['file_path'],
                  fit: BoxFit.cover,
                  loadingBuilder: GlobalVariables().loadingBuilderForImage,
                  errorBuilder: GlobalVariables().ErrorBuilderForImage,
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
        height: 4.4.h,
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
                color: const Color.fromRGBO(84, 166, 193, 1),
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
