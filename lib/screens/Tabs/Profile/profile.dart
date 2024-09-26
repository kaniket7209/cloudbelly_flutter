// ignore_for_file: must_be_immutable, prefer_is_empty, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudbelly_app/widgets/modal_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _switchValue = false;
  String kycStatus = 'not verified';
  bool darkMode = true;
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
        MediaQuery.sizeOf(context).height / 3.5, // Scroll to the top
        duration:
            const Duration(milliseconds: 300), // Duration of the animation
        curve: Curves.linearToEaseOut, // Curve of the animation
      );
    });
  }

  Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });

    return prefs.getString('dark_mode');
  }

  @override
  void dispose() {
    t1.dispose();
    super.dispose();
    getDarkModeStatus();
  }

  Future<void> _loading() async {
    final prefs = await SharedPreferences.getInstance();
    fetchUserDetailsbyKey();
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<Auth>(context, listen: false);
    final userData = authProvider.userData;

    await authProvider.getFeed(userData?['user_id']).then((feed) {
      setState(() {
        feedList = feed;
        _isLoading = false;
      });
    });

    await authProvider.getMenu(userData?['user_id']).then((menu) {
      setState(() {
        menuList = menu;
        _isLoading = false;
      });
      final menuData = json.encode({'menu': menu});
      prefs.setString('menuData', menuData);
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
    // if (prefs.containsKey('menuData')) {
    //   setState(() {
    //     final extractedUserData =
    //         json.decode(prefs.getString('menuData')!) as Map<String, dynamic>;
    //     // print("extractedUserData ${extractedUserData}");
    //     menuList = [];
    //     menuList.addAll(extractedUserData['menu'] as List<dynamic>);
    //     _isLoading = false;
    //   });
    // } else {

    await Provider.of<Auth>(context, listen: false)
        .getMenu(Provider.of<Auth>(context, listen: false).userData?['user_id'])
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

    // }
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

  void fetchUserDetailsbyKey() async {
    final res = await getUserDetailsbyKey(
        Provider.of<Auth>(context, listen: false).userData?['user_id'], [
      'store_availability',
      'kyc_status',
      'followings',
      'followers',
      'fssai'
    ]);
    print(" resssp ${json.encode(res)}");
    setState(() {
      _switchValue = res['store_availability'] ?? true;
    });
    Map<String, dynamic>? userData = UserPreferences.getUser();
    if (userData != null) {
      userData['store_availability'] = _switchValue;
      userData['fssai'] = res['fssai'];
      userData['kyc_status'] = res['kyc_status'] ?? 'not verified';
      await UserPreferences.setUser(userData);
      kycStatus = userData['kyc_status'];

      setState(() {
        Provider.of<Auth>(context, listen: false).userData?['kyc_status'] =
            res['kyc_status'] ?? 'verified';
        Provider.of<Auth>(context, listen: false).userData?['followers'] =
            res['followers'] ?? [];
        Provider.of<Auth>(context, listen: false).userData?['followings'] =
            res['followings'] ?? [];
        Provider.of<Auth>(context, listen: false).userData?['fssai'] =
            res['fssai'] ?? "";
      });
    }
  }

  Future<Map<String, dynamic>> getUserDetailsbyKey(
      String userId, List<String> projectKey) async {
    try {
      final res = await Provider.of<Auth>(context, listen: false)
          .getUserDataByKey(userId, projectKey);
      print(res);
      return res;
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    getDarkModeStatus();
    Provider.of<Auth>(context, listen: false).userData =
        UserPreferences.getUser();
    // _switchValue = Provider.of<Auth>(context, listen: false)
    //         .userData?['store_availability'] ??
    fetchUserDetailsbyKey();
    false;
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
    if (darkMode) {
      boxShadowColor = Color(0xff313030);
    } else {
      if (userType == 'Vendor') {
        boxShadowColor = const Color(0xff0A4C61);
      } else if (userType == 'Customer') {
        boxShadowColor = const Color(0xff2E0536);
      } else if (userType == 'Supplier') {
        boxShadowColor = Color.fromARGB(0, 115, 188, 150);
      } else {
        boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
      }
    }

    return RefreshIndicator(
      onRefresh: _loading,
      // controller: _refreshController,

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
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            // margin: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (userType == 'Vendor')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Transform.scale(
                                          scale:
                                              0.75, // Adjust the scale factor to make the switch smaller
                                          child: CupertinoSwitch(
                                            thumbColor: _switchValue
                                                ? const Color(0xFF4DAB4B)
                                                : Color.fromARGB(
                                                    255, 196, 49, 49),
                                            activeColor: _switchValue
                                                ? const Color(0xFFBFFC9A)
                                                : const Color(0xFFFBCDCD),
                                            trackColor: const Color.fromARGB(
                                                    255, 196, 49, 49)
                                                .withOpacity(0.5),
                                            value: _switchValue,
                                            onChanged: (value) async {
                                              setState(() {
                                                _switchValue = value;
                                              });
                                              await submitStoreAvailability(); // Call the submit function after the state update
                                              print(
                                                  "switch tapped $_switchValue");
                                            },
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Store Status',
                                        style: TextStyle(
                                          color:darkMode?Colors.white:
                                              boxShadowColor, // Replace with the desired color
                                          fontFamily: 'Product Sans',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                // store switch
                                Row(
                                  children: [
                                    CustomIconButton(
                                      text: '',
                                      ic: Icons.qr_code,
                                      color: darkMode?Color(0xff030303).withOpacity(0.77): Colors.transparent,
                                      onTap: () {
                                        context
                                            .read<TransitionEffect>()
                                            .setBlurSigma(5.0);
                                        ProfileShareBottomSheet()
                                            .AddAddressSheet(context);
                                      },
                                    ),
                                    if (userType != 'Customer')
                                      SizedBox(
                                        width: 10,
                                      ),
                                    if (userType == 'Customer')
                                      SizedBox(
                                        width: 60.w,
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
                                              color:darkMode?Color(0xff030303).withOpacity(0.77): _isVendor
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
                                              cornerRadius: 12,
                                              cornerSmoothing: 1,
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.settings,
                                          size: 27,
                                          color: boxShadowColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Space(2.h),
                      //store panel
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 420, // Set the maximum width to 420
                          ),
                          child: Column(
                            children: [
                              Center(
                                  child: Container(
                                width: 90.w,
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      offset: Offset(0, 4),
                                      color:darkMode?Color(0xff030303): Provider.of<Auth>(context,
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
                                  color:darkMode?Color(0xff313030): Colors.white,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 53,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Space(3.h),
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 15, 10, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: const StoreLogoWidget(),
                                          ),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Container(
                                            width: 50.w,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  Provider.of<Auth>(context,
                                                          listen: true)
                                                      .userData?['store_name'],
                                                  style: TextStyle(
                                                      color:darkMode?Colors.white: boxShadowColor,
                                                      fontFamily: 'Ubuntu',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1),
                                                ),
                                                Text(
                                                  Provider.of<Auth>(context,
                                                          listen: true)
                                                      .userData?['user_type'],
                                                  style: TextStyle(
                                                      color: darkMode?Color(0xffB1F0EF):boxShadowColor,
                                                      fontFamily:
                                                          'Product Sans',
                                                      fontSize: 12,
                                                      letterSpacing: 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              final phoneNumber =
                                                  Provider.of<Auth>(context,
                                                              listen: false)
                                                          .userData?['phone'] ??
                                                      '';

                                              if (phoneNumber.length == 10) {
                                                final whatsappUrl =
                                                    'https://wa.me/91$phoneNumber';
                                                _launchURL(whatsappUrl);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'WhatsApp number is incorrect. It is not a 10-digit number.'),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 7, 12, 2),
                                              child: Image.asset(
                                                  'assets/images/WhatsApp.png',
                                                  width: 27,color: darkMode?Colors.white:Colors.transparent,),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

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
                                          color: darkMode?Color(0xffB1F0EF):Colors.transparent,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final List<dynamic>
                                                dynamicFollowers =
                                                Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followers'] ??
                                                    [];

                                            _showFollowers(
                                                context, dynamicFollowers);
                                          },
                                          child: ColumnWidgetHomeScreen(
                                            data: Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followers'] !=
                                                    null
                                                ? (Provider.of<Auth>(context,
                                                            listen: false)
                                                        .userData?['followers'])
                                                    .length
                                                    .toString()
                                                : "",
                                            txt: 'Followers',
                                             color: darkMode?Color(0xffB1F0EF):Colors.transparent,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final List<dynamic>
                                                dynamicFollowings =
                                                Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followings'] ??
                                                    [];

                                            _showFollowings(
                                                context, dynamicFollowings);
                                          },
                                          child: ColumnWidgetHomeScreen(
                                            data: Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followings'] !=
                                                    null
                                                ? (Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followings'])
                                                    .length
                                                    .toString()
                                                : "",
                                            txt: 'Following',
                                             color: darkMode?Color(0xffB1F0EF):Colors.transparent,
                                          ),
                                        )
                                      ],
                                    ),
                                    Space(2.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Customer.name)
                                          TouchableOpacity(
                                            onTap: () {
                                              TextEditingController
                                                  _controller =
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
                                          SizedBox(
                                            width: 20,
                                          ),
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          Make_Profile_ListWidget(
                                            color:
                                                Color.fromRGBO(250, 110, 0, 1),
                                            onTap: () async {
                                              final data = await Provider.of<
                                                          Auth>(context,
                                                      listen: false)
                                                  .getMenu(Provider.of<Auth>(
                                                          context,
                                                          listen: false)
                                                      .userData?['user_id']);
                                              (data as List<dynamic>).forEach(
                                                (element) {
                                                  // print(element);
                                                },
                                              );
                                              // Sc
                                              showScannedMenuBottomSheet(
                                                  context, data, false);
                                            },
                                            txt: 'Edit product',
                                          ),
                                        //edit menu
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          SizedBox(
                                            width: 20,
                                          ),
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          Make_Profile_ListWidget(
                                            color:
                                                Color.fromRGBO(10, 76, 97, 1),
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
                                                              showScannedMenuBottomSheet(
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
                                                              showScannedMenuBottomSheet(
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

                                        SizedBox(
                                          width: 20,
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
                                color:darkMode?Color(0xff000000).withOpacity(0.47): Provider.of<Auth>(context, listen: false)
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
                            color:darkMode? Color(0xff313030): Colors.white,
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
                                Center(
                                  child: Container(
                                    // padding: EdgeInsets.only(
                                    //     top: 1.h, right: 20.w),
                                    width: 30,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFFA6E00)
                                          .withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                    ),
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
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
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
                                                    color: darkMode?Colors.white:boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
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
                                                    txt: 'Menu ',
                                                    width: 52,
                                                    color: darkMode?Colors.white:boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
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
                                                    color: darkMode?Colors.white:boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
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
                                                    color: darkMode?Colors.white:boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      )
                                    : userType == UserType.Customer.name
                                        ? Container(
                                            width: 95.w,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              1;
                                                        });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                1,
                                                        txt: 'Content',
                                                        width: 52,
                                                        color: darkMode?Colors.white:boxShadowColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              3;
                                                        });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                3,
                                                        txt: 'Reviews',
                                                        width: 52,
                                                        color: darkMode?Colors.white:boxShadowColor,
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          )
                                        : Container(
                                            // height: 6.5.h,
                                            width: 100.w,

                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              1;
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
                                                              color: darkMode?Colors.white:boxShadowColor,
                                                            ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              2;

                                                          if (menuList.length !=
                                                              0) _scrollToTop();
                                                        });

                                                        // Ensure the scroll happens after the frame is built
                                                        //                                                   WidgetsBinding.instance.addPostFrameCallback((_) {
                                                        //   t1.jumpTo(500.0); // Scroll to the top
                                                        // });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                2,
                                                        txt: 'Menu ',
                                                        width: 40,
                                                        color: darkMode?Colors.white:boxShadowColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              4;
                                                        });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                4,
                                                        txt: 'About',
                                                        width: 52,
                                                        color: darkMode?Colors.white:boxShadowColor,
                                                      ),
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
                                      kycStatus: kycStatus),
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
                                    constraints: BoxConstraints(
                                      minHeight:
                                          400, // Set your minimum height here
                                    ),
                                    child: Container(
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Store Info',
                                              style: TextStyle(
                                                  color: boxShadowColor,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 22,
                                                  letterSpacing: 1,
                                                  fontFamily:
                                                      'Product Sans Black'),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    final locationDet = Provider
                                                            .of<Auth>(context,
                                                                listen: false)
                                                        .userData!['address'];
                                                    print(
                                                        "locationDet  $locationDet");
                                                    if (locationDet[
                                                                'longitude'] !=
                                                            null &&
                                                        locationDet[
                                                                'latitude'] !=
                                                            null) {
                                                      final String
                                                          googleMapsUrl =
                                                          'https://www.google.com/maps/search/?api=1&query=${locationDet['latitude']},${locationDet['longitude']}';
                                                      print(
                                                          "googleMapsUrl  $googleMapsUrl");
                                                      _launchURL(googleMapsUrl);
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 25,
                                                    height: 25,
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: boxShadowColor
                                                              .withOpacity(
                                                                  0.2), // Color with 35% opacity
                                                          blurRadius:
                                                              10, // Blur amount
                                                          offset: Offset(0,
                                                              4), // X and Y offset
                                                        ),
                                                      ],
                                                    ),
                                                    child: Image.asset(
                                                      'assets/images/Location.png',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Container(
                                                  constraints: BoxConstraints(
                                                      maxWidth: 60.w),
                                                  child: Text(
                                                    (Provider.of<Auth>(context,
                                                                        listen:
                                                                            false)
                                                                    .userData![
                                                                'address'] !=
                                                            null)
                                                        ? "${Provider.of<Auth>(context, listen: false).userData!['address']['hno']} ${Provider.of<Auth>(context, listen: false).userData!['address']['location']} ${Provider.of<Auth>(context, listen: false).userData!['address']['landmark']}"
                                                        : 'No location found',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff1B7997),
                                                        fontSize: 13,
                                                        fontFamily:
                                                            'Product Sans'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 1.w),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final phoneNumber =
                                                        Provider.of<Auth>(
                                                                context,
                                                                listen: false)
                                                            .userData!['phone'];
                                                    final url =
                                                        'tel:$phoneNumber';

                                                    try {
                                                      await _launchURL(url);
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Could not launch phone call $e')),
                                                      );
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 9,
                                                    backgroundColor:
                                                        const Color(0xFFFA6E00),
                                                    child: Image.asset(
                                                        'assets/images/Phone.png'),
                                                  ),
                                                ),
                                                SizedBox(width: 3.w),
                                                Text(
                                                  "${Provider.of<Auth>(context, listen: false).userData!['phone']}",
                                                  style: TextStyle(
                                                      color: Color(0xff1B7997),
                                                      fontSize: 12,
                                                      fontFamily:
                                                          'Product Sans'),
                                                ),
                                              ],
                                            ),
                                            // Container(
                                            //   color: Colors.white,
                                            //   child: ClipSmoothRect(
                                            //     radius: SmoothBorderRadius(
                                            //       cornerRadius: 22,
                                            //       cornerSmoothing: 1,
                                            //     ),
                                            //     child: CachedNetworkImage(
                                            //       imageUrl: Provider.of<Auth>(
                                            //               context,
                                            //               listen: false)
                                            //           .userData?['fssai'],
                                            //       fit: BoxFit.cover,
                                            //       placeholder: (context, url) =>
                                            //           Center(
                                            //         child:
                                            //             CircularProgressIndicator(
                                            //           color: Color.fromARGB(
                                            //               255, 33, 229, 243),
                                            //         ),
                                            //       ),
                                            //       errorWidget:
                                            //           (context, url, error) =>
                                            //               Icon(Icons.error),
                                            //     ),
                                            //   ),
                                            // ),

                                            const SizedBox(
                                              height: 100,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ]),
                        ),
                      ),
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

  Future<void> submitStoreAvailability() async {
    // Fetch the kyc_status safely
    String kycStatus = UserPreferences.getUser()?['kyc_status'];

    if (kycStatus == 'verified') {
      // Check for true value explicitly
      String msg = await Provider.of<Auth>(context, listen: false)
          .storeAvailability(_switchValue);
      if (msg == 'User information updated successfully.') {
        Map<String, dynamic>? userData = UserPreferences.getUser();
        if (userData != null) {
          userData['store_availability'] = _switchValue;
          await UserPreferences.setUser(userData);
          setState(() {
            Provider.of<Auth>(context, listen: false)
                .userData?['store_availability'] = _switchValue;
          });
          TOastNotification()
              .showSuccesToast(context, 'Store status updated successfully');
        }
      } else {
        TOastNotification().showErrorToast(context, msg);
      }
    } else {
      setState(() {
        Provider.of<Auth>(context, listen: false)
            .userData?['store_availability'] = false;
      });
      TOastNotification()
          .showErrorToast(context, 'Your KYC status is incomplete');
    }
  }

  void _showFollowers(BuildContext context, List<dynamic> followers) {
    List<String> userIds =
        followers.map((item) => item['user_id'] as String).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsModal(
        title: 'Followers',
        userIds: userIds,
        actionButtonText: 'Unfollow',
        onReload: () {
          // Your code to reload the parent widget's state
          fetchUserDetailsbyKey();
        },
      ),
    );
  }

  void _showFollowings(BuildContext context, List<dynamic> followings) {
    List<String> userIds =
        followings.map((item) => item['user_id'] as String).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsModal(
        title: 'Followings',
        userIds: userIds,
        actionButtonText: 'Unfollow',
        onReload: () {
          // Your code to reload the parent widget's state
          fetchUserDetailsbyKey();
        },
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
          height: 43,
          width: 135,
          decoration: ShapeDecoration(
            shadows: [
              txt == 'Add products'
                  ? BoxShadow(
                      offset: Offset(5, 6),
                      spreadRadius: 0,
                      color: Color(0xff126B87).withOpacity(0.42),
                      blurRadius: 30)
                  : BoxShadow(
                      offset: Offset(5, 6),
                      spreadRadius: 0,
                      color: Color(0xffE88037).withOpacity(0.5),
                      blurRadius: 30)
            ],
            color: color ?? const Color.fromRGBO(84, 166, 193, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 14,
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

Future<void> showScannedMenuBottomSheet(
    BuildContext context, dynamic data, bool isUpload) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ScannedMenuBottomSheet(data: data, isUpload: isUpload);
    },
  );
}

class ScannedMenuBottomSheet extends StatefulWidget {
  final dynamic data;
  final bool isUpload;

  ScannedMenuBottomSheet({required this.data, required this.isUpload});

  @override
  _ScannedMenuBottomSheetState createState() => _ScannedMenuBottomSheetState();
}

class _ScannedMenuBottomSheetState extends State<ScannedMenuBottomSheet> {
  late List<Map<String, dynamic>> list;
  late Map<int, TextEditingController> nameControllers;
  late Map<int, TextEditingController> priceControllers;
  late Map<int, TextEditingController> categoryControllers;

  @override
  void initState() {
    super.initState();
    list = [];
    nameControllers = {};
    priceControllers = {};
    categoryControllers = {};

    for (var item in widget.data) {
      var newItem = Map<String, dynamic>.from(item);
      if (widget.isUpload) {
        newItem['type'] = 'Veg';
      } else {
        newItem['type'] = item['type'] == 'Veg' ? 'Veg' : 'Non Veg';
      }
      list.add(newItem);
    }

    for (int i = 0; i < list.length; i++) {
      nameControllers[i] = TextEditingController(text: list[i]['name']);
      priceControllers[i] = TextEditingController(text: list[i]['price']);
      categoryControllers[i] = TextEditingController(text: list[i]['category']);
    }
  }

  @override
  void dispose() {
    nameControllers.forEach((key, controller) => controller.dispose());
    priceControllers.forEach((key, controller) => controller.dispose());
    categoryControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var uniqueCategories = widget.data.map((e) => e['category']).toSet();
    var numberOfCategories = uniqueCategories.length;

    return SingleChildScrollView(
      child: Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.only(
              topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
              topRight: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
            ),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.9,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 6.w,
          right: 6.w,
          top: 2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    padding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                    width: 65,
                    height: 6,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFA6E00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              Space(1.h),
              if (widget.isUpload)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TouchableOpacity(
                      onTap: () {
                        setState(() {
                          int newIndex = list.length;
                          list.insert(0, {
                            'category': 'Category',
                            'name': 'Item',
                            'price': '00.00',
                            'type': 'Veg',
                          });
                          nameControllers[newIndex] =
                              TextEditingController(text: 'Item');
                          priceControllers[newIndex] =
                              TextEditingController(text: '00.00');
                          categoryControllers[newIndex] =
                              TextEditingController(text: 'Category');
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
                        ),
                      ),
                    ),
                  ],
                ),
              Space(2.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isUpload ? 'Scan complete' : 'Edit your menu',
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
                  ),
                ],
              ),
              if (widget.isUpload) Space(5.h),
              if (widget.isUpload)
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
                      (widget.data as List<dynamic>).length.toString(),
                      style: const TextStyle(
                        color: Color(0xFFFA6E00),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0.10,
                        letterSpacing: 0.42,
                      ),
                    ),
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
                    width: 20.w,
                  ),
                  SheetLabelWidget(
                    txt: 'Price',
                    width: 18.w,
                  ),
                  SheetLabelWidget(
                    txt: 'V/N',
                    width: 10.w,
                  ),
                  Space(2.w, isHorizontal: true),
                  SheetLabelWidget(
                    txt: 'Category',
                    width: 20.w,
                  ),
                  Spacer(),
                  SheetLabelWidget(
                    txt: 'Action',
                    width: 18.w,
                  ),
                ],
              ),
              Space(1.h),
              const Divider(
                color: Color(0xFFFA6E00),
              ),
              Space(1.5.h),
              Column(
                children: List.generate(list.length, (index) {
                  bool isNonVeg = list[index]['type'] == 'Non Veg';
                  return Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                            textInputAction: TextInputAction.done,
                            controller: nameControllers[index],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (newValue) async {
                              if (!widget.isUpload) {
                                await Provider.of<Auth>(context, listen: false)
                                    .updateMenuItem(
                                  list[index]['_id'],
                                  list[index]['price'].toString(),
                                  newValue,
                                  list[index]['type'],
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
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Color(0xFF094B60),
                                    fontSize: 13,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  controller: priceControllers[index],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onChanged: (newValue) async {
                                    if (!widget.isUpload) {
                                      await Provider.of<Auth>(context,
                                              listen: false)
                                          .updateMenuItem(
                                        list[index]['_id'],
                                        newValue,
                                        list[index]['name'],
                                        list[index]['type'],
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
                          width: 10.w,
                          child: Transform.scale(
                            scale: 0.85,
                            child: CupertinoSwitch(
                              value: isNonVeg,
                              onChanged: (value) async {
                                final updatedType = value ? 'Non Veg' : 'Veg';
                                if (!widget.isUpload) {
                                  await Provider.of<Auth>(context,
                                          listen: false)
                                      .updateMenuItem(
                                    list[index]['_id'],
                                    list[index]['price'].toString(),
                                    list[index]['name'],
                                    updatedType,
                                    list[index]['category'],
                                  );
                                }
                                setState(() {
                                  list[index]['type'] = updatedType;
                                });
                              },
                              activeColor: const Color.fromRGBO(232, 89, 89, 1),
                              trackColor: const Color.fromRGBO(77, 171, 75, 1),
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
                            controller: categoryControllers[index],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            textInputAction: TextInputAction.done,
                            onChanged: (newValue) async {
                              if (!widget.isUpload) {
                                await Provider.of<Auth>(context, listen: false)
                                    .updateMenuItem(
                                  list[index]['_id'],
                                  list[index]['price'].toString(),
                                  list[index]['name'],
                                  list[index]['type'],
                                  newValue,
                                );
                              }
                              setState(() {
                                list[index]['category'] = newValue;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: Color(0xffFF5A77)),
                          onPressed: () async {
                            if (!widget.isUpload) {
                              await Provider.of<Auth>(context, listen: false)
                                  .deleteMenuItem(list[index]['_id']);
                            }
                            setState(() {
                              list.removeAt(index);
                              nameControllers.remove(index);
                              priceControllers.remove(index);
                              categoryControllers.remove(index);

                              // Optionally, you can reinitialize the controllers map to maintain correct indices.
                              nameControllers = {
                                for (var i = 0; i < list.length; i++)
                                  i: TextEditingController(
                                      text: list[i]['name'])
                              };
                              priceControllers = {
                                for (var i = 0; i < list.length; i++)
                                  i: TextEditingController(
                                      text: list[i]['price'])
                              };
                              categoryControllers = {
                                for (var i = 0; i < list.length; i++)
                                  i: TextEditingController(
                                      text: list[i]['category'])
                              };
                            });
                          },
                        )
                      ],
                    ),
                  );
                }),
              ),
              Space(1.h),
              if (widget.isUpload)
                AppWideButton(
                  onTap: () async {
                    // Show loading banner
                    AppWideLoadingBanner().loadingBanner(context);

                    // Call the API to add products
                    final code = await Provider.of<Auth>(context, listen: false)
                        .AddProductsForMenu(list);
                    Navigator.of(context).pop(); // Remove loading banner
                    // print("code $code"); // Debug print

                    if (code == '200') {
                      // Ensure code is compared as an integer
                      TOastNotification().showSuccesToast(
                          context, 'Menu Uploaded successfully');

                      AppWideBottomSheet().showSheet(
                          context,
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width - 20,
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
                                    softWrap: true, // Enable soft wrapping
                                  ),
                                ),
                                Space(3.h),
                                TouchableOpacity(
                                  onTap: () async {
                                    // Show loading banner
                                    AppWideLoadingBanner()
                                        .loadingBanner(context);

                                    // Call the API to update description and type

                                    final updateCode = await Provider.of<Auth>(
                                            context,
                                            listen: false)
                                        .updateDescriptionAndType();
                                    Navigator.of(context)
                                        .pop(); // Remove loading banner
                                    // print(
                                    //     "code upd $updateCode"); // Debug print

                                    if (updateCode == '200') {
                                      // Ensure updateCode is compared correctly
                                      TOastNotification().showSuccesToast(
                                          context, 'Menu Updated successfully');
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
                      Navigator.of(context).pop(); // Remove loading banner
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
    required this.kycStatus,
  }) : _isLoading = isLoading;
  final scroll;
  final bool _isLoading;
  final String kycStatus;
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
  bool darkMode = true;

  bool storeAvailability = true;
  @override
  void initState() {
    super.initState();

    // getUserDetailsbyKey()
    fetchUserDetailsbyKey();
  }

  void fetchUserDetailsbyKey() async {
    final res = await getUserDetailsbyKey(widget.user, ['store_availability']);
    print(" ressdes ${json.encode(res)}");
    final prefs = await SharedPreferences.getInstance();

   

    if (res['store_availability'] && res['store_availability'] != null)
      setState(() {
        storeAvailability = res['store_availability'] ?? false;
        darkMode = prefs.getString('dark_mode') == "true" ? true : false;
      });
  }

  Future<Map<String, dynamic>> getUserDetailsbyKey(
      String userId, List<String> projectKey) async {
    try {
      final res = await Provider.of<Auth>(context, listen: false)
          .getUserDataByKey(userId, projectKey);
      print(res);
      return res;
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("storeAvailabilitydata $storeAvailability");

    String userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    print("widget.menuList  ${widget.menuList}");
    Color boxShadowColor;
    Color categorySelected = Color(0xff70BAD2);
    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
    }
    print("Category Search is ON");
    print("Search Text: ${_controller.text}");
    print("Total Menu Items: ${widget.menuList.length}");
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
                                    color:darkMode?Colors.white: boxShadowColor.withOpacity(0.2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                    fontFamily: 'Product Sans'),
                              ),
                              Text(
                                'in menu  ',
                                style: TextStyle(
                                    color:darkMode?Colors.white: boxShadowColor.withOpacity(0.2),
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
                                    padding: const EdgeInsets.only(
                                        bottom: 15, top: 0),
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
                                              categorySelected = Colors.red;
                                            },
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 5.w),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 1.h,
                                                  horizontal: 5.w),
                                              decoration: ShapeDecoration(
                                                color: categorySelected,
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
                                                        .withOpacity(0.5),
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
                                                  .toString() ==
                                              _controller.text)
                                            MenuItem(
                                                storeAvailability:
                                                    storeAvailability,
                                                data: widget.menuList[index],
                                                kycStatus: widget.kycStatus,
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
                                                storeAvailability:
                                                    storeAvailability,
                                                data: widget.menuList[index],
                                                scroll: widget.scroll,
                                                kycStatus: widget.kycStatus),
                                      if (!_searchOn)
                                        for (int index = 0;
                                            index < widget.menuList.length;
                                            index++)
                                          MenuItem(
                                              storeAvailability:
                                                  storeAvailability,
                                              data: widget.menuList[index],
                                              scroll: widget.scroll,
                                              kycStatus: widget.kycStatus),
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

  Color getBackgroundColor(
      String isSelfProfile, bool isVendor, String main_user_type) {
    print("userModel ${userModel?.id}");
    var usertype = userModel?.userType;
    if (usertype == null) usertype = main_user_type;
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
    String main_user_type =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';

    return TouchableOpacity(
      onTap: () async {
        print("post_screeenindexis :: $index");
        final Data = await Provider.of<Auth>(context, listen: false)
            .getFeed(userId) as List<dynamic>;
        // print("userId:: $userId");
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
                    offset: const Offset(1, 4),
                    // color: _isVendor ? const Color.fromRGBO(10, 76, 97, 0.31) :  const Color(0xBC73BC).withOpacity(0.6),
                    color: getBackgroundColor(
                        isSelfProfile, _isVendor, main_user_type),
                    blurRadius: 12,
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
  final Color? color;

  CommonButtonProfile({
    super.key,
    required this.isActive,
    required this.txt,
    required this.width,
    this.color,
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
    Color finalColor = color ?? colorProfile;
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
                      color: finalColor,
                      fontSize: 14,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      height: 0.10,
                      letterSpacing: 0.42,
                    ),
                  ),
                ),
                Container(
                  //  padding: EdgeInsets.only(top: 7),
                  height: 4,
                  decoration: ShapeDecoration(
                    color: !isActive ?  color : const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  //  padding: EdgeInsets.only(top: 7),
                  child: Text(
                    txt,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 14,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      height: 0.10,
                      letterSpacing: 0.42,
                    ),
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
