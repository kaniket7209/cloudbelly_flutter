import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:cloudbelly_app/screens/Tabs/Feed/feed.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tabs extends StatefulWidget {
  static const routeName = '/tabs-screen';
  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final List<Widget> _pages = [
    Home(),
    Feed(),
    // UploadPage(),
    Profile(),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          // Add more items for each tab
        ],
        currentIndex: _selectedIndex, // Current index
        onTap: null, // Function to handle item tap
      ),
    );
  }
}
