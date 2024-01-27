// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/api_services_profile_page.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/create_feed.dart';
import 'package:cloudbelly_app/widgets/appwide_banner.dart';
import 'package:cloudbelly_app/widgets/custom_icon_button.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
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
                              List<String> url = await ProfileApi()
                                  .pickMultipleImagesAndUpoad();
                              // List<String> url = [
                              //   'https://yt3.googleusercontent.com/MANvrSkn-NMy7yTy-dErFKIS0ML4F6rMl-aE4b6P_lYN-StnCIEQfEH8H6fudTC3p0Oof3Pd=s176-c-k-c0x00ffffff-no-rj',
                              //   'https://yt3.googleusercontent.com/Gvn-OAu94UsSQPp5zEMpC2ZMY3Yv1wUNbFaqkfBAYpXRLROA_nz3lS-Y9jQKJ3SGNVKX81xSpRM=s176-c-k-c0x00ffffff-no-rj',
                              //   'https://yt3.googleusercontent.com/zgMN9BuSQByG1SrpmLwcNB3MQhjDhS_pl9H1h7TaRievMfS4UpU7Z36j77z5_hnIW4N8uFX3NA=s176-c-k-c0x00ffffff-no-rj'
                              // ];
                              if (url.length == 0) {
                                TOastNotification().showErrorToast(
                                    context, 'Error While Uploading Image');
                              } else if (url.contains('file size very large'))
                                TOastNotification().showErrorToast(
                                    context, 'file size very large');
                              else if (!url.contains('element'))
                                CreateFeed()
                                    .showModalSheetForNewPost(context, url);
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
                          child: FutureBuilder(
                            future: ProfileApi().getFeed(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                print(snapshot.data);
                                final data = snapshot.data as List<dynamic>;
                                return GridView.builder(
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
                                    crossAxisCount:
                                        3, // Number of items in a row
                                    crossAxisSpacing:
                                        4.w, // Spacing between columns
                                    mainAxisSpacing:
                                        1.5.h, // Spacing between rows
                                  ),
                                  itemCount:
                                      data.length, // Total number of items
                                  itemBuilder: (context, index) {
                                    // You can replace this container with your custom item widget
                                    return FeedWidget(data: data[index]);
                                  },
                                );
                              } else
                                return Center(
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
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
}

class FeedWidget extends StatelessWidget {
  FeedWidget({
    super.key,
    required this.data,
  });

  final dynamic data;
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    bool _isMultiple =
        data['multiple_files'] != null && data['multiple_files'].length != 0;
    return TouchableOpacity(
      onTap: () {
        Navigator.of(context).pushNamed(PostsScreen.routeName);
        // showModalBottomSheet(
        //   // useSafeArea: true,

        //   context: context,
        //   isScrollControlled: true,

        //   builder: (BuildContext context) {
        //     return Container(
        //       decoration: ShapeDecoration(
        //         color: Colors.white,
        //         shape: SmoothRectangleBorder(
        //           borderRadius: SmoothBorderRadius.only(
        //               topLeft:
        //                   SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
        //               topRight:
        //                   SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
        //         ),
        //       ),
        //       height: MediaQuery.of(context).size.height * 0.5,
        //       width: double.infinity,
        //       padding: EdgeInsets.only(
        //           left: 10.w, right: 10.w, top: 2.h, bottom: 2.h),
        //       child: SingleChildScrollView(
        //           child: Column(
        //         children: [
        //           TouchableOpacity(
        //             onTap: () {
        //               return Navigator.of(context).pop();
        //             },
        //             child: Center(
        //               child: Container(
        //                 padding: EdgeInsets.symmetric(
        //                     vertical: 1.h, horizontal: 3.w),
        //                 width: 65,
        //                 height: 9,
        //                 decoration: ShapeDecoration(
        //                   color: const Color(0xFFFA6E00),
        //                   shape: RoundedRectangleBorder(
        //                       borderRadius: BorderRadius.circular(6)),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           Space(4.h),
        //           Row(
        //             children: [
        //               Padding(
        //                 padding: const EdgeInsets.all(8.0),
        //                 child: Text(
        //                   '<<',
        //                   style: TextStyle(
        //                     color: Color(0xFFFA6E00),
        //                     fontSize: 22,
        //                     fontFamily: 'Kavoon',
        //                     fontWeight: FontWeight.w400,
        //                     height: 0.04,
        //                     letterSpacing: 0.66,
        //                   ),
        //                 ),
        //               ),
        //               Text(
        //                 'Your Post',
        //                 style: TextStyle(
        //                   color: Color(0xFF094B60),
        //                   fontSize: 22,
        //                   fontFamily: 'Product Sans',
        //                   fontWeight: FontWeight.w700,
        //                   height: 0.04,
        //                   letterSpacing: 0.66,
        //                 ),
        //               )
        //             ],
        //           ),
        //           Space(3.h),
        //           !_isMultiple
        //               ? Center(
        //                   child: Container(
        //                     height: 200,
        //                     width: 200,
        //                     decoration: const ShapeDecoration(
        //                       shadows: [
        //                         BoxShadow(
        //                           offset: Offset(0, 4),
        //                           color: Color.fromRGBO(124, 193, 191, 0.3),
        //                           blurRadius: 20,
        //                         )
        //                       ],
        //                       shape: SmoothRectangleBorder(),
        //                     ),
        //                     child: ClipSmoothRect(
        //                       radius: SmoothBorderRadius(
        //                         cornerRadius: 15,
        //                         cornerSmoothing: 1,
        //                       ),
        //                       child: Image.network(data['file_path']),
        //                     ),
        //                   ),
        //                 )
        //               : Center(
        //                   child: FlutterCarousel(
        //                     items: (data['multiple_files'] as List<dynamic>)
        //                         .map<Widget>((url) {
        //                       return Container(
        //                         // height: 15.h,
        //                         decoration: const ShapeDecoration(
        //                           shadows: [
        //                             BoxShadow(
        //                               offset: Offset(0, 4),
        //                               color: Color.fromRGBO(124, 193, 191, 0.3),
        //                               blurRadius: 20,
        //                             )
        //                           ],
        //                           shape: SmoothRectangleBorder(),
        //                         ),
        //                         child: ClipSmoothRect(
        //                           radius: SmoothBorderRadius(
        //                             cornerRadius: 15,
        //                             cornerSmoothing: 1,
        //                           ),
        //                           child: AspectRatio(
        //                             aspectRatio: 1,
        //                             child: Image.network(
        //                               url,

        //                               fit: BoxFit
        //                                   .cover, // Adjust the fit as needed
        //                             ),
        //                           ),
        //                         ),
        //                       );
        //                     }).toList(),
        //                     options: CarouselOptions(
        //                       autoPlay: false,
        //                       controller: buttonCarouselController,
        //                       enlargeCenterPage: true,
        //                       viewportFraction: 0.9,
        //                       aspectRatio: 2.0,
        //                       initialPage: 0,
        //                     ),
        //                   ),
        //                 ),
        //           Space(3.h),
        //           Row(
        //             children: [
        //               Text(
        //                 'User_name :',
        //                 style: TextStyle(
        //                   color: Color(0xFF0A4C61),
        //                   fontSize: 14,
        //                   fontFamily: 'Product Sans',
        //                   fontWeight: FontWeight.w700,
        //                   height: 0,
        //                   letterSpacing: 0.14,
        //                 ),
        //               ),
        //               Space(isHorizontal: true, 4.w),
        //               Text(
        //                 data['caption'],
        //                 style: TextStyle(
        //                   color: Color(0xFF0A4C61),
        //                   fontSize: 12,
        //                   fontFamily: 'Product Sans',
        //                   fontWeight: FontWeight.w400,
        //                   height: 0,
        //                   letterSpacing: 0.12,
        //                 ),
        //               )
        //             ],
        //           ),
        //           Row(
        //             children: [
        //               Text(
        //                 'Hastags :',
        //                 style: TextStyle(
        //                   color: Color(0xFF0A4C61),
        //                   fontSize: 14,
        //                   fontFamily: 'Product Sans',
        //                   fontWeight: FontWeight.w700,
        //                   height: 0,
        //                   letterSpacing: 0.14,
        //                 ),
        //               ),
        //               Space(isHorizontal: true, 4.w),
        //               for (int i = 0;
        //                   i < (data['tags'] as List<dynamic>).length;
        //                   i++)
        //                 Container(
        //                   padding: EdgeInsets.only(right: 3.w),
        //                   child: Text(
        //                     data['tags'][i],
        //                     style: TextStyle(
        //                       color: Color(0xFF0A4C61),
        //                       fontSize: 12,
        //                       fontFamily: 'Product Sans',
        //                       fontWeight: FontWeight.w400,
        //                       height: 0,
        //                       letterSpacing: 0.12,
        //                     ),
        //                   ),
        //                 )
        //             ],
        //           )
        //         ],
        //       )),
        //     );
        //   },
        // );
      },
      child: Stack(
        children: [
          Container(
            height: 100,
            width: 100,
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
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
              child: Image.network(
                data['file_path'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (data['multiple_files'] != null &&
              data['multiple_files'].length != 0)
            Positioned(
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
