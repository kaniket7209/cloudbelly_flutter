// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/screens/Tabs/Home/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/api_services_profile_page.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return SingleChildScrollView(
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
                        children: [
                          CustomIconButton(
                            ic: Icons.arrow_back_ios_new_outlined,
                            onTap: () {},
                          ),
                          Space(
                            25.w,
                            isHorizontal: true,
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
                                      color: Color.fromRGBO(31, 111, 109, 0.6),
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
                          Spacer(),
                          CustomIconButton(
                            boxColor: Color.fromRGBO(38, 115, 140, 1),
                            color: Colors.white,
                            ic: Icons.add,
                            onTap: () async {
                              String url = await HomeApi().pickImageAndUpoad();
                              if (url == 'file size very large')
                                TOastNotification()
                                    .showErrorToast(context, url);
                              else if (url != '')
                                _showModalSheetForNewPost(context, url);
                              else {
                                TOastNotification().showErrorToast(
                                    context, 'Error While Uploading Image');
                              }
                            },
                          ),
                          Space(
                            3.w,
                            isHorizontal: true,
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
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
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
                          width: 85.w,
                          child: GridView.builder(
                            physics:
                                NeverScrollableScrollPhysics(), // Disable scrolling
                            shrinkWrap:
                                true, // Allow the GridView to shrink-wrap its content
                            addAutomaticKeepAlives: true,

                            padding: EdgeInsets.symmetric(
                                vertical: 0.8.h, horizontal: 3.w),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1,
                              crossAxisCount: 3, // Number of items in a row
                              crossAxisSpacing: 4.w, // Spacing between columns
                              mainAxisSpacing: 1.5.h, // Spacing between rows
                            ),
                            itemCount: 31, // Total number of items
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
    );
  }

  Future<dynamic> _showModalSheetForNewPost(
      BuildContext context, String imageUrl) {
    TextEditingController _textFieldController = TextEditingController();
    String caption = '';
    List<String> _hasTagList = [
      '#chicken',
      '#tandoori',
      '#boneless',
      '#For2',
      '#chicken',
      '#eggless',
      '#tranding',
    ];

    Future<void> _shareButton() async {
      List<String> tags = _textFieldController.text
          .split(',')
          .map((String s) => s.trim())
          .toList();
      String msg = await ProfileApi().createPost(imageUrl, tags, caption);
      if (msg == "Post metadata updated successfully") {
        TOastNotification()
            .showSuccesToast(context, 'Post Created successfully!');

        Navigator.of(context).pop();
      } else {
        TOastNotification().showErrorToast(context, 'Error!');
      }
    }

    return showModalBottomSheet(
      // useSafeArea: true,

      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        return Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.only(
                  topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          padding:
              EdgeInsets.only(left: 6.w, right: 6.w, top: 2.h, bottom: 2.h),
          child: SingleChildScrollView(
            child: Column(
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
                      height: 9,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFA6E00),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ),
                Space(4.h),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '<<',
                        style: TextStyle(
                          color: Color(0xFFFA6E00),
                          fontSize: 22,
                          fontFamily: 'Kavoon',
                          fontWeight: FontWeight.w400,
                          height: 0.04,
                          letterSpacing: 0.66,
                        ),
                      ),
                    ),
                    Text(
                      'New post',
                      style: TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 22,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0.04,
                        letterSpacing: 0.66,
                      ),
                    )
                  ],
                ),
                Space(3.h),
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: const ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          color: Color.fromRGBO(124, 193, 191, 0.3),
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
                      child: Image.network(imageUrl),
                    ),
                  ),
                ),
                Space(3.h),
                TextField(
                  onChanged: (value) {
                    caption = value.toString();
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
                    hintText: 'Write a caption...',
                    hintStyle: TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 12,
                      fontFamily: 'Product Sans Medium',
                      fontWeight: FontWeight.w500,
                      height: 0.14,
                      letterSpacing: 0.36,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                Center(
                  child: Container(
                    width: 85.w,
                    height: 2,
                    decoration: BoxDecoration(color: Color(0xFFFA6E00)),
                  ),
                ),
                Space(5.h),
                Text(
                  'Give hashtags',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 14,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.14,
                  ),
                ),
                Space(2.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  // rgba(165, 200, 199, 1),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        color: Color.fromRGBO(165, 200, 199, 0.6),
                        blurRadius: 20,
                      )
                    ],
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                    ),
                  ),
                  height: 6.h,
                  child: TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.only(left: 14),
                      hintText: 'Link your post with your menu by #tags',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0A4C61),
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {},
                  ),
                ),
                Space(2.h),
                SizedBox(
                  height: 10.h,
                  child: GridView.builder(
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling
                    shrinkWrap:
                        true, // Allow the GridView to shrink-wrap its content
                    addAutomaticKeepAlives: true,

                    padding:
                        EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 3.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 2.1,
                      crossAxisCount: 4, // Number of items in a row
                      crossAxisSpacing: 3.w, // Spacing between columns
                      mainAxisSpacing: 1.5.h, // Spacing between rows
                    ),
                    itemCount: _hasTagList.length,
                    itemBuilder: (context, index) {
                      return TouchableOpacity(
                          onTap: () {
                            _textFieldController.text =
                                _textFieldController.text == ''
                                    ? _textFieldController.text +
                                        '${_hasTagList[index]}'
                                    : _textFieldController.text +
                                        ', ${_hasTagList[index]}';
                          },
                          child: Container(
                              decoration: ShapeDecoration(
                                color: Color.fromRGBO(239, 255, 254, 1),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius.all(
                                      SmoothRadius(
                                          cornerRadius: 10,
                                          cornerSmoothing: 1)),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _hasTagList[index],
                                  style: TextStyle(
                                    color: Color(0xFF0A4C61),
                                    fontSize: 12,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                    letterSpacing: 0.12,
                                  ),
                                ),
                              )));
                    },
                  ),
                ),
                Space(10.h),
                TouchableOpacity(
                  onTap: () {
                    _shareButton();
                  },
                  child: Container(
                      height: 6.h,
                      decoration: ShapeDecoration(
                        color: Color.fromRGBO(250, 110, 0, 1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.all(SmoothRadius(
                              cornerRadius: 10, cornerSmoothing: 1)),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w700,
                            height: 0,
                            letterSpacing: 0.16,
                          ),
                        ),
                      )),
                ),
                Space(15.h),
              ],
            ),
          ),
        );
      },
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
