// ignore_for_file: must_be_immutable, prefer_is_empty, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/customer_widgets_profile.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/edit_profile.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/menu_item.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
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
import 'package:shared_preferences/shared_preferences.dart';    import 'package:pull_to_refresh/pull_to_refresh.dart';


enum SampleItem { itemOne }

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
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async{
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
    await Provider.of<Auth>(context, listen: false).getFeed().then((feed) {
      setState(() {
        feedList = [];
        feedList.addAll(feed);
        _isLoading = false;
        _refreshController.refreshCompleted();

      });
    });
    await Provider.of<Auth>(context, listen: false).getMenu().then((menu) {
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
  List<String> categories = [];

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
      await Provider.of<Auth>(context, listen: false).getMenu().then((menu) {
        setState(() {
          menuList = [];
          menuList.addAll(menu);
          _isLoading = false;
        });
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
    await Provider.of<Auth>(context, listen: false).getFeed().then((feed) {
      setState(() {
        feedList = [];
        feedList.addAll(feed);
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    _getFeed();
    _getMenu();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userType == 'Vendor';
    return SmartRefresher(
      onRefresh: _loading,
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onLoading: _loading,
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
                                CustomIconButton(
                                  text: 'back',
                                  ic: Icons.arrow_back_ios_new_outlined,
                                  onTap: () {},
                                ),
                                Container(
                                  // width: 40.w,
                                  padding: EdgeInsets.only(left: 10.w),
                                  child: const StoreLogoWidget(),
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

                                          await Provider.of<Auth>(context,
                                                  listen: false)
                                              .logout();
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
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const StoreNameWidget(),
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
                                                  'https://api.cloudbelly.in/jTpt?id=${Provider.of<Auth>(context, listen: false).user_id}&type=profile'),
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
                                    )
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
                            shadows: const [
                              BoxShadow(
                                offset: Offset(0, 4),
                                color: Color.fromRGBO(165, 200, 199, 0.6),
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
                               /* if (_isVendor)
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
                                  ),*/
                                Space(2.h),
                                !_isVendor
                                    ? SizedBox(
                                        width: 87.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 1;
                                                  });
                                                },
                                                child:
                                                    CommomButtonProfileCustomer(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                1,
                                                        text: 'Content')),
                                            TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 2;
                                                  });
                                                },
                                                child:
                                                    CommomButtonProfileCustomer(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                2,
                                                        text: 'Menu')),
                                            TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 4;
                                                  });
                                                },
                                                child:
                                                    CommomButtonProfileCustomer(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                4,
                                                        text: 'About')),
                                            TouchableOpacity(
                                                onTap: () {
                                                  setState(() {
                                                    _activeButtonIndex = 3;
                                                  });
                                                },
                                                child:
                                                    CommomButtonProfileCustomer(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                3,
                                                        text: 'Reviews')),
                                          ],
                                        ),
                                      )
                                    : Container(
                                       // height: 6.5.h,
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
                                                MainAxisAlignment.spaceAround,
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
                                                        _activeButtonIndex == 2,
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
                                                        _activeButtonIndex == 3,
                                                    txt: 'Reviews',
                                                  width: 52,),
                                              ),
                                            ]),
                                      ),
                              //  _isVendor ? Space(1.h) : Space(0.h),
                                Space(20),
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
                                                  height: 10.h,
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
                                                      horizontal:
                                                          _isVendor ? 1.w : 0),
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
                                                        data: feedList[index]);
                                                  },
                                                )),
                                if (_activeButtonIndex == 2)
                                  Menu(
                                    isLoading: _isLoading,
                                    menuList: menuList,
                                    categories: categories,
                                  ),
                                if (_activeButtonIndex == 3)
                                  const Text('Feature Pending'),
                                if (_activeButtonIndex == 4)
                                  const Text('Feature Pending')
                              ]),
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

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required bool isLoading,
    required this.menuList,
    required this.categories,
  }) : _isLoading = isLoading;

  final bool _isLoading;
  final List menuList;
  final List<String> categories;

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
      child: Column(children: [
        widget._isLoading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : widget.menuList.length == 0
                ? Container(
                    height: 10.h,
                    child: const Center(child: Text('No items in Menu')),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                for (int i = 0; i < widget.categories.length; i++)
                                  TouchableOpacity(
                                    onTap: () {
                                      setState(() {
                                        _iscategorySearch = true;
                                        _searchOn = true;
                                        _controller.text = widget.categories[i];
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5.w),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 1.h, horizontal: 5.w),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(112, 186, 210, 1),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(6, 6),
                                             // spreadRadius: 0.5,
                                              color: Color(0xFF70BAD2).withOpacity(0.8),
                                              blurRadius: 10)
                                        ],
                                      ),
                                     /* decoration: GlobalVariables()
                                          .ContainerDecoration(
                                              offset: const Offset(5, 6),
                                              blurRadius: 10,
                                              shadowColor: const Color.fromRGBO(72, 138, 136, 0.5),
                                              boxColor: const Color.fromRGBO(
                                                  112, 186, 210, 1),
                                              cornerRadius: 10,

                                      ),*/
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
                      const Space(22),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: GlobalVariables().ContainerDecoration(
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                          shadowColor: Colors.white,
                          boxColor: const Color.fromRGBO(239, 255, 254, 1),
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
                                      textInputAction: TextInputAction.done,
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
                                        if (newv == '')
                                          setState(() {
                                            _searchOn = false;
                                          });
                                      },
                                      cursorColor: const Color(0xFFFA6E00)),
                                ),
                              ),
                              const Space(
                                30,
                                isHorizontal: true,
                              ),
                              TouchableOpacity(
                                onTap: () {
                                  setState(() {
                                    _searchOn = false;
                                    _controller.clear();
                                  });
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 1.w),
                                  child: const Icon(
                                    Icons.cancel,
                                    color: Color(0xFFFA6E00),
                                  ),
                                ),
                              )
                            ]),
                      ),
                      Space(1.h),
                      if (_iscategorySearch && _searchOn)
                        for (int index = 0;
                            index < widget.menuList.length;
                            index++)
                          if (widget.menuList[index]['category']
                              .toString()
                              .contains(_controller.text))
                            MenuItem(data: widget.menuList[index]),
                      if (!_iscategorySearch && _searchOn)
                        for (int index = 0;
                            index < widget.menuList.length;
                            index++)
                          if (widget.menuList[index]['name']
                              .toString()
                              .toLowerCase()
                              .contains(_controller.text.toLowerCase()))
                            MenuItem(data: widget.menuList[index]),
                      if (!_searchOn)
                        for (int index = 0;
                            index < widget.menuList.length;
                            index++)
                          MenuItem(data: widget.menuList[index]),
                    ],
                  ),
      ]),
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
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userType == 'Vendor';
    // bool _isMultiple =
    //     data['multiple_files'] != null && data['multiple_files'].length != 0;
    return TouchableOpacity(
            onTap: () async {
              final Data = await Provider.of<Auth>(context, listen: false)
                  .getFeed() as List<dynamic>;
              Navigator.of(context).pushNamed(PostsScreen.routeName,arguments: {'data': Data, 'index': index});
            //  print("data:: $fulldata");
            },
            child: Stack(
              children: [
                Hero(
                  tag: data['id'],
                  child: Container(
                    height: _isVendor ? 100 : 110,
                    width: _isVendor ? 100 : 110,
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
                        loadingBuilder:
                            GlobalVariables().loadingBuilderForImage,
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
                      height: 5,
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
