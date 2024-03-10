import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_item.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> FeedList = [];
  int index = 1;
  bool _isLoading = false;
  int _pageNumber = 1;
  Future<void> _refreshFeed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pageNumber = 1;
    });
    await Provider.of<Auth>(context, listen: false)
        .getGlobalFeed(_pageNumber)
        .then((newFeed) {
      setState(() {
        FeedList.clear();
        FeedList.addAll(newFeed);

        _isLoading = false;
      });
      final feedData = json.encode(
        {
          'feed': newFeed,
        },
      );
      prefs.setString('feedData', feedData);
    });
  }

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFeed();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreFeed();
    }
  }

  Future<void> _fetchFeed() async {
    setState(() {
      _isLoading = true;
      _pageNumber = 1;
    });
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('feedData')) {
      setState(() {
        final extractedUserData =
            json.decode(prefs.getString('feedData')!) as Map<String, dynamic>;
        print(extractedUserData);
        FeedList.addAll(extractedUserData['feed'] as List<dynamic>);
        _isLoading = false;
      });
    } else {
      await Provider.of<Auth>(context, listen: false)
          .getGlobalFeed(_pageNumber)
          .then((newFeed) {
        setState(() {
          FeedList.addAll(newFeed);
          _isLoading = false;
        });
        final feedData = json.encode(
          {
            'feed': newFeed,
          },
        );
        prefs.setString('feedData', feedData);
      });
    }
  }

  Future<void> _fetchMoreFeed() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _pageNumber++;
      });
      await Provider.of<Auth>(context, listen: false)
          .getGlobalFeed(_pageNumber)
          .then((newFeeds) {
        setState(() {
          FeedList.addAll(newFeeds);
          _isLoadingMore = false;
        });
      });
    }
  }

  // int _pageNumber = 1;/
  @override
  Widget build(BuildContext context) {
    // FeedList = FeedList.reversed.toList();
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),

        // primary: true, // Ensure vertical scroll works
        controller: _scrollController,
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
              Space(3.h),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
              //     child: Row(
              //       children: [
              //         StoryItemWidget(
              //           url: Provider.of<Auth>(context, listen: true).logo_url,
              //           name:
              //               Provider.of<Auth>(context, listen: true).store_name,
              //           isYours: true,
              //         ),
              //         for (int index = 0; index < 10; index++)
              //           StoryItemWidget(
              //             url:
              //                 'https://yt3.googleusercontent.com/MANvrSkn-NMy7yTy-dErFKIS0ML4F6rMl-aE4b6P_lYN-StnCIEQfEH8H6fudTC3p0Oof3Pd=s176-c-k-c0x00ffffff-no-rj',
              //             name: 'Raj',
              //           ),
              //       ],
              //     ),
              //   ),
              // ),
              _isLoading == true
                  ? Center(
                      child: AppWideLoadingBanner().LoadingCircle(context),
                    )
                  : Column(
                      children: FeedList == []
                          ? []
                          : FeedList.map<Widget>((item) {
                              // if (item['user_id'] ==
                              //     Provider.of<Auth>(context).user_id) print(item);
                              bool _isMultiple =
                                  item['multiple_files'] != null &&
                                      item['multiple_files'].length != 0;
                              return PostItem(
                                isProfilePost: false,
                                isMultiple: _isMultiple,
                                data: item,
                              );
                              // return SizedBox.shrink();
                            }).toList(),
                    ),
              _isLoadingMore == true
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppWideLoadingBanner().LoadingCircle(context),
                          Space(isHorizontal: true, 7),
                          Text('Loading more feed...')
                        ],
                      ),
                    )
                  : SizedBox(height: 0, width: 0)
            ],
          ),
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
                height: 60,
                width: 60,
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
                    loadingBuilder: GlobalVariables().loadingBuilderForImage,
                    errorBuilder: GlobalVariables().ErrorBuilderForImage,
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(
                  10,
                ),
                height: 60,
                width: 60,
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
