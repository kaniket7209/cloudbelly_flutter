// ignore_for_file: must_be_immutable, prefer_is_empty, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory_bottom_sheet.dart';
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
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    // _refreshController.refreshCompleted();
    _scrollToTop(); // Ensure the scroll jumps to the top after refresh
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      t1.animateTo(
        MediaQuery.sizeOf(context).height / 2.5, // Scroll to the top
        duration:
            const Duration(milliseconds: 300), // Duration of the animation
        curve: Curves.linearToEaseOut, // Curve of the animation
      );
    });
  }

  @override
  void dispose() {
    t1.dispose();
    super.dispose();
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
      });
    });
    await Provider.of<Auth>(context, listen: false)
        .getMenu(Provider.of<Auth>(context, listen: false).userData?['user_id'])
        .then((menu) {
      setState(() {
        menuList = [];
        menuList.addAll(menu);
        _isLoading = false;
      });
      final feedData = json.encode({
        'menu': menu,
      });
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

    return RefreshIndicator(
      onRefresh: _loading,
      // controller: _refreshController,
      // enablePullDown: true,
      // enablePullUp: false,
      // onLoading: _loading,
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
                                    print(" profilepic" +
                                        Provider.of<Auth>(context,
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
                                      2.w,
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
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          Make_Profile_ListWidget(
                                            color: Color(0xFFFA6E00),
                                            onTap: () {
                                              AppWideBottomSheet().showSheet(
                                                  context,
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Space(1.h),
                                                        const Text(
                                                          '  Scan your menu',
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
                                                        TouchableOpacity(
                                                          onTap: () async {
                                                            AppWideLoadingBanner()
                                                                .loadingBanner(
                                                                    context);
                                                            dynamic data =
                                                                await Provider.of<
                                                                            Auth>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .ScanMenu(
                                                                        'Gallery');
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            if (data ==
                                                                'file size very large') {
                                                              TOastNotification()
                                                                  .showErrorToast(
                                                                      context,
                                                                      'file size very large');
                                                            } else if (data !=
                                                                    'No image picked' &&
                                                                data != '') {
                                                              ScannedMenuBottomSheet(
                                                                  context,
                                                                  data['data'],
                                                                  true);
                                                            }
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .photo_album_outlined),
                                                                Space(
                                                                    isHorizontal:
                                                                        true,
                                                                    15),
                                                                Text(
                                                                  'Upload from gallery',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF094B60),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Product Sans',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height:
                                                                        0.10,
                                                                    letterSpacing:
                                                                        0.36,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TouchableOpacity(
                                                          onTap: () async {
                                                            AppWideLoadingBanner()
                                                                .loadingBanner(
                                                                    context);
                                                            dynamic data =
                                                                await Provider.of<
                                                                            Auth>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .ScanMenu(
                                                                        'Camera');
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            // print(data);
                                                            if (data ==
                                                                'file size very large') {
                                                              TOastNotification()
                                                                  .showErrorToast(
                                                                      context,
                                                                      'file size very large');
                                                            } else if (data !=
                                                                    'No image picked' &&
                                                                data != '') {
                                                              ScannedMenuBottomSheet(
                                                                  context,
                                                                  data['data'],
                                                                  true);
                                                            }
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .camera),
                                                                Space(
                                                                    isHorizontal:
                                                                        true,
                                                                    15),
                                                                Text(
                                                                  'Click photo',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF094B60),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Product Sans',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height:
                                                                        0.10,
                                                                    letterSpacing:
                                                                        0.36,
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

                      // bottom - panel
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
                                // if (userType == UserType.Vendor.name)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1.h, horizontal: 3.w),
                                  width: 55,
                                  height: 6,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFFA6E00),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
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
                                                    print(
                                                        "menuList.length ${menuList.length}");
                                                    if (menuList.length != 0)
                                                      _scrollToTop();
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
                                                       
                                                        if (menuList.length !=
                                                            0) _scrollToTop();
                                                      });

                                                      // Ensure the scroll happens after the frame is built
                                                      //                                                   WidgetsBinding.instance.addPostFrameCallback((_) {
                                                      //   t1.jumpTo(500.0); // Scroll to the top
                                                      // });
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
                                                  height:
                                                      MediaQuery.sizeOf(context)
                                                              .height /
                                                          2.7,
                                                  child: Center(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'No items  ',
                                                        style: TextStyle(
                                                            color: boxShadowColor
                                                                .withOpacity(
                                                                    0.2),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 35,
                                                            fontFamily:
                                                                'Product Sans'),
                                                      ),
                                                      Text(
                                                        'in content  ',
                                                        style: TextStyle(
                                                            color: boxShadowColor
                                                                .withOpacity(
                                                                    0.2),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 35,
                                                            fontFamily:
                                                                'Product Sans'),
                                                      ),
                                                      const SizedBox(
                                                        height: 100,
                                                      )
                                                    ],
                                                  )),
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
                                    scroll: t1,
                                  ),
                                if (_activeButtonIndex == 3)
                                  Container(
                                    height:
                                        MediaQuery.sizeOf(context).height / 2.7,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No reviews',
                                          style: TextStyle(
                                              color: boxShadowColor
                                                  .withOpacity(0.2),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35,
                                              fontFamily: 'Product Sans'),
                                        ),
                                        const SizedBox(
                                          height: 100,
                                        )
                                      ],
                                    )),
                                  ),

                                if (_activeButtonIndex == 4)
                                  Container(
                                    height:
                                        MediaQuery.sizeOf(context).height / 2.7,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No data',
                                          style: TextStyle(
                                              color: boxShadowColor
                                                  .withOpacity(0.2),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35,
                                              fontFamily: 'Product Sans'),
                                        ),
                                        const SizedBox(
                                          height: 100,
                                        )
                                      ],
                                    )),
                                  )
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

class Make_Profile_ListWidget extends StatelessWidget {
  String txt;
  final Function? onTap;
  Color? color;

  Make_Profile_ListWidget({
    super.key,
    required this.txt,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Container(
          height: 41,
          width: 125,
          decoration: ShapeDecoration(
            shadows: const [
              BoxShadow(
                  offset: Offset(0, 4),
                  spreadRadius: 0.1,
                  color: Color.fromRGBO(232, 128, 55, 0.5),
                  blurRadius: 10)
            ],
            color: color ?? const Color.fromRGBO(84, 166, 193, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              txt,
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
    );
  }
}

Future<dynamic> ScannedMenuBottomSheet(
    BuildContext context, dynamic data, bool isUpload) {
  // bool isEditing = false;/
  // TextEditingController textEditingController = TextEditingController();
  // String text = 'Click me to edit';

  List<Map<String, dynamic>> list = [];

  for (var item in data) {
    var newItem = Map<String, dynamic>.from(item);
    isUpload
        ? newItem['VEG'] = true
        : newItem['VEG'] = newItem['VEG']; // Adding VEG element with value true
    list.add(newItem);

    list.reversed;
  }
  var uniqueCategories = data.map((e) => e['category']).toSet();

  // Counting the number of unique categories
  var numberOfCategories = uniqueCategories.length;

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
                    Space(1.h),
                    if (isUpload)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TouchableOpacity(
                            onTap: () {
                              setState(() {
                                list.insert(0, {
                                  'category': 'Category',
                                  'name': 'Item',
                                  'price': '00.00',
                                  'VEG': true
                                });
                              });
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
                                    'Add more  +  ',
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
                    Space(2.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isUpload ? 'Scan complete' : 'Edit your menu',
                          style: const TextStyle(
                            color: Color(0xFF094B60),
                            fontSize: 30,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.02,
                            letterSpacing: 0.90,
                          ),
                        ),
                        const Text(
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
                    if (isUpload) Space(5.h),
                    if (isUpload)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            'Categories Scanned',
                            style: TextStyle(
                              color: Color(0xFF1E6F6D),
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                              letterSpacing: 0.42,
                            ),
                          ),
                          Text(
                            numberOfCategories.toString(),
                            style: const TextStyle(
                              color: Color(0xFFFA6E00),
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w700,
                              height: 0.10,
                              letterSpacing: 0.42,
                            ),
                          ),
                          const Text(
                            'Products Scanned',
                            style: TextStyle(
                              color: Color(0xFF1E6F6D),
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 0.10,
                              letterSpacing: 0.42,
                            ),
                          ),
                          Text(
                            (data as List<dynamic>).length.toString(),
                            style: const TextStyle(
                              color: Color(0xFFFA6E00),
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w700,
                              height: 0.10,
                              letterSpacing: 0.42,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SheetLabelWidget(
                          txt: 'Product',
                          width: 25.w,
                        ),
                        SheetLabelWidget(
                          txt: 'Price',
                          width: 22.w,
                        ),
                        SheetLabelWidget(
                          txt: 'V/N',
                          width: 15.w,
                        ),
                        Space(
                          5.w,
                          isHorizontal: true,
                        ),
                        SheetLabelWidget(
                          txt: 'Category',
                          width: 20.w,
                        ),
                      ],
                    ),
                    Space(1.h),
                    const Divider(
                      color: Color(0xFFFA6E00),
                    ),
                    Space(1.5.h),
                    Column(
                      children: List.generate((list as List<dynamic>).length,
                          (index) {
                        print(list[index]);
                        TextEditingController nameController =
                            TextEditingController(
                          text: list[index]['name'],
                        );
                        TextEditingController priceController =
                            TextEditingController(
                          text: list[index]['price'],
                        );
                        TextEditingController categoryController =
                            TextEditingController(
                          text: list[index]['category'],
                        );

                        return Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 25.w,
                                child: TextField(
                                  maxLines: null,
                                  style: const TextStyle(
                                    color: Color(0xFF094B60),
                                    fontSize: 13,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (newValue) async {
                                    if (!isUpload) {
                                      await Provider.of<Auth>(context,
                                              listen: false)
                                          .updateMenuItem(
                                        list[index]['_id'],
                                        list[index]['price'],
                                        newValue,
                                        list[index]['VEG'],
                                        list[index]['category'],
                                      );
                                    }
                                    setState(() {
                                      list[index]['name'] = newValue;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    const Text(
                                      'Rs ',
                                      style: TextStyle(
                                        color: Color(0xFF094B60),
                                        fontSize: 13,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                      child: TextField(
                                        style: const TextStyle(
                                          color: Color(0xFF094B60),
                                          fontSize: 13,
                                          fontFamily: 'Product Sans',
                                          fontWeight: FontWeight.w400,
                                        ),
                                        controller: priceController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (newValue) async {
                                          if (!isUpload) {
                                            await Provider.of<Auth>(context,
                                                    listen: false)
                                                .updateMenuItem(
                                              list[index]['_id'],
                                              newValue,
                                              list[index]['name'],
                                              list[index]['VEG'],
                                              list[index]['category'],
                                            );
                                          }
                                          setState(() {
                                            list[index]['price'] = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                                child: Transform.scale(
                                  scale: 0.9,
                                  child: CupertinoSwitch(
                                    value: !list[index]['VEG'],
                                    onChanged: (value) async {
                                      if (!isUpload) {
                                        await Provider.of<Auth>(context,
                                                listen: false)
                                            .updateMenuItem(
                                          list[index]['_id'],
                                          list[index]['price'],
                                          list[index]['name'],
                                          !value,
                                          list[index]['category'],
                                        );
                                      }
                                      setState(() {
                                        list[index]['VEG'] = !value;
                                      });
                                    },
                                    activeColor:
                                        const Color.fromRGBO(232, 89, 89, 1),
                                    trackColor:
                                        const Color.fromRGBO(77, 171, 75, 1),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 20.w,
                                child: TextField(
                                  maxLines: null,
                                  style: const TextStyle(
                                    color: Color(0xFF094B60),
                                    fontSize: 13,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  controller: categoryController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (newValue) async {
                                    if (!isUpload) {
                                      await Provider.of<Auth>(context,
                                              listen: false)
                                          .updateMenuItem(
                                              list[index]['_id'],
                                              list[index]['price'],
                                              list[index]['name'],
                                              list[index]['VEG'],
                                              newValue);
                                    }
                                    setState(() {
                                      list[index]['category'] = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    Space(1.h),
                    if (isUpload)
                      AppWideButton(
                        onTap: () async {
                          // Show loading banner
                          AppWideLoadingBanner().loadingBanner(context);

                          // Call the API to add products
                          final code =
                              await Provider.of<Auth>(context, listen: false)
                                  .AddProductsForMenu(list);
                          Navigator.of(context).pop(); // Remove loading banner
                          print("code $code"); // Debug print

                          if (code == '200') {
                            // Ensure code is compared as an integer
                            TOastNotification().showSuccesToast(
                                context, 'Menu Uploaded successfully');

                            AppWideBottomSheet().showSheet(
                                context,
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                20,
                                        padding: const EdgeInsets.all(
                                            8.0), // Add padding for better readability
                                        child: const Text(
                                          'Do you want to generate description and type using AI',
                                          style: TextStyle(
                                            color: Color(0xFF094B60),
                                            fontSize: 24,
                                            fontFamily: 'Jost',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.78,
                                          ),
                                          softWrap:
                                              true, // Enable soft wrapping
                                        ),
                                      ),
                                      Space(3.h),
                                      TouchableOpacity(
                                        onTap: () async {
                                          // Show loading banner
                                          AppWideLoadingBanner()
                                              .loadingBanner(context);

                                          // Call the API to update description and type

                                          final updateCode =
                                              await Provider.of<Auth>(context,
                                                      listen: false)
                                                  .updateDescriptionAndType();
                                          Navigator.of(context)
                                              .pop(); // Remove loading banner
                                          print(
                                              "code upd $updateCode"); // Debug print

                                          if (updateCode == '200') {
                                            // Ensure updateCode is compared correctly
                                            TOastNotification().showSuccesToast(
                                                context,
                                                'Menu Updated successfully');
                                            Navigator.of(context)
                                                .pop(); // Close the bottom sheet
                                            Navigator.of(context)
                                                .pop(); // Close the bottom sheet
                                          } else {
                                            TOastNotification().showErrorToast(
                                                context,
                                                'Error happened while updating menu');
                                            Navigator.of(context)
                                                .pop(); // Close the bottom sheet
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.done_rounded,
                                                color: Colors.green,
                                              ),
                                              Space(isHorizontal: true, 15),
                                              Text(
                                                'Yes, I know it can be edited as well',
                                                style: TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
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
                                          print("Closing bar");
                                          Navigator.of(context)
                                              .pop(); // Close the bottom sheet
                                          Navigator.of(context)
                                              .pop(); // Close the previous bottom sheet
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.close_rounded,
                                                color: Colors.red,
                                              ),
                                              Space(isHorizontal: true, 15),
                                              Text(
                                                'No, I want to add it manually',
                                                style: TextStyle(
                                                  color: Color(0xFF094B60),
                                                  fontSize: 14,
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
                                30.h);
                          } else {
                            TOastNotification().showErrorToast(
                                context, 'Unexpected error. Please try again');
                            Navigator.of(context)
                                .pop(); // Remove loading banner
                          }
                        },
                        num: 1,
                        txt: 'Complete menu upload',
                      ),
                    Space(2.h),
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
  // @override
  // void initState() {
  //   super.initState();

  //   // Scroll to the top 10 items after the first frame is rendered

  // }

  @override
  Widget build(BuildContext context) {
    String userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
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
                      ? Container(
                          height: MediaQuery.sizeOf(context).height / 2.7,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'No items  ',
                                style: TextStyle(
                                    color: boxShadowColor.withOpacity(0.2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                    fontFamily: 'Product Sans'),
                              ),
                              Text(
                                'in menu  ',
                                style: TextStyle(
                                    color: boxShadowColor.withOpacity(0.2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                    fontFamily: 'Product Sans'),
                              ),
                              const SizedBox(
                                height: 100,
                              )
                            ],
                          )),
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
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
                                              decoration: ShapeDecoration(
                                                color: const Color.fromRGBO(
                                                    112, 186, 210, 1),
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius(
                                                    cornerRadius: 11,
                                                    cornerSmoothing: 1,
                                                  ),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: const Color.fromRGBO(
                                                            112, 186, 210, 1)
                                                        .withOpacity(0.8),
                                                    spreadRadius: 0,
                                                    blurRadius: 10,
                                                    offset: Offset(1, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  widget.categories[i],
                                                  style: const TextStyle(
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
                              ),
                              const Space(1),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                              const Space(10),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
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
                                              .contains(_controller.text
                                                  .toLowerCase()))
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
                                      const SizedBox(height: 150),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
            ],
          ),
          if (Provider.of<Auth>(context).itemAdd.isNotEmpty)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
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
                          shadows: const [
                            BoxShadow(
                              offset: Offset(3, 6),
                              color: Color(0xff4F215B),
                              blurRadius: 20,
                            ),
                          ],
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
    String? userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color colorProfile;
    if (userType == 'Vendor') {
      colorProfile = const Color(0xFF094B60);
    } else if (userType == 'Customer') {
      colorProfile = const Color(0xFF2E0536);
    } else if (userType == 'Supplier') {
      colorProfile = Color.fromARGB(255, 26, 48, 10);
    } else {
      colorProfile = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }
    return Container(
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
                    style: TextStyle(
                      color: colorProfile,
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
