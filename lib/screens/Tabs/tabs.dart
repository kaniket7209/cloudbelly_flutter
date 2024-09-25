// ignore_for_file: use_build_context_synchronously, unused_field

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloudbelly_app/NotificationScree.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/cart.dart';
import 'package:cloudbelly_app/screens/Tabs/belly_gpt.dart';
import 'package:cloudbelly_app/screens/Tabs/coupon_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/image_generation.dart';
import 'package:cloudbelly_app/screens/Tabs/order_page.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/screens/Tabs/Search/search_view.dart';
import 'package:cloudbelly_app/screens/Tabs/supplier/supplier_dashboard.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/screens/Tabs/Feed/feed.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tabs extends StatefulWidget {
  static const routeName = '/tabs-screen';

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  late AnimationController _hideBottomBarAnimationController;
  String? userType = "";
  late List<IconData> iconList;
  late List<String> textList = [];
  late List<Widget> pages = [];
  bool darkMode = true;

  @override
  void initState() {
    getDarkModeStatusTabs();
    userType = Provider.of<Auth>(context, listen: false).userData?['user_type'];
    iconList = <IconData>[
      Icons.home,
      userType == UserType.Vendor.name
          ? Icons.laptop
          : userType == UserType.Supplier.name
              ? Icons.laptop
              : Icons.search,
      Icons.notifications_outlined,
      Icons.person,
      // Icons.brightness_1,
    ];
    textList = <String>[
      'Feed',
      userType == UserType.Vendor.name
          ? 'Dashboard'
          : userType == UserType.Supplier.name
              ? 'Dashboard'
              : 'Search',
      'Notifications',
      'Profile',
      // 'Account',
    ];
    pages = [
      const Feed(),
      userType == UserType.Vendor.name
          ? const DashBoard()
          : userType == UserType.Supplier.name
              ? const SupplierDashboard()
              : SearchView(),
      NotificationScreen(
        initialTabIndex: 0, // Ensure initialTabIndex is an int
      ),
      const Profile(),
    ];

    _hideBottomBarAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    // TODO: implement initState
    super.initState();
  }
 Future<String?> getDarkModeStatusTabs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });
    return prefs.getString('dark_mode');
  }
  @override
  void dispose() {
    getDarkModeStatusTabs();
    _hideBottomBarAnimationController.dispose();
    super.dispose();

  }

  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  Widget buildColorFilteredIcon(Icon ic, bool isFiltered) {
    // applies the color filter when the icon is selected
    if (!isFiltered) {
      return ic;
    }
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Color(0xff4ad7d1), BlendMode.srcIn),
      child: ic,
    );
  }

  // void animateToSelectedPage() {
  //   _pageController.animateToPage(_selectedIndex,
  //       duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  // }

  @override
  Widget build(BuildContext context) {
    String? userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color colorProfile;
    if (userType == 'Vendor') {
      colorProfile = const Color(0xff54A6C1);
    } else if (userType == 'Customer') {
      colorProfile = const Color(0xff7B358D); //0xff7B358D
    } else if (userType == 'Supplier') {
      colorProfile = Color.fromARGB(255, 26, 48, 10);
    } else {
      colorProfile = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor:

      darkMode
                ? Color(0xff000000).withOpacity(0.35):
          Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                  UserType.Vendor.name
              ? const Color.fromRGBO(234, 245, 247, 1)
              : userType == UserType.Supplier.name
                  ? const Color(0xffF6FFEE)
                  : const Color.fromRGBO(255, 248, 255, 1),

      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 30, cornerSmoothing: 1)),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(250, 110, 0, 1),
                Color.fromRGBO(248, 185, 177, 1),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Center(
            child: Image.asset(
              Assets.plus_png,
              width: 25,
              height: 25,
            ),
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.only(
                topLeft: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
                topRight: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
              ),
            ),
            builder: (context) {
              return Container(
                decoration: const ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      color: Color(0x7FB1D9D8),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                      topLeft:
                          SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
                      topRight:
                          SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white,
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Shortcuts',
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Color(0xff0A4C61),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildShortcutButton(
                                  context,
                                  'BellyGPT',
                                  'assets/images/BotIcon.png',
                                  _bellyGpt,
                                ),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                child: _buildShortcutButton(
                                  context,
                                  'BellyIMAGING',
                                  'assets/images/imageFile.png',
                                  _imageGeneration,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildShortcutButton(
                                  context,
                                  'Create Post',
                                  'assets/images/editImage.png',
                                  _addPost,
                                ),
                              ),
                              if (userType == 'Vendor') ...[
                                SizedBox(width: 30),
                                Expanded(
                                  child: _buildShortcutButton(
                                    context,
                                    'Create Coupon',
                                     'assets/images/coupons.png',
                                    () => _createNewCoupon(
                                        context), // Correct way to pass context
                                  ),
                                ),
                              ]
                            ],
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // _pages[_selectedIndex]
        },
        activeIndex: _selectedIndex,
        itemCount: pages.length,

        tabBuilder: (int index, bool isActive) {
          if (_selectedIndex == index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              
              // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10.w),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),

              width: 100,
              height: 30,
              decoration: ShapeDecoration(
                shadows: [
                  BoxShadow(
                    offset: Offset(0, 8),
                    color: Provider.of<Auth>(context, listen: false)
                                .userData?['user_type'] ==
                            UserType.Vendor.name
                        ? Color.fromRGBO(84, 166, 193, 1).withOpacity(0.5)
                        : userType == UserType.Supplier.name
                            ? Color(0xFF4DBF4A).withOpacity(0.5)
                            : Color(0xff7B358D).withOpacity(0.5),
                    blurRadius: 20,
                  )
                ],
                //  color: Color.fromRGBO(84, 166, 193, 1),
                color: 
                Provider.of<Auth>(context, listen: false)
                            .userData?['user_type'] ==
                        UserType.Vendor.name
                    ? const Color.fromRGBO(84, 166, 193, 1)
                    : userType == UserType.Supplier.name
                        ? const Color(0xFF4DBF4A)
                        : const Color(0xff7B358D),
                shape: const SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.all(
                      SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      iconList[index],
                      color: Colors.white,
                    ),
                    const Space(isHorizontal: true, 2),
                    Expanded(
                      child: Text(
                        textList[index],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SizedBox(
                width: 20,
                height: 20,
                child: Icon(
                  iconList[index],
                  color: colorProfile,
                ));
          }
        },
        backgroundColor: darkMode?Color(0xff1D1D1D):Colors.white,
// gapWidth: 0/,
        splashColor: Colors.blue,
        // notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.sharpEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius:darkMode?0: 15,
        rightCornerRadius: darkMode?0:15,
        notchMargin: 5,
        // onTap: (index) => setState(() => _bottomNavIndex = index),
        hideAnimationController: _hideBottomBarAnimationController,
        shadow:  BoxShadow(
          offset: Offset(0, -4),
          blurRadius: 15,
          // spreadRadius: 0.5,
          // rgba

          color:darkMode?Color(0xff191919).withOpacity(0.69): Color.fromRGBO(177, 217, 216, 0.69),
        ),
      ),
    );
  }

Widget _buildShortcutButton(BuildContext context, String title,
      String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // height: 50,
        decoration: ShapeDecoration(
          shadows: [
            BoxShadow(
              offset: const Offset(3, 4),
              color: Color(0xff0A4C61).withOpacity(0.4),
              blurRadius: 15,
            ),
          ],
          color: Color(0xff0A4C61),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 15,
              cornerSmoothing: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  color: Colors.white,
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8), // Add some spacing between icon and text
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Product Sans',
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Sample method implementations for different actions
  bool _isNavigating = false;

  void _createNewCoupon(BuildContext context) {
    if (_isNavigating) return; // Prevents multiple navigations

    _isNavigating = true;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewCouponScreen()),
    ).then((_) {
      _isNavigating = false; // Reset the flag after navigation completes
    });
  }

  void _imageGeneration() {
    // Handle editing the menu
    if (_isNavigating) return; // Prevents multiple navigations

    _isNavigating = true;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageGeneration()),
    ).then((_) {
      _isNavigating = false; // Reset the flag after navigation completes
    });
  }

  void _bellyGpt() {
    if (_isNavigating) return; // Prevents multiple navigations

    _isNavigating = true;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BellyGPTPage()),
    ).then((_) {
      _isNavigating = false; // Reset the flag after navigation completes
    });
  }

  void _takeOrder() {
    // Handle taking an order
  }

  void _addPost() async {
    Navigator.of(context).pop(); // Close the bottom sheet
    AppWideLoadingBanner().loadingBanner(context);
    List<String> url = await Provider.of<Auth>(context, listen: false)
        .pickMultipleImagesAndUpoad();
    List<dynamic> menuList = await Provider.of<Auth>(context, listen: false)
        .getMenu(
            Provider.of<Auth>(context, listen: false).userData?['user_id']);
    Navigator.of(context).pop();
    if (url.isEmpty) {
      print("No image selected");
    } else if (url.contains('file size very large')) {
      TOastNotification().showErrorToast(context, 'file size very large');
    } else if (!url.contains('element')) {
      CreateFeed().showModalSheetForNewPost(context, url, menuList);
    } else {
      TOastNotification()
          .showErrorToast(context, 'Error While Uploading Image');
    }
  }
}
