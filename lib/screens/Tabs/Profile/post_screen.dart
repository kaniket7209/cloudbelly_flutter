import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_item.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:flutter/material.dart';
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
                future: getFeed(),
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
                          return PostItem(
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
