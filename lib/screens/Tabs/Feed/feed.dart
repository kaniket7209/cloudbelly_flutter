import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_item.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Space(10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Cloudbelly',
                style: TextStyle(
                  color: Color(0xFF094B60),
                  fontSize: 24,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                  height: 0.04,
                ),
              ),
            ),
            Space(2.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
                child: Row(
                  children: [
                    StoryItemWidget(
                      url: Provider.of<Auth>(context, listen: true).logo_url,
                      name: Provider.of<Auth>(context, listen: true).store_name,
                      isYours: true,
                    ),
                    for (int index = 0; index < 10; index++)
                      StoryItemWidget(
                        url:
                            'https://yt3.googleusercontent.com/MANvrSkn-NMy7yTy-dErFKIS0ML4F6rMl-aE4b6P_lYN-StnCIEQfEH8H6fudTC3p0Oof3Pd=s176-c-k-c0x00ffffff-no-rj',
                        name: 'Raj',
                      ),
                  ],
                ),
              ),
            ),
            FutureBuilder(
                future: Provider.of<Auth>(context).getFeed(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final data = snapshot.data as List<dynamic>;
                    return Column(
                      children: data.map<Widget>((item) {
                        bool _isMultiple = item['multiple_files'] != null &&
                            item['multiple_files'].length != 0;
                        return PostItem(
                          isProfilePost: false,
                          isMultiple: _isMultiple,
                          data: item,
                        );
                      }).toList(),
                    );
                  }
                  return SizedBox.shrink();
                })
          ],
        ),
      ),
    );
  }
}

class StoryItemWidget extends StatelessWidget {
  String url;
  String name;
  bool isYours;
  StoryItemWidget({
    super.key,
    this.isYours = false,
    required this.url,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 3.w),
      child: Stack(children: [
        url != ''
            ? Container(
                height: 80,
                width: 80,
                decoration: const ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(31, 111, 109, 0.4),
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
              )
            : Container(
                padding: EdgeInsets.all(
                  10,
                ),
                height: 80,
                width: 80,
                decoration: ShapeDecoration(
                  shadows: const [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(31, 111, 109, 0.4),
                      blurRadius: 20,
                    ),
                  ],
                  color: Color.fromRGBO(31, 111, 109, 0.6),
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  )),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
        if (isYours)
          Positioned(
              right: 03,
              bottom: 0,
              child: Container(
                  height: 20,
                  width: 20,
                  decoration: ShapeDecoration(
                    shadows: const [
                      BoxShadow(
                        offset: Offset(0, 4),
                        color: Color.fromRGBO(31, 111, 109, 0.4),
                        blurRadius: 20,
                      ),
                    ],
                    color: Color.fromRGBO(255, 165, 0, 1),
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                      cornerRadius: 5,
                      cornerSmoothing: 1,
                    )),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 20,
                    ),
                  )))
      ]),
    );
  }
}
