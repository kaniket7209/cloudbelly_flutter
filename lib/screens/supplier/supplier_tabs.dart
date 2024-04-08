// ignore_for_file: use_build_context_synchronously, unused_field

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/screens/supplier/supplier_dashboard.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/screens/Tabs/Feed/feed.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierTabs extends StatefulWidget {
  static const routeName = '/supplier/tabs-screen';
  @override
  State<SupplierTabs> createState() => _SupplierTabsState();
}

class _SupplierTabsState extends State<SupplierTabs> with SingleTickerProviderStateMixin {
  late AnimationController _hideBottomBarAnimationController;

  @override
  void initState() {
    _hideBottomBarAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _hideBottomBarAnimationController.dispose();
    super.dispose();
  }

  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 0);
  final List<Widget> _pages = [
    const Feed(),
    const SupplierDashboard(),

    // UploadPage(),
    const Cart(),
    const Profile(),
  ];

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

  final iconList = <IconData>[
    Icons.home,
    Icons.laptop,
    Icons.shopping_cart_outlined,
    Icons.person,
    // Icons.brightness_1,
  ];
  final textList = <String>[
    'Feed',
    'Dashboard',
    'Cart',
    'Profile',
    // 'Account',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 245, 247, 1),

      body: _pages[_selectedIndex],
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
            // child: Icon(Icons.add, size: 30, color: Colors.white,),
            child: Image.asset(
              Assets.plus_png,
              width: 25,
              height: 25,
            ),
            // child: Text(
            //   '+',
            //   textAlign: TextAlign.start,
            //   style: TextStyle(color: Colors.white, fontSize: 35),
            // ),
          ),
          // Adjust padding as needed
        ),
        onPressed: () async {
          // awa
          // await Provider.of<Auth>(context, listen: false)
          //     .postalCodeCheck('332030');
          AppWideLoadingBanner().loadingBanner(context);
          List<String> url = await Provider.of<Auth>(context, listen: false)
              .pickMultipleImagesAndUpoad();
          Navigator.of(context).pop();
          if (url.length == 0) {
            TOastNotification()
                .showErrorToast(context, 'Error While Uploading Image');
          } else if (url.contains('file size very large'))
            TOastNotification().showErrorToast(context, 'file size very large');
          else if (!url.contains('element'))
            CreateFeed().showModalSheetForNewPost(context, url);
          else {
            TOastNotification()
                .showErrorToast(context, 'Error While Uploading Image');
          }
        },
      ),
      //     floatingActionButton: FloatingActionButton(
      //     //params
      //  ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // _pages[_selectedIndex]
        },
        activeIndex: _selectedIndex,
        itemCount: _pages.length,

        tabBuilder: (int index, bool isActive) {
          if (_selectedIndex == index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10.w),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),

              width: 100,
              height: 30,
              decoration: const ShapeDecoration(
                shadows: [
                  BoxShadow(
                    offset: Offset(0, 8),
                    color: Color.fromRGBO(152, 202, 201, 0.8),
                    blurRadius: 20,
                  )
                ],
                color: Color.fromRGBO(77, 191, 74, 1),
                  // rgba()
                shape: SmoothRectangleBorder(
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
                    Text(
                      textList[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.10,
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
                  color: const Color.fromRGBO(77, 191, 74, 1),
                    // background: rgba();
                    // rgba()
                ));
          }
        },
        backgroundColor: Colors.white,
// gapWidth: 0/,
        splashColor: Colors.blue,
        // notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.sharpEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 15,
        rightCornerRadius: 15,
        notchMargin: 5,
        // onTap: (index) => setState(() => _bottomNavIndex = index),
        hideAnimationController: _hideBottomBarAnimationController,
        shadow: const BoxShadow(
          offset: Offset(0, -4),
          blurRadius: 15,
          // spreadRadius: 0.5,
          // rgba

          color: Color.fromRGBO(177, 217, 216, 0.69),
        ),
      ),
    );
  }
}
