import 'dart:developer';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_item.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostsScreen extends StatefulWidget {
  static const routeName = '/home/your-posts-screen';

  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  bool _didChanged = true;
  List<dynamic> data = [];
  int? index;
  String? userId;
  String? type;
  String? isSelfProfile;
  UserModel? userModel;
  bool darkMode = false;

  @override
  void didChangeDependencies() {
    getDarkModeStatus();
    if (_didChanged) {
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      data = arguments['data'] as List<dynamic>;
      // data = data.reversed.toList();
      index = arguments['index'] as int;
      userId = arguments['userId'] as String;
      isSelfProfile = arguments['isSelfProfile'] as String;
      if (arguments['type'] == "not self") {
        userModel = arguments['userModel'] as UserModel;
      }
      print("index:: $index");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToPost();
      });
      _didChanged = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getDarkModeStatus();
   

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        55.h + 65.h * (index - 1),
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });*/
  }
Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });

    return prefs.getString('dark_mode');
  }

  Future<void> _refreshFeed() async {
    final Data = await Provider.of<Auth>(context, listen: false).getFeed(userId)
        as List<dynamic>;
    print("dataref ${Data}");
    Navigator.of(context)
        .pushReplacementNamed(PostsScreen.routeName, arguments: {
      'data': Data,
      'index': 0,
      "userId": userId,
      "userModel": userModel,
      "type": type,
      "isSelfProfile": isSelfProfile
    });
  }

void _scrollToPost() {
  // Get the total height of the viewport (screen height)
  double viewportHeight = _scrollController.position.viewportDimension;
 

  // Calculate the height of a single item (assuming each item has the same height)
  double singleItemHeight = 70.h; // Adjust this based on the actual height of each item
 

  // Calculate the target offset to center the clicked post and move it slightly down by 10 pixels
  double targetOffset = (singleItemHeight * (index ?? 0)) -
      (viewportHeight / 2) +
      (singleItemHeight / 3.5) -
      50.0; // Move 10 pixels down
  

  // Ensure the targetOffset is within valid bounds
  double maxScrollExtent = _scrollController.position.maxScrollExtent;
  

  // Check if the targetOffset plus viewportHeight would exceed the maxScrollExtent
  if (targetOffset + viewportHeight / 2 > maxScrollExtent) {
    // If so, adjust the offset to scroll as close to the end as possible
    targetOffset = maxScrollExtent;
   
  } else {
    // Otherwise, clamp the offset to valid bounds
    targetOffset = targetOffset.clamp(0.0, maxScrollExtent);
   
  }

  _scrollController.animateTo(
    targetOffset,
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeInOut,
  );
}
  
  @override
  Widget build(BuildContext context) {
    String? userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];

    Color colorProfile;
    if (userType == 'Vendor') {
      colorProfile = const Color(0xFFEAF5F7);
    } else if (userType == 'Customer') {
      colorProfile = const Color(0xFFD9D9D9);
    } else if (userType == 'Supplier') {
      colorProfile = Color(0xFFE4F4DA);
    } else {
      colorProfile = const Color(
          0xFFEAF5F7); // Default color if user_type is none of the above
    }
    return Scaffold(
      backgroundColor:darkMode?Color(0xff1D1D1D): Color(0xffEAF5F7),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: SingleChildScrollView(
          controller: _scrollController,
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
                      padding: EdgeInsets.only(
                        top: 1.h,
                        bottom: 1.h,
                        right: 3.w,
                        left: 5.w,
                      ),
                      child: const Text(
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
                    'Posts',
                    style: TextStyle(
                      color:darkMode?Colors.white: Color(0xFF094B60),
                      fontSize: 26,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      height: 0.03,
                      letterSpacing: 0.78,
                    ),
                  )
                ],
              ),
              Space(2.h),
              // Space(400.h),
              Column(
                children: data.map<Widget>((item) {
                  // print(item);
                  bool _isMultiple = item['multiple_files'] != null &&
                      item['multiple_files'].length != 0;
                  log("item:: $item  $userId $_isMultiple $isSelfProfile");
                  return PostItem(
                    isMultiple: _isMultiple,
                    data: item,
                    userModel: userModel ?? UserModel(),
                    isSharePost: isSelfProfile ?? "",
                    isProfilePost: true,
                    userId: userId,
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
