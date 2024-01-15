import 'package:cloudbelly_app/screens/Tabs/home.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _activeButtonIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                      Space(10.h),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomIconButton(
                              ic: Icons.notifications,
                              onTap: () {},
                            ),
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Space(15),
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const ShapeDecoration(
                                    shadows: [
                                      BoxShadow(
                                        offset: Offset(0, 4),
                                        color:
                                            Color.fromRGBO(31, 111, 109, 0.6),
                                        blurRadius: 20,
                                      )
                                    ],
                                    shape: SmoothRectangleBorder(),
                                  ),
                                  child: ClipSmoothRect(
                                    radius: SmoothBorderRadius(
                                      cornerRadius: 15,
                                      cornerSmoothing: 1,
                                    ),
                                    child: Image.network(
                                        'https://yt3.googleusercontent.com/MANvrSkn-NMy7yTy-dErFKIS0ML4F6rMl-aE4b6P_lYN-StnCIEQfEH8H6fudTC3p0Oof3Pd=s176-c-k-c0x00ffffff-no-rj'),
                                  ),
                                ),
                                Space(2.h),
                                const Text(
                                  'Geeta Kitchen',
                                  style: TextStyle(
                                    color: Color(0xFF094B60),
                                    fontSize: 14,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w700,
                                    height: 0.10,
                                    letterSpacing: 0.42,
                                  ),
                                )
                              ],
                            ),
                            CustomIconButton(
                              ic: Icons.more_horiz,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      Space(3.h),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ColumnWidgetHomeScreen(
                                  data: (4.9).toString(),
                                  txt: 'Rating',
                                ),
                                ColumnWidgetHomeScreen(
                                  data: (789).toString(),
                                  txt: 'Followers',
                                ),
                                ColumnWidgetHomeScreen(
                                  data: '+${43}',
                                  txt: 'New followers',
                                )
                              ],
                            ),
                            Space(3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TouchableOpacity(
                                  onTap: () {},
                                  child: ButtonWidgetHomeScreen(
                                      txt: 'Edit profile', isActive: true),
                                ),
                                TouchableOpacity(
                                  onTap: () {},
                                  child: ButtonWidgetHomeScreen(
                                    txt: 'Share profile',
                                    isActive: true,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ))
                    ],
                  )
                ],
              ),
              Space(3.h),
              Center(
                child: Container(
                  width: 90.w,
                  padding:
                      EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 3.w),
                          width: 55,
                          height: 9,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFA6E00),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                        Space(2.h),
                        Container(
                          height: 7.h,
                          width: 90.w,
                          decoration: ShapeDecoration(
                            shadows: const [
                              BoxShadow(
                                offset: Offset(0, 4),
                                color: Color.fromRGBO(165, 200, 199, 0.6),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TouchableOpacity(
                                    onTap: () {
                                      setState(() {
                                        _activeButtonIndex = 1;
                                      });
                                    },
                                    child: CommonButtonProfile(
                                        isActive: _activeButtonIndex == 1,
                                        txt: 'Content')),
                                TouchableOpacity(
                                  onTap: () {
                                    setState(() {
                                      _activeButtonIndex = 2;
                                    });
                                  },
                                  child: CommonButtonProfile(
                                      isActive: _activeButtonIndex == 2,
                                      txt: 'Menu'),
                                ),
                                TouchableOpacity(
                                  onTap: () {
                                    setState(() {
                                      _activeButtonIndex = 3;
                                    });
                                  },
                                  child: CommonButtonProfile(
                                      isActive: _activeButtonIndex == 3,
                                      txt: 'Reviews'),
                                ),
                              ]),
                        ),
                        Space(4.h),
                        if (_activeButtonIndex == 1)
                          Container(
                            height: 70.h,
                            width: 85.w,
                            child: GridView.builder(
                              addAutomaticKeepAlives: true,
                              padding: EdgeInsets.symmetric(
                                  vertical: 0.8.h, horizontal: 3.w),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1,
                                crossAxisCount: 3, // Number of items in a row
                                crossAxisSpacing:
                                    4.w, // Spacing between columns
                                mainAxisSpacing: 1.5.h, // Spacing between rows
                              ),
                              itemCount: 35, // Total number of items
                              itemBuilder: (context, index) {
                                // You can replace this container with your custom item widget
                                return Container(
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
                                      cornerRadius: 25,
                                      cornerSmoothing: 1,
                                    ),
                                    child: Image.network(
                                        'https://yt3.googleusercontent.com/MANvrSkn-NMy7yTy-dErFKIS0ML4F6rMl-aE4b6P_lYN-StnCIEQfEH8H6fudTC3p0Oof3Pd=s176-c-k-c0x00ffffff-no-rj'),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (_activeButtonIndex == 2) Text('Menu'),
                        if (_activeButtonIndex == 3) Text('Reviews')
                      ]),
                ),
              )
            ],
          ),
        ),
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
        height: 5.h,
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
                color: Color.fromRGBO(177, 217, 216, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                ),
              )
            : ShapeDecoration(shape: SmoothRectangleBorder()),
        child: Center(
          child: Text(
            txt,
            style: TextStyle(
              color: isActive ? Colors.white : Color(0xFF094B60),
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
