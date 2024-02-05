// ignore_for_file: use_build_context_synchronously

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/cart.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/screens/Tabs/Orders/orders.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

class Tabs extends StatefulWidget {
  static const routeName = '/tabs-screen';
  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
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

  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final List<Widget> _pages = [
    const Home(),
    const Orders(),
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

  void animateToSelectedPage() {
    _pageController.animateToPage(_selectedIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  final iconList = <IconData>[
    Icons.home,
    Icons.laptop,
    Icons.shopping_cart_outlined,
    Icons.person,
    // Icons.brightness_1,
  ];
  final textList = <String>[
    'Home',
    'Orders',
    'Cart',
    'Profile',
    // 'Account',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: PageView(
        onPageChanged: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        children: _pages,
      ),
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
              ], // Define your gradient colors
              begin: Alignment.topCenter, // Define your gradient begin position
              end: Alignment.bottomCenter, // Define your gradient end position
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16), // Adjust padding as needed
        ),
        onPressed: () async {
          // awa
          AppWideLoadingBanner().loadingBanner(context);
          List<String> url = await pickMultipleImagesAndUpoad();
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
          animateToSelectedPage();
        },
        activeIndex: _selectedIndex,
        itemCount: 4,

        tabBuilder: (int index, bool isActive) {
          if (_selectedIndex == index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
                color: Color.fromRGBO(84, 166, 193, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.all(
                      SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        fontSize: 10,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0,
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
                  color: const Color.fromRGBO(84, 166, 193, 1),
                ));
          }
        },
        backgroundColor: Colors.white,

        splashColor: Colors.blue,
        // notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.sharpEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 15,
        rightCornerRadius: 15,

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

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: AnimatedBottomNavigationBar(
      //     icons: [Icons.abc, Icons.ac_unit, Icons.home, Icons.rocket],
      //     activeIndex: _selectedIndex,
      //     gapLocation: GapLocation.center,
      //     notchSmoothness: NotchSmoothness.verySmoothEdge,
      //     leftCornerRadius: 32,
      //     rightCornerRadius: 32,
      //     onTap: (index) {
      //       setState(() {
      //         _selectedIndex = index;
      //       });
      //       animateToSelectedPage();
      //     }

      //     //other params
      //     ),
      // bottomNavigationBar: Container(
      //   margin: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      //   height: 55,
      //   padding: const EdgeInsets.symmetric(horizontal: 50),
      //   decoration: ShapeDecoration(
      //     color: Color.fromRGBO(38, 115, 140, 1),
      //     shape: SmoothRectangleBorder(
      //       borderRadius: SmoothBorderRadius(
      //         cornerRadius: 15,
      //         cornerSmoothing: 1,
      //       ),
      //     ),
      //   ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       TouchableOpacity(
      //         onTap: () {
      //           setState(() {
      //             _selectedIndex = 0;
      //           });
      //           animateToSelectedPage();
      //         },
      //         child: Column(
      //           children: [
      //             const Space(9),
      //             buildColorFilteredIcon(Icon(Icons.home), _selectedIndex == 0),
      //             // const Space(4.33),
      //             Text(
      //               "Home",
      //               style: GoogleFonts.nunito(
      //                 color: _selectedIndex == 0
      //                     ? Colors.black
      //                     : const Color(0xff404654),
      //                 fontSize: 10,
      //                 fontWeight: FontWeight.w600,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       TouchableOpacity(
      //         onTap: () {
      //           setState(() {
      //             _selectedIndex = 1;
      //           });
      //           animateToSelectedPage();
      //         },
      //         child: Column(
      //           children: [
      //             const Space(9.5),
      //             buildColorFilteredIcon(
      //                 Icon(Icons.add_a_photo), _selectedIndex == 1),
      //             // const Space(5.92),
      //             Text(
      //               "Feed",
      //               style: GoogleFonts.nunito(
      //                 color: _selectedIndex == 1
      //                     ? Colors.black
      //                     : const Color(0xff404654),
      //                 fontSize: 10,
      //                 fontWeight: FontWeight.w600,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       TouchableOpacity(
      //         onTap: () {
      //           setState(() {
      //             _selectedIndex = 2;
      //           });
      //           animateToSelectedPage();
      //         },
      //         child: Column(
      //           children: [
      //             const Space(8.67),
      //             buildColorFilteredIcon(
      //                 Icon(Icons.person), _selectedIndex == 2),
      //             // const Space(4.67),
      //             Text(
      //               "Profile",
      //               style: GoogleFonts.nunito(
      //                 color: _selectedIndex == 4
      //                     ? Colors.black
      //                     : const Color(0xff404654),
      //                 fontSize: 10,
      //                 fontWeight: FontWeight.w600,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
