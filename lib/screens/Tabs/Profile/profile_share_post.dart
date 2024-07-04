import 'dart:developer';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/share_profile_post_item.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfileSharePost extends StatefulWidget {
  static const routeName = '/home/profile-posts-screen';
  const ProfileSharePost({super.key});

  @override
  State<ProfileSharePost> createState() => _ProfileSharePostState();
}

class _ProfileSharePostState extends State<ProfileSharePost> {
  bool _didChanged = true;
  List<dynamic> data = [];
  int? index;
  String? userId;

  @override
  void didChangeDependencies() {
    if (_didChanged) {
      final Map<String, dynamic> arguments =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      data = arguments['data'] as List<dynamic>;
      // data = data.reversed.toList();
      index = arguments['index'] as int;
      userId = arguments['userId'] as String;
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
    print("math:: ${55.h + 65.0.h * (index ?? 0)}");
    print("abcduserIds:::: ${userId}");

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        55.h + 65.h * (index - 1),
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });*/
  }

  Future<void> _refreshFeed() async {
    final Data = await Provider.of<Auth>(context, listen: false).getFeed(userId) as List<dynamic>;

    Navigator.of(context).pushReplacementNamed(ProfileSharePost.routeName,
        arguments: {'data': Data, 'index': 0, "userId" : userId});
  }

  void _scrollToPost() {
    double itemPosition =
        _scrollController.position.viewportDimension * (index ?? 0);
    print("itemPosition:: ${_scrollController.position.viewportDimension}");
    _scrollController.animateTo(
      55.h + 65.h * (index  ?? 0),
      //360.0 * (index ?? 0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
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
                  const Text(
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
              Space(2.h),
              // Space(400.h),
              Column(
                children: data.map<Widget>((item) {
                  // print(item);
                  bool _isMultiple = item['multiple_files'] != null &&
                      item['multiple_files'].length != 0;
                  log("item:: $userId");
                  return ShareProfilePostItem(
                    isMultiple: _isMultiple,
                    data: item,
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
