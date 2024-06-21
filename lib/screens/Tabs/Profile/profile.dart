// ignore_for_file: must_be_immutable, prefer_is_empty, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/kyc_view.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/payment_details_view.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/profile_setting_view.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/customer_widgets_profile.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/edit_profile.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/menu_item.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_share_post.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_share_view.dart';
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
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _activeButtonIndex = 1;
  SampleItem? selectedMenu;
  List<dynamic> menuList = [];
  List<dynamic> feedList = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  Future<void> _loading() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Auth>(context, listen: false)
        .getFeed(Provider.of<Auth>(context, listen: false).userData?['user_id'])
        .then((feed) {
      setState(() {
        feedList = [];
        feedList.addAll(feed);
        _isLoading = false;
        _refreshController.refreshCompleted();
      });
    });
    await Provider.of<Auth>(context, listen: false)
        .getMenu(Provider.of<Auth>(context, listen: false).userData?['user_id'])
        .then((menu) {
      setState(() {
        menuList = [];
        menuList.addAll(menu);
        _isLoading = false;
        _refreshController.refreshCompleted();
      });
      final feedData = json.encode(
        {
          'menu': menu,
        },
      );
      prefs.setString('menuData', feedData);
    });
  }

  bool _isLoading = false;
  ScrollController t1 = new ScrollController();
  List<String> categories = [];
  String userType = "";
  Map<String, dynamic>? userData;

  Future<void> getUserDataFromPref() async {
    userData = UserPreferences.getUser();
  }

  Future<void> _getMenu() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('menuData')) {
      setState(() {
        final extractedUserData =
            json.decode(prefs.getString('menuData')!) as Map<String, dynamic>;
        print(extractedUserData);
        menuList = [];
        menuList.addAll(extractedUserData['menu'] as List<dynamic>);
        _isLoading = false;
      });
    } else {
      await Provider.of<Auth>(context, listen: false)
          .getMenu(
              Provider.of<Auth>(context, listen: false).userData?['user_id'])
          .then((menu) {
        menuList = [];
        menuList.addAll(menu);
        _isLoading = false;
        /* setState(() {

        });*/
        final menuData = json.encode(
          {
            'menu': menu,
          },
        );
        prefs.setString('menuData', menuData);
      });
    }
    for (var item in menuList) {
      if (item.containsKey('category')) {
        String category = item['category'];
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }
  }

  Future<void> _getFeed() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Auth>(context, listen: false)
        .getFeed(Provider.of<Auth>(context, listen: false).userData?['user_id'])
        .then((feed) {
      setState(() {
        feedList = [];
        feedList.addAll(feed);
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<Auth>(context, listen: false).userData =
        UserPreferences.getUser();
    _getFeed();
    _getMenu();
    userType = Provider.of<Auth>(context, listen: false).userData?['user_type'];
  }

  @override
  Widget build(BuildContext context) {
    print("check user login user ${userType}");
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';
    Color boxShadowColor;

    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
    }

    return SmartRefresher(
      onRefresh: _loading,
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onLoading: _loading,
      child: SingleChildScrollView(
        controller: t1,
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
                                CustomIconButton(
                                  text: '',
                                  ic: Icons.qr_code,
                                  onTap: () {
                                    print(" profilepic"+ Provider.of<Auth>(context,
                                            listen: false)
                                        .userData?['profile_photo']);
                                    context
                                        .read<TransitionEffect>()
                                        .setBlurSigma(5.0);
                                    ProfileShareBottomSheet()
                                        .AddAddressSheet(context);
                                  },
                                ),
                                Container(
                                  // width: 40.w,
                                  padding: EdgeInsets.only(left: 10.w),
                                  child: const StoreLogoWidget(),
                                ),
                                Row(
                                  children: [
                                    CustomIconButton(
                                      boxColor: _isVendor
                                          ? Color.fromRGBO(31, 111, 109, 0.5)
                                          : Color(0xBC73BC).withOpacity(0.6),
                                      // boxColor:
                                      //     const Color.fromRGBO(38, 115, 140, 1),
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
                                              context, 'file size very large');
                                        else if (!url.contains('element')) {
                                          CreateFeed()
                                              .showModalSheetForNewPost(
                                                  context, url, menuList)
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
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ProfileSettingView()));
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: ShapeDecoration(
                                          shadows: [
                                            BoxShadow(
                                              offset: Offset(0, 4),
                                              color: _isVendor
                                                  ? Color.fromRGBO(
                                                      31, 111, 109, 0.5)
                                                  : Color(0xBC73BC)
                                                      .withOpacity(0.6),
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
                                        child: Icon(
                                          Icons.settings,
                                          color: boxShadowColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      StoreNameWidget(),
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
                                //height: 20.h,
                                width: 90.w,
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      offset: Offset(0, 4),
                                      color: Provider.of<Auth>(context,
                                                      listen: false)
                                                  .userData?['user_type'] ==
                                              UserType.Vendor.name
                                          ? const Color.fromRGBO(
                                              165, 200, 199, 0.6)
                                          : Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?['user_type'] ==
                                                  UserType.Supplier.name
                                              ? const Color.fromRGBO(
                                                  77, 191, 74, 0.6)
                                              : const Color.fromRGBO(
                                                  188, 115, 188, 0.6),
                                      blurRadius: 25,
                                    )
                                  ],
                                  color: Colors.white,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 20,
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
                                                  .userData?['rating'] ??
                                              "",
                                          txt: 'Rating',
                                        ),
                                        ColumnWidgetHomeScreen(
                                          data: Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?['followers'] !=
                                                  null
                                              ? (Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?['followers'])
                                                  .length
                                                  .toString()
                                              : "",
                                          txt: 'Followers',
                                        ),
                                        ColumnWidgetHomeScreen(
                                          data: Provider.of<Auth>(context,
                                                              listen: false)
                                                          .userData?[
                                                      'followings'] !=
                                                  null
                                              ? (Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?['followings'])
                                                  .length
                                                  .toString()
                                              : "",
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
                                                            .userData?[
                                                        'store_name']);
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
                                                  'https://app.cloudbelly.in',
                                              link: Uri.parse(
                                                  'https://app.cloudbelly.in/jTpt?id=${Provider.of<Auth>(context, listen: false).userData?['user_id']}&type=profile'),
                                              androidParameters:
                                                  const AndroidParameters(
                                                packageName:
                                                    'com.app.CloudbellyApp',
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
                                            // print(shortUrl);
                                            Share.share("${shortUrl}");
                                          },
                                          child: ButtonWidgetHomeScreen(
                                            txt: 'Share profile',
                                            isActive: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Space(3.h),
                                  ],
                                ),
                              )),
                              Space(3.h),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 100.w,
                          padding: EdgeInsets.symmetric(
                              vertical: 1.5.h, horizontal: 4.w),
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                color: Provider.of<Auth>(context, listen: false)
                                            .userData?['user_type'] ==
                                        UserType.Vendor.name
                                    ? const Color.fromRGBO(165, 200, 199, 0.6)
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Supplier.name
                                        ? const Color.fromRGBO(77, 191, 74, 0.6)
                                        : const Color.fromRGBO(
                                            188, 115, 188, 0.6),
                                blurRadius: 30,
                              )
                            ],
                            color: Colors.white,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 30,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (userType == UserType.Vendor.name)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 1.h, horizontal: 3.w),
                                    width: 55,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFFA6E00),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                    ),
                                  ),
                                Space(2.h),
                                userType == UserType.Supplier.name
                                    ? Container(
                                        // height: 6.5.h,
                                        width: 95.w,

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
                                                      _activeButtonIndex == 1,
                                                  txt: 'Content',
                                                  width: 52,
                                                ),
                                              ),
                                              TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 2;
                                                  });
                                                },
                                                child: CommonButtonProfile(
                                                  isActive:
                                                      _activeButtonIndex == 2,
                                                  txt: 'Menu',
                                                  width: 52,
                                                ),
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
                                                  txt: 'About',
                                                  width: 52,
                                                ),
                                              ),
                                              TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 4;
                                                  });
                                                },
                                                child: CommonButtonProfile(
                                                  isActive:
                                                      _activeButtonIndex == 4,
                                                  txt: 'Reviews',
                                                  width: 52,
                                                ),
                                              ),
                                            ]),
                                      )
                                    : userType == UserType.Customer.name
                                        ? Container(
                                            width: 95.w,
                                            /* decoration: ShapeDecoration(
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
                                        ),*/
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
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
                                                      txt: 'Content',
                                                      width: 52,
                                                    ),
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
                                                      txt: 'Reviews',
                                                      width: 52,
                                                    ),
                                                  ),
                                                ]),
                                          )
                                        : Container(
                                            // height: 6.5.h,
                                            width: 95.w,
                                            /*decoration: ShapeDecoration(
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
                                        ),*/
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  TouchableOpacity(
                                                    onTap: () {
                                                      setState(() {
                                                        _activeButtonIndex = 1;
                                                      });
                                                    },
                                                    child: !_isVendor
                                                        ? CommomButtonProfileCustomer(
                                                            isActive:
                                                                _activeButtonIndex ==
                                                                    1,
                                                            text: 'Content')
                                                        : CommonButtonProfile(
                                                            isActive:
                                                                _activeButtonIndex ==
                                                                    1,
                                                            txt: 'Content',
                                                            width: 52,
                                                          ),
                                                  ),
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
                                                      txt: 'Menu',
                                                      width: 40,
                                                    ),
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
                                                      txt: 'Reviews',
                                                      width: 52,
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                //  _isVendor ? Space(1.h) : Space(0.h),
                                const Space(20),
                                if (_activeButtonIndex == 1)
                                  Center(
                                      // width:
                                      child: _isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : feedList.length == 0
                                              ? Container(
                                                  child: const Center(
                                                      child: Text(
                                                          'No items in Content')),
                                                )
                                              : GridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  // Disable scrolling
                                                  shrinkWrap: true,
                                                  // Allow the GridView to shrink-wrap its content
                                                  addAutomaticKeepAlives: true,

                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 0.8.h,
                                                      horizontal: 0),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 1,
                                                    crossAxisCount:
                                                        3, // Number of items in a row
                                                    crossAxisSpacing:
                                                        _isVendor ? 2.w : 2.w,
                                                    mainAxisSpacing: 1
                                                        .h, // Spacing between rows
                                                  ),
                                                  itemCount: feedList.length,
                                                  // Total number of items
                                                  itemBuilder:
                                                      (context, index) {
                                                    // You can replace this container with your custom item widget
                                                    return FeedWidget(
                                                        index: index,
                                                        fulldata: feedList,
                                                        type: "self",
                                                        isSelfProfile: "Yes",
                                                        userId: Provider.of<
                                                                    Auth>(
                                                                context,
                                                                listen: false)
                                                            .userData?['user_id'],
                                                        data: feedList[index]);
                                                  },
                                                )),
                                if (_activeButtonIndex == 2)
                                  Menu(
                                      isLoading: _isLoading,
                                      menuList: menuList,
                                      categories: categories,
                                      scroll: t1),
                                if (_activeButtonIndex == 3)
                                  const Text('Feature Pending'),
                                if (_activeButtonIndex == 4)
                                  const Text('Feature Pending')
                              ]),
                        ),
                      ),

                      // ignore: avoid_unnecessary_containers
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required bool isLoading,
    required this.menuList,
    required this.categories,
    this.user,
    required this.scroll,
  }) : _isLoading = isLoading;
  final scroll;
  final bool _isLoading;
  final List menuList;
  final List<String> categories;
  // ignore: prefer_typing_uninitialized_variables
  final user;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  TextEditingController _controller = TextEditingController();

  bool _iscategorySearch = false;
  bool _searchOn = false;

  @override
  Widget build(BuildContext context) {
   
    return Container(
      width: 90.w,
      height: 90.h,
      child: Stack(
        children: [
          Column(
            children: [
              widget._isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : widget.menuList.isEmpty
                      ? const SizedBox(
                          // height: 10.h,
                          child: Center(child: Text('No items in Menu')),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        children: [
                                          for (int i = 0;
                                              i < widget.categories.length;
                                              i++)
                                            TouchableOpacity(
                                              onTap: () {
                                                setState(() {
                                                  _iscategorySearch = true;
                                                  _searchOn = true;
                                                  _controller.text =
                                                      widget.categories[i];
                                                });
                                              },
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(right: 5.w),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 1.h,
                                                    horizontal: 5.w),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromRGBO(
                                                      112, 186, 210, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        offset:
                                                            const Offset(5, 5),
                                                        color: const Color
                                                                .fromRGBO(112,
                                                                186, 210, 1)
                                                            .withOpacity(0.5),
                                                        blurRadius: 10)
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    widget.categories[i],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Product Sans',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0,
                                                      letterSpacing: 0.14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Space(12),
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration:
                                      GlobalVariables().ContainerDecoration(
                                    offset: const Offset(0, 4),
                                    blurRadius: 0,
                                    shadowColor: Colors.white,
                                    boxColor:
                                        const Color.fromRGBO(239, 255, 254, 1),
                                    cornerRadius: 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Space(12, isHorizontal: true),
                                      const Icon(
                                        Icons.search,
                                        color: Color(0xFFFA6E00),
                                      ),
                                      const Space(12, isHorizontal: true),
                                      Center(
                                        child: Container(
                                          width: 60.w,
                                          child: TextField(
                                              controller: _controller,
                                              readOnly: false,
                                              maxLines: null,
                                              style: const TextStyle(
                                                color: Color(0xFF094B60),
                                                fontSize: 14,
                                                fontFamily: 'Product Sans',
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.42,
                                              ),
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: const InputDecoration(
                                                hintText: 'Search',
                                                hintStyle: TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0.42,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.only(bottom: 10),
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (newv) {
                                                setState(() {
                                                  _iscategorySearch = false;
                                                  _searchOn = true;
                                                });
                                                if (newv == '') {
                                                  setState(() {
                                                    _searchOn = false;
                                                  });
                                                }
                                              },
                                              cursorColor:
                                                  const Color(0xFFFA6E00)),
                                        ),
                                      ),
                                      const Spacer(),
                                      TouchableOpacity(
                                        onTap: () {
                                          setState(() {
                                            _searchOn = false;
                                            _controller.clear();
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.w),
                                          child: const Icon(
                                            Icons.cancel,
                                            color: Color(0xFFFA6E00),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Space(1.h),
                                if (_iscategorySearch && _searchOn)
                                  for (int index = 0;
                                      index < widget.menuList.length;
                                      index++)
                                    if (widget.menuList[index]['category']
                                        .toString()
                                        .contains(_controller.text))
                                      MenuItem(
                                          data: widget.menuList[index],
                                          scroll: widget.scroll),
                                if (!_iscategorySearch && _searchOn)
                                  for (int index = 0;
                                      index < widget.menuList.length;
                                      index++)
                                    if (widget.menuList[index]['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                            _controller.text.toLowerCase()))
                                      MenuItem(
                                          data: widget.menuList[index],
                                          scroll: widget.scroll),
                                if (!_searchOn)
                                  for (int index = 0;
                                      index < widget.menuList.length;
                                      index++)
                                    MenuItem(
                                        data: widget.menuList[index],
                                        scroll: widget.scroll),
                                Space(2.h),
                              ],
                            ),
                          ),
                        ),
            ],
          ),
          if (Provider.of<Auth>(context).itemAdd.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 7.w),
                width: 80.w,
                height: 75,
                decoration: GlobalVariables().ContainerDecoration(
                  offset: const Offset(3, 6),
                  blurRadius: 20,
                  shadowColor: const Color.fromRGBO(179, 108, 179, 0.5),
                  boxColor: const Color.fromRGBO(123, 53, 141, 1),
                  cornerRadius: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${Provider.of<Auth>(context).itemAdd.length}  Items   | ${Provider.of<Auth>(context).Tpice}  Rs ',
                          style: const TextStyle(
                            color: Color(0xFFF7F7F7),
                            fontSize: 16,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Extra charges may apply',
                          style: TextStyle(
                            color: Color(0xFFF7F7F7),
                            fontSize: 12,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    TouchableOpacity(
                      onTap: () {
                        Provider.of<ViewCartProvider>(context, listen: false)
                            .getProductList(
                                Provider.of<Auth>(context, listen: false)
                                    .itemAdd);
                        Provider.of<ViewCartProvider>(context, listen: false)
                            .setSellterId(widget.user);
                        context.read<TransitionEffect>().setBlurSigma(0);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewCart(),
                          ),
                        );
                      },
                      child: Container(
                        height: 41,
                        width: 113,
                        decoration: ShapeDecoration(
                          color: const Color.fromRGBO(84, 166, 193, 1),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 12,
                              cornerSmoothing: 1,
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'View Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
    required this.userId,
    required this.type,
    required this.isSelfProfile,
    this.userModel,
  });

  final int index;
  final UserModel? userModel;
  final dynamic data;
  final dynamic fulldata;
  final String userId;
  final String type;
  final String isSelfProfile;
  CarouselController buttonCarouselController = CarouselController();

  Color getBackgroundColor(String isSelfProfile, bool isVendor) {
    print("userModel ${userModel?.id}");
    var usertype = userModel?.userType;
    if (isSelfProfile == 'Yes' && isVendor && usertype == 'Vendor') {
      return const Color.fromRGBO(10, 76, 97, 0.31);
    } else if (isSelfProfile == 'Yes' && usertype == 'Customer') {
      return Color(0xBC73BC).withOpacity(0.6);
    } else if (isSelfProfile == 'Yes' && usertype == 'Supplier') {
      return const Color(0xFF4DBF4A);
    } else if (isSelfProfile == 'No' && usertype == 'Vendor') {
      return const Color.fromRGBO(10, 76, 97, 0.31);
    } else if (isSelfProfile == 'No' && usertype == 'Customer') {
      return Color(0xBC73BC).withOpacity(0.6);
    } else if (isSelfProfile == 'No' && usertype == 'Supplier') {
      return const Color(0xFF4DBF4A);
    } else {
      return Colors.grey; // Default color if no conditions match
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';

    return TouchableOpacity(
      onTap: () async {
        print("fullData:: $fulldata");
        final Data = await Provider.of<Auth>(context, listen: false)
            .getFeed(userId) as List<dynamic>;
        print("userId:: $userId");
        Navigator.of(context).pushNamed(PostsScreen.routeName, arguments: {
          'data': Data,
          'index': index,
          "userId": userId,
          "userModel": userModel,
          "type": type,
          "isSelfProfile": isSelfProfile
        });
      },
      child: Stack(
        children: [
          Hero(
            tag: data['id'],
            child: Container(
              height: 110,
              width: 110,
              decoration: ShapeDecoration(
                shadows: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    // color: _isVendor ? const Color.fromRGBO(10, 76, 97, 0.31) :  const Color(0xBC73BC).withOpacity(0.6),
                    color: getBackgroundColor(isSelfProfile, _isVendor),
                    blurRadius: 20,
                  ),
                ],
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 17,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 25,
                  cornerSmoothing: 1,
                ),
                child: Image.network(
                  data['file_path'],
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
              ),
            ),
          ),
          if (data['multiple_files'] != null &&
              data['multiple_files'].length != 0)
            const Positioned(
              top: 5,
              right: 5,
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
  double width;

  CommonButtonProfile({
    super.key,
    required this.isActive,
    required this.txt,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        // height: 4.4.h,
        // width: 25.w,
        //  padding: EdgeInsets.all(08),

        /* decoration: isActive
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
            : const ShapeDecoration(shape: SmoothRectangleBorder()),*/
        child: Center(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 13.0),
                  child: Text(
                    txt,
                    style: const TextStyle(
                      color: /*isActive ? Colors.white :*/ Color(0xFF094B60),
                      fontSize: 14,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      height: 0.10,
                      letterSpacing: 0.42,
                    ),
                  ),
                ),
                Container(
                  //  padding: EdgeInsets.only(top: 7),
                  width: width,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: !isActive ? Colors.white : const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
