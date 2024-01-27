import 'package:cloudbelly_app/screens/Tabs/Profile/api_services_profile_page.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PostsScreen extends StatefulWidget {
  static const routeName = '/home/your-posts-screen';
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  // bool _isMultiple = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Space(7.h),
            Row(
              children: [
                TouchableOpacity(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    // width: 30/,
                    padding: EdgeInsets.only(
                        top: 1.h, bottom: 1.h, right: 3.w, left: 5.w),
                    child: Text(
                      '<<',
                      style: TextStyle(
                        color: Color(0xFFFA6E00),
                        fontSize: 24,
                        fontFamily: 'Kavoon',
                        fontWeight: FontWeight.w900,
                        height: 0.04,
                        letterSpacing: 0.66,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Post',
                  style: TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 26,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                    height: 0.03,
                    letterSpacing: 0.78,
                  ),
                )
              ],
            ),
            FutureBuilder(
                future: ProfileApi().getFeed(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    final data = snapshot.data;

                    return SizedBox(
                      height: 90.7.h,
                      child: ListView.builder(
                        itemCount: (data as List<dynamic>).length,
                        itemBuilder: (context, index) {
                          bool _isMultiple =
                              data[index]['multiple_files'] != null &&
                                  data[index]['multiple_files'].length != 0;
                          return SinglePostWidget(
                              isMultiple: _isMultiple, data: data[index]);
                        },
                      ),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}

class SinglePostWidget extends StatelessWidget {
  SinglePostWidget({
    super.key,
    required bool isMultiple,
    required this.data,
  }) : _isMultiple = isMultiple;

  final bool _isMultiple;
  final data;

  @override
  Widget build(BuildContext context) {
    CarouselController buttonCarouselController = CarouselController();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 35,
                width: 35,
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
                    cornerRadius: 5,
                    cornerSmoothing: 1,
                  ),
                  child: Image.network(
                      'https://yt3.googleusercontent.com/MANvrSkn-NMy7yTy-dErFKIS0ML4F6rMl-aE4b6P_lYN-StnCIEQfEH8H6fudTC3p0Oof3Pd=s176-c-k-c0x00ffffff-no-rj'),
                ),
              ),
              Space(isHorizontal: true, 5.w),
              Text(
                'Geeta Kitchen',
                style: TextStyle(
                  color: Color(0xFF094B60),
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  height: 0.10,
                  letterSpacing: 0.42,
                ),
              ),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
            ],
          ),
          Space(3.h),
          !_isMultiple
              ? Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      width: double.infinity,
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
                        child: Image.network(
                          data['file_path'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )
              : FlutterCarousel(
                  items: (data['multiple_files'] as List<dynamic>)
                      .map<Widget>((url) {
                    return Container(
                      width:
                          double.infinity, // Take up full width of the screen
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
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    autoPlay: false,
                    controller: buttonCarouselController,
                    enlargeCenterPage: true,

                    viewportFraction: 1.0,
                    aspectRatio: 1, // Set overall carousel aspect ratio to 1:1
                    initialPage: 0,
                  ),
                ),
          Space(1.5.h),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.mode_comment_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.share))
            ],
          ),
          Space(1.h),
          Row(
            children: [
              Text(
                'Liked by',
                style: TextStyle(
                  color: Color(0xFF519896),
                  fontSize: 12,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w500,
                  height: 0,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
          Space(3.h),
        ],
      ),
    );
  }
}
