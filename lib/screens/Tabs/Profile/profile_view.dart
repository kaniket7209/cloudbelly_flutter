import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/customer_widgets_profile.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/menu_item.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileView extends StatefulWidget {
  List<String> userIdList = [];

  ProfileView({super.key, required this.userIdList});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _activeButtonIndex = 1;

  SampleItem? selectedMenu;
  List<dynamic> menuList = [];
  List<dynamic> feedList = [];
  List<UserModel> userList = [];
  bool _isFollowing = false;
  bool _isLoad = false;
  String countFollowers = '';
  String countFollowings = '';
  ScrollController t1 = new ScrollController();
  String kycStatus = 'not verified';

  bool checkFollow() {
    String id = widget.userIdList.first;
    List<dynamic> temp =
        // userList.first.followings
        Provider.of<Auth>(context, listen: false).userData?['followings'];
    for (var user in temp) {
      if (user['user_id'] == id) {
        _isFollowing = true;
        return true;
      }
    }
    return false;
  }

  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  void _onRefresh() async {
    try {
      await getUserInfo(widget.userIdList);
      await _getFeed();
      await _getMenu();
      // _refreshController.refreshCompleted();
      _scrollToTop();
    } catch (error) {
      // _refreshController.refreshFailed();
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      t1.animateTo(
        MediaQuery.sizeOf(context).height / 2.9, // Scroll to the top
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

  Future<void> getUserInfo(List<String> userIds) async {
    // AppWideLoadingBanner().loadingBanner(context);
    // _isLoad = true;

    userList =
        await Provider.of<Auth>(context, listen: false).getUserDetails(userIds);
    // print(" viewProfi ${userList.first.followers?.length}  followers ${userList.first.followings?.length}  followings  ");
    // _isLoad = false;
    List<dynamic> fetchedUserDetails =
        await Provider.of<Auth>(context, listen: false).getUserInfo(userIds);
    if (fetchedUserDetails[0] != null) {
      kycStatus = fetchedUserDetails[0]!['kyc_status'];
    }

    //Navigator.pop(context);
  }

  Future<void> _loading() async {
    getUserInfo(widget.userIdList);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Auth>(context, listen: false)
        .getFeed(widget.userIdList.first)
        .then((feed) {
      setState(() {
        feedList = [];
        feedList.addAll(feed);
        _isLoading = false;
        // _refreshController.refreshCompleted();
      });
    });
    await Provider.of<Auth>(context, listen: false)
        .getMenu(widget.userIdList.first)
        .then((menu) {
      setState(() {
        menuList = [];
        menuList.addAll(menu);
        _isLoading = false;
        // _refreshController.refreshCompleted();
      });
      final feedData = json.encode(
        {'menu': menu, 'kyc_status': kycStatus},
      );
      prefs.setString('menuData', feedData);
    });
  }

  bool _isLoading = false;
  List<String> categories = [];
  String userType = "";

  Future<void> _getMenu() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    await Provider.of<Auth>(context, listen: false)
        .getMenu(widget.userIdList.first)
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
        .getFeed(widget.userIdList.first)
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
    Future.delayed(Duration.zero, () {
      final userId = ModalRoute.of(context)?.settings.arguments as String?;
      if (userId != null) {
        widget.userIdList = [userId];
      }
      _loadAllData();
    });
  }

  void _loadAllData() {
    getUserInfo(widget.userIdList);
    _getFeed();
    _getMenu();
    userType = Provider.of<Auth>(context, listen: false).userData?['user_type'];
  }

  @override
  Widget build(BuildContext context) {
    bool _isFollowing = checkFollow();
    String? userType =
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

    Color sharedProfileColour(userType) {
      Color profileColour;
      // userType= userList.first.userType;
      if (userType == 'Vendor') {
        profileColour = const Color(0xff0A4C61);
      } else if (userType == 'Customer') {
        profileColour = const Color(0xff2E0536);
      } else if (userType == 'Supplier') {
        profileColour = Color.fromARGB(0, 115, 188, 150);
      } else {
        profileColour = const Color.fromRGBO(77, 191, 74, 0.6);
      }
      return profileColour;
    }

    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';
    return Scaffold(
      backgroundColor:
          Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                  UserType.Vendor.name
              ? const Color.fromRGBO(234, 245, 247, 1)
              : userType == UserType.Supplier.name
                  ? const Color(0xFFF6FFEE)
                  : const Color.fromRGBO(255, 248, 255, 1),
      body: RefreshIndicator(
        onRefresh: _loading,
        // controller: _refreshController,
        // enablePullDown: true,
        // enablePullUp: false,
        // onLoading: _loading,
        child: userList.isNotEmpty
            ? SingleChildScrollView(
                controller: t1,
                child: _isLoad == false
                    ? Container(
                        constraints: const BoxConstraints(
                          maxWidth: 800, // Set your maximum width here
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth:
                                          800, // Set the maximum width to 800
                                    ),
                                    child: Container(
                                      width: 100.w,
                                      height: 23.3.h,
                                      decoration: ShapeDecoration(
                                        color: userList.first.userType ==
                                                UserType.Vendor.name
                                            ? const Color.fromRGBO(
                                                165, 200, 199, 0.6)
                                            : userList.first.userType ==
                                                    UserType.Supplier.name
                                                ? const Color.fromRGBO(
                                                    77, 191, 74, 0.6)
                                                : const Color(0xBC73BC)
                                                    .withOpacity(0.5),
                                        shape: const SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius.only(
                                              bottomLeft: SmoothRadius(
                                                  cornerRadius: 40,
                                                  cornerSmoothing: 1),
                                              bottomRight: SmoothRadius(
                                                  cornerRadius: 40,
                                                  cornerSmoothing: 1)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Space(6.h),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth:
                                            800, // Set the maximum width to 800
                                      ),
                                      child: Center(
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CustomIconButton(
                                                  text: 'back',
                                                  ic: Icons
                                                      .arrow_back_ios_new_outlined,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  color: sharedProfileColour(
                                                          userList
                                                              .first.userType)
                                                      .withOpacity(0.4)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Space(2.h),
                                    Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth:
                                              420, // Set the maximum width to 800
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
                                                    offset: const Offset(0, 4),
                                                    color: userList.first
                                                                .userType ==
                                                            UserType.Vendor.name
                                                        ? const Color.fromRGBO(
                                                            165, 200, 199, 0.6)
                                                        : userList.first
                                                                    .userType ==
                                                                UserType
                                                                    .Supplier
                                                                    .name
                                                            ? const Color
                                                                .fromRGBO(77,
                                                                191, 74, 0.6)
                                                            : const Color
                                                                .fromRGBO(188,
                                                                115, 188, 0.6),
                                                    blurRadius: 25,
                                                  )
                                                ],
                                                color: Colors.white,
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius(
                                                    cornerRadius: 53,
                                                    cornerSmoothing: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Space(3.h),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: 15,
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10),
                                                        child: userList.first
                                                                    .profilePhoto !=
                                                                null
                                                            ? Container(
                                                                height: 70,
                                                                width: 70,
                                                                decoration:
                                                                    ShapeDecoration(
                                                                  shadows: [
                                                                    BoxShadow(
                                                                      offset:
                                                                          Offset(
                                                                              1,
                                                                              4),
                                                                      color: userList.first.userType ==
                                                                              UserType
                                                                                  .Vendor.name
                                                                          ? const Color
                                                                              .fromRGBO(
                                                                              165,
                                                                              200,
                                                                              199,
                                                                              0.6)
                                                                          : userList.first.userType == UserType.Supplier.name
                                                                              ? const Color.fromRGBO(77, 191, 74, 0.6)
                                                                              : const Color.fromRGBO(188, 115, 188, 0.6),
                                                                      blurRadius:
                                                                          20,
                                                                    )
                                                                  ],
                                                                  shape:
                                                                      SmoothRectangleBorder(),
                                                                ),
                                                                child:
                                                                    ClipSmoothRect(
                                                                  radius:
                                                                      SmoothBorderRadius(
                                                                    cornerRadius:
                                                                        22,
                                                                    cornerSmoothing:
                                                                        1,
                                                                  ),
                                                                  child: Image
                                                                      .network(
                                                                    userList.first
                                                                            .profilePhoto ??
                                                                        "",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    loadingBuilder:
                                                                        GlobalVariables()
                                                                            .loadingBuilderForImage,
                                                                    errorBuilder:
                                                                        GlobalVariables()
                                                                            .ErrorBuilderForImage,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: 70,
                                                                width: 70,
                                                                decoration:
                                                                    ShapeDecoration(
                                                                  shadows: [
                                                                    BoxShadow(
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              4),
                                                                      color: userList.first.userType ==
                                                                              UserType.Vendor.name
                                                                          ? const Color(0xff1F6F6D).withOpacity(0.4)
                                                                          : userList.first.userType == UserType.Supplier.name
                                                                              ? const Color.fromRGBO(77, 191, 74, 0.6)
                                                                              : const Color.fromRGBO(188, 115, 188, 0.6),
                                                                      blurRadius:
                                                                          20,
                                                                    ),
                                                                  ],
                                                                  color: userList
                                                                              .first
                                                                              .userType ==
                                                                          UserType
                                                                              .Vendor
                                                                              .name
                                                                      ? const Color(0xff1F6F6D)
                                                                          .withOpacity(
                                                                              0.4)
                                                                      : userList.first.userType ==
                                                                              UserType
                                                                                  .Supplier.name
                                                                          ? const Color
                                                                              .fromRGBO(
                                                                              77,
                                                                              191,
                                                                              74,
                                                                              0.6)
                                                                          : const Color
                                                                              .fromRGBO(
                                                                              188,
                                                                              115,
                                                                              188,
                                                                              0.6),
                                                                  shape:
                                                                      SmoothRectangleBorder(
                                                                          borderRadius:
                                                                              SmoothBorderRadius(
                                                                    cornerRadius:
                                                                        22,
                                                                    cornerSmoothing:
                                                                        1,
                                                                  )),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    userList
                                                                        .first
                                                                        .storeName![
                                                                            0]
                                                                        .toUpperCase(),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            40),
                                                                  ),
                                                                )),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                        width: 50.w,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              userList.first
                                                                      .storeName ??
                                                                  'Unknown', // Provide a default value
                                                              style: TextStyle(
                                                                  color: sharedProfileColour(
                                                                      userList
                                                                          .first
                                                                          .userType),
                                                                  fontFamily:
                                                                      'Ubuntu',
                                                                  fontSize: 22,
                                                                  letterSpacing:
                                                                      1,
                                                                  height: 1,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              userList.first
                                                                      .userType ??
                                                                  'Unknown', // Provide a default value
                                                              style: TextStyle(
                                                                color: sharedProfileColour(
                                                                    userList
                                                                        .first
                                                                        .userType),
                                                                fontFamily:
                                                                    'Product Sans',
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          final phoneNumber =
                                                              userList.first
                                                                      .phone ??
                                                                  '';
                                                          print(
                                                              "Phone number length: $phoneNumber (${phoneNumber.length})");

                                                          // Check if the phone number is a 10-digit number
                                                          if (phoneNumber
                                                                  .length ==
                                                              10) {
                                                            final whatsappUrl =
                                                                'https://wa.me/91$phoneNumber';
                                                            print(
                                                                "Launching WhatsApp URL: $whatsappUrl");

                                                            // Check if the URL can be launched
                                                            _launchURL(
                                                                whatsappUrl);
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'WhatsApp number is incorrect. It is not a 10-digit number.')),
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 7, 12, 2),
                                                          child: Image.asset(
                                                              'assets/images/WhatsApp.png',
                                                              width: 27),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      ColumnWidgetHomeScreen(
                                                        data: Provider.of<Auth>(
                                                                context,
                                                                listen: false)
                                                            .userData?['rating'],
                                                        txt: 'Rating',
                                                        color:
                                                            sharedProfileColour(
                                                                userList.first
                                                                    .userType),
                                                      ),
                                                      ColumnWidgetHomeScreen(
                                                          data: userList
                                                                  .first
                                                                  .followers
                                                                  ?.length
                                                                  .toString() ??
                                                              "",
                                                          txt: 'Followers',
                                                          color:
                                                              sharedProfileColour(
                                                                  userList.first
                                                                      .userType)),
                                                      ColumnWidgetHomeScreen(
                                                          data: userList
                                                                  .first
                                                                  .followings
                                                                  ?.length
                                                                  .toString() ??
                                                              "",
                                                          txt: 'Following',
                                                          color:
                                                              sharedProfileColour(
                                                                  userList.first
                                                                      .userType))
                                                    ],
                                                  ),
                                                  Space(2.h),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      if (widget.userIdList
                                                              .first !=
                                                          Provider.of<Auth>(
                                                                  context,
                                                                  listen: false)
                                                              .userData?['user_id'])
                                                        TouchableOpacity(
                                                          onTap: () async {
                                                            if (!_isFollowing) {
                                                              final dynamic response = await Provider.of<
                                                                          Auth>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .follow(widget
                                                                      .userIdList
                                                                      .first);
                                                              getUserInfo(widget
                                                                  .userIdList);
                                                              if (response[
                                                                      'code'] ==
                                                                  200) {
                                                                TOastNotification()
                                                                    .showSuccesToast(
                                                                        context,
                                                                        response['body']
                                                                            [
                                                                            'message']);
                                                                Provider.of<Auth>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .userData?[
                                                                        'followings']
                                                                    .add({
                                                                  'user_id': widget
                                                                      .userIdList
                                                                      .first
                                                                });
                                                                setState(() {
                                                                  _isFollowing =
                                                                      true;
                                                                });
                                                              } else {
                                                                TOastNotification()
                                                                    .showErrorToast(
                                                                        context,
                                                                        response['body']
                                                                            [
                                                                            'message']);
                                                              }
                                                            } else {
                                                              final dynamic response = await Provider.of<
                                                                          Auth>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .unfollow(widget
                                                                      .userIdList
                                                                      .first);
                                                              if (response[
                                                                      'code'] ==
                                                                  200) {
                                                                TOastNotification()
                                                                    .showSuccesToast(
                                                                        context,
                                                                        response['body']
                                                                            [
                                                                            'message']);
                                                                Provider.of<Auth>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .userData?[
                                                                        'followings']
                                                                    .removeWhere((element) =>
                                                                        element[
                                                                            'user_id'] ==
                                                                        widget
                                                                            .userIdList
                                                                            .first);
                                                                getUserInfo(widget
                                                                    .userIdList);
                                                                setState(() {
                                                                  _isFollowing =
                                                                      false;
                                                                });
                                                              } else {
                                                                TOastNotification()
                                                                    .showErrorToast(
                                                                        context,
                                                                        response['body']
                                                                            [
                                                                            'message']);
                                                              }
                                                            }
                                                            print(Provider.of<
                                                                            Auth>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .userData?[
                                                                'followings']);
                                                          },
                                                          child: ButtonWidgetHomeScreen(
                                                              txt: _isFollowing
                                                                  ? 'Unfollow'
                                                                  : 'Follow',
                                                              isActive: true),
                                                        ),
                                                    ],
                                                  ),
                                                  Space(2.h),
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
                                              color: userList.first.userType ==
                                                      UserType.Vendor.name
                                                  ? const Color.fromRGBO(
                                                      165, 200, 199, 0.6)
                                                  : userList.first.userType ==
                                                          UserType.Supplier.name
                                                      ? const Color.fromRGBO(
                                                          77, 191, 74, 0.6)
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              if (_isVendor)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 1.h,
                                                      horizontal: 3.w),
                                                  width: 30,
                                                  height: 6,
                                                  decoration: ShapeDecoration(
                                                    color:
                                                        const Color(0xFFFA6E00)
                                                            .withOpacity(0.5),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                  ),
                                                ),
                                              Space(2.h),
                                              userList.first.userType ==
                                                      UserType.Supplier.name
                                                  ? Container(
                                                      width: 95.w,
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            TouchableOpacity(
                                                              onTap: () {
                                                                setState(() {
                                                                  _activeButtonIndex =
                                                                      1;
                                                                });
                                                              },
                                                              child: CommonButtonProfile(
                                                                  isActive:
                                                                      _activeButtonIndex ==
                                                                          1,
                                                                  txt:
                                                                      'Content',
                                                                  width: 52,
                                                                  color: sharedProfileColour(
                                                                      userList
                                                                          .first
                                                                          .userType)),
                                                            ),
                                                            TouchableOpacity(
                                                              onTap: () {
                                                                setState(() {
                                                                  _activeButtonIndex =
                                                                      2;
                                                                  if (menuList
                                                                          .length !=
                                                                      0)
                                                                    _scrollToTop();
                                                                });
                                                              },
                                                              child: CommonButtonProfile(
                                                                  isActive:
                                                                      _activeButtonIndex ==
                                                                          2,
                                                                  txt: 'Menu',
                                                                  width: 52,
                                                                  color: sharedProfileColour(
                                                                      userList
                                                                          .first
                                                                          .userType)),
                                                            ),
                                                            TouchableOpacity(
                                                              onTap: () {
                                                                setState(() {
                                                                  _activeButtonIndex =
                                                                      3;
                                                                });
                                                              },
                                                              child: CommonButtonProfile(
                                                                  isActive:
                                                                      _activeButtonIndex ==
                                                                          3,
                                                                  txt: 'About',
                                                                  width: 52,
                                                                  color: sharedProfileColour(
                                                                      userList
                                                                          .first
                                                                          .userType)),
                                                            ),
                                                            TouchableOpacity(
                                                              onTap: () {
                                                                setState(() {
                                                                  _activeButtonIndex =
                                                                      4;
                                                                });
                                                              },
                                                              child: CommonButtonProfile(
                                                                  isActive:
                                                                      _activeButtonIndex ==
                                                                          4,
                                                                  txt:
                                                                      'Reviews',
                                                                  width: 52,
                                                                  color: sharedProfileColour(
                                                                      userList
                                                                          .first
                                                                          .userType)),
                                                            ),
                                                          ]),
                                                    )
                                                  : userList.first.userType ==
                                                          UserType.Customer.name
                                                      ? Container(
                                                          width: 95.w,
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                TouchableOpacity(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _activeButtonIndex =
                                                                          1;
                                                                    });
                                                                  },
                                                                  child: CommonButtonProfile(
                                                                      isActive:
                                                                          _activeButtonIndex ==
                                                                              1,
                                                                      txt:
                                                                          'Content',
                                                                      width: 52,
                                                                      color: sharedProfileColour(userList
                                                                          .first
                                                                          .userType)),
                                                                ),
                                                                TouchableOpacity(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _activeButtonIndex =
                                                                          3;
                                                                    });
                                                                  },
                                                                  child: CommonButtonProfile(
                                                                      isActive:
                                                                          _activeButtonIndex ==
                                                                              3,
                                                                      txt:
                                                                          'Reviews',
                                                                      width: 52,
                                                                      color: sharedProfileColour(userList
                                                                          .first
                                                                          .userType)),
                                                                ),
                                                              ]),
                                                        )
                                                      : Container(
                                                          width: 95.w,
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                TouchableOpacity(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _activeButtonIndex =
                                                                          1;
                                                                    });
                                                                  },
                                                                  child: CommonButtonProfile(
                                                                      isActive:
                                                                          _activeButtonIndex ==
                                                                              1,
                                                                      txt:
                                                                          'Content',
                                                                      width: 52,
                                                                      color: sharedProfileColour(userList
                                                                          .first
                                                                          .userType)),
                                                                ),
                                                                TouchableOpacity(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _activeButtonIndex =
                                                                          2;
                                                                      if (menuList
                                                                              .length !=
                                                                          0)
                                                                        _scrollToTop();
                                                                    });
                                                                  },
                                                                  child: CommonButtonProfile(
                                                                      isActive:
                                                                          _activeButtonIndex ==
                                                                              2,
                                                                      txt:
                                                                          'Menu',
                                                                      width: 40,
                                                                      color: sharedProfileColour(userList
                                                                          .first
                                                                          .userType)),
                                                                ),
                                                                TouchableOpacity(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _activeButtonIndex =
                                                                          3;
                                                                    });
                                                                  },
                                                                  child: CommonButtonProfile(
                                                                      isActive:
                                                                          _activeButtonIndex ==
                                                                              3,
                                                                      txt:
                                                                          'Reviews',
                                                                      width: 52,
                                                                      color: sharedProfileColour(userList
                                                                          .first
                                                                          .userType)),
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
                                                                constraints:
                                                                    BoxConstraints(
                                                                  minHeight:
                                                                      300, // Set your minimum height here
                                                                ),
                                                                child: Center(
                                                                    child:
                                                                        Column(
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
                                                                          color: boxShadowColor.withOpacity(
                                                                              0.2),
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              35,
                                                                          fontFamily:
                                                                              'Product Sans'),
                                                                    ),
                                                                    Text(
                                                                      'in content  ',
                                                                      style: TextStyle(
                                                                          color: boxShadowColor.withOpacity(
                                                                              0.2),
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              35,
                                                                          fontFamily:
                                                                              'Product Sans'),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          200,
                                                                    )
                                                                  ],
                                                                )),
                                                              )
                                                            : Container(
                                                                constraints:
                                                                    BoxConstraints(
                                                                  minHeight:
                                                                      300, // Set your minimum height here
                                                                ),
                                                                child: GridView
                                                                    .builder(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  // Disable scrolling
                                                                  shrinkWrap:
                                                                      true,
                                                                  // Allow the GridView to shrink-wrap its content
                                                                  addAutomaticKeepAlives:
                                                                      true,

                                                                  padding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          0.8.h,
                                                                      horizontal:
                                                                          _isVendor
                                                                              ? 1.w
                                                                              : 0),
                                                                  gridDelegate:
                                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                                    childAspectRatio:
                                                                        1,
                                                                    crossAxisCount:
                                                                        3, // Number of items in a row
                                                                    crossAxisSpacing:
                                                                        _isVendor
                                                                            ? 2.w
                                                                            : 2.w,
                                                                    mainAxisSpacing:
                                                                        1.h, // Spacing between rows
                                                                  ),
                                                                  itemCount:
                                                                      feedList
                                                                          .length,
                                                                  // Total number of items
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    // You can replace this container with your custom item widget
                                                                    return FeedWidget(
                                                                        index:
                                                                            index,
                                                                        isSelfProfile:
                                                                            "No",
                                                                        type:
                                                                            "not self",
                                                                        userModel:
                                                                            userList
                                                                                .first,
                                                                        userId: widget
                                                                            .userIdList
                                                                            .first,
                                                                        fulldata:
                                                                            feedList,
                                                                        data: feedList[
                                                                            index]);
                                                                  },
                                                                ),
                                                              )),

                                              if (_activeButtonIndex == 2)
                                                Menu(
                                                    isLoading: _isLoading,
                                                    menuList: menuList,
                                                    scroll: t1,
                                                    categories: categories,
                                                    user:
                                                        widget.userIdList.first,
                                                    kycStatus: kycStatus),
                                              if (_activeButtonIndex == 3)
                                                Container(
                                                  constraints: BoxConstraints(
                                                    minHeight:
                                                        300, // Set your minimum height here
                                                  ),
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
                                                        'No reviews',
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
                                                        height: 200,
                                                      )
                                                    ],
                                                  )),
                                                ),
                                              if (_activeButtonIndex == 4)
                                                Container(
                                                  constraints: BoxConstraints(
                                                    minHeight:
                                                        300, // Set your minimum height here
                                                  ),
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
                                                        'No data',
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
                                                        height: 200,
                                                      )
                                                    ],
                                                  )),
                                                )
                                            ]),
                                      ),
                                    ),
                                    Space(10.h),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                        color: Colors.black,
                      )),
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}

Future<void> _launchURL(String url) async {
  try {
    final Uri urlLink = Uri.parse(url);

    await launchUrl(
      urlLink,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    print('Could not open the  link: $e');
  }
}
