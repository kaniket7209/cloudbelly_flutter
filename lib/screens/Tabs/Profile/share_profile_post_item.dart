import 'dart:math';
import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/screens/Tabs/Feed/feed_bottom_sheet.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_item.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_view.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';

class ShareProfilePostItem extends StatefulWidget {
  const ShareProfilePostItem({
    super.key,
    required bool isMultiple,
    required this.data,
    this.userId,
  }) : _isMultiple = isMultiple;
  final bool _isMultiple;
  final data;
  final String? userId;
  @override
  State<ShareProfilePostItem> createState() => _ShareProfilePostItemState();
}

class _ShareProfilePostItemState extends State<ShareProfilePostItem> {
  bool _didUpdate = true;

  String discription = '';

  String caption1 = '';
  String caption2 = '';
  List<ProductDetails> productDetails = [];
  @override
  void didChangeDependencies() {
    if (_didUpdate) {
      checkFollow();
      discription = widget.data['caption'] ?? '';

      caption1 = getFittedText(discription, context)[0];

      caption2 = getFittedText(discription, context)[1];
      _getLikeData();
      //getProductDetails();

      _didUpdate = false;
    }

    super.didChangeDependencies();
  }

  List<String> getFittedText(String text, BuildContext context) {
    text = widget.data['caption'] ?? '';
    if (text.length < 50) {
      return [text, ''];
    } else {
      String text1 = text.substring(0, 50);

      text1 = text1 + ' - ';
      String text2 = text.length > 50 ? text.substring(50) : '';
      return [text1, text2];
    }
  }

  void getProductDetails() async {
    AppWideLoadingBanner().loadingBanner(context);
    print(widget.data + "gaurav");
    List<dynamic> productIds = widget.data['menu_items'];
    productDetails = await Provider.of<Auth>(context, listen: false)
        .getProductDetails(productIds)
        .then((value) {
      print("details:: $value");
      Navigator.of(context).pop();
      context.read<TransitionEffect>().setBlurSigma(5.0);
      FeedBottomSheet()
          .ProductsInPostSheet(context, widget.data, _isLiked, value, "");
      return [];
    });

    setState(() {});
  }

  bool _isLiked = false;

  // List<dynamic> likePorfileUrlList = [];
  void _getLikeData() async {
    List<dynamic> likeIds = widget.data['likes'] ?? [];
    List<dynamic> temp = await Provider.of<Auth>(context).getUserInfo(likeIds);
    temp.forEach((element) {
      if (element is Map) {
        _likeData.add({
          'id': element['_id'] ?? 'default_id',
          'name': element['store_name'] ?? 'default_name',
          'profile_photo': element['profile_photo'] ?? 'default_photo'
        });
        itemsToShow = min(_likeData.length, 2);
      } else {
        print("Unexpected data type: $element");
      }
      setState(() {});
    });
    // print(_likeData);

    _isLiked = (widget.data['likes'] ?? []).contains(
        Provider.of<Auth>(context, listen: false).userData?['user_id']);
  }

  String formatTimeDifference(String timestampString) {
    DateFormat format = DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'");
    DateTime timestamp;

    try {
      timestamp = format.parse(timestampString, true).toLocal();
    } catch (e) {
      print('Error parsing timestamp: $e');
      return 'Invalid timestamp';
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return DateFormat('dd MMMM, yyyy').format(timestamp);
    }
  }

  //SampleItem? selectedMenu;
  bool _showLikeIcon = false;
  List<dynamic> _likeData = [];
  List<String> userId = [];
  int itemsToShow = 0;
  bool _isFollowing = false;

  bool checkFollow() {
    String id = widget.data['user_id'];
    List<dynamic> temp =
        Provider.of<Auth>(context, listen: false).userData?['followings'] ?? [];
    for (var user in temp) {
      if (user['user_id'] == id) {
        _isFollowing = true;
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    print("userID:: ${userId}");
    bool _isFollowing = checkFollow();
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';
    // print(widget.data);
    // final date_time = formatTimeDifference('created_at');
    CarouselController buttonCarouselController = CarouselController();
    return Container(
      // height: caption1 != '' ? 67.h : 63.h,
      margin: EdgeInsets.only(bottom: 2.7.h),
      // padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
            child: Row(
              children: [
                const Space(
                  10,
                  isHorizontal: true,
                ),
                widget.data['profile_photo'] == '' ||
                        widget.data['profile_photo'] == null
                    ? InkWell(
                        onTap: () {
                          print("data:: ${widget.data}");
                          setState(() {
                            userId.add(widget.data['user_id']);
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileView(
                                        userIdList: userId,
                                      ))).then((value) {
                            userId.clear();
                          });
                        },
                        child: Container(
                            height: 35,
                            width: 35,
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: _isVendor
                                      ? const Color.fromRGBO(31, 111, 109, 0.4)
                                      : Provider.of<Auth>(context,
                                                      listen: false)
                                                  .userData?['user_type'] ==
                                              UserType.Supplier.name
                                          ? const Color.fromRGBO(
                                              198, 239, 161, 0.6)
                                          : const Color.fromRGBO(
                                              130, 47, 130, 0.6),
                                  blurRadius: 20,
                                ),
                              ],
                              color: const Color.fromRGBO(31, 111, 109, 0.6),
                              shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                cornerRadius: 10,
                                cornerSmoothing: 1,
                              )),
                            ),
                            child: Center(
                              child: Text(
                                widget.data['store_name'][0].toUpperCase(),
                                style: const TextStyle(fontSize: 20),
                              ),
                            )),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            userId.add(widget.data['user_id']);
                          });
                          print("userId:: $userId");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileView(
                                        userIdList: userId,
                                      )));
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                color: _isVendor
                                    ? const Color.fromRGBO(31, 111, 109, 0.6)
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Supplier.name
                                        ? const Color.fromRGBO(77, 191, 74, 0.5)
                                        : const Color.fromRGBO(
                                            130, 47, 130, 0.7),
                                blurRadius: 20,
                              )
                            ],
                            shape: const SmoothRectangleBorder(),
                          ),
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 10,
                              cornerSmoothing: 1,
                            ),
                            child: Image.network(
                              widget.data['profile_photo'],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  GlobalVariables().loadingBuilderForImage,
                              errorBuilder:
                                  GlobalVariables().ErrorBuilderForImage,
                            ),
                          ),
                        ),
                      ),
                const Space(isHorizontal: true, 15),
                SizedBox(
                  width: 37.w,
                  child: Text(
                    widget.data['store_name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _isVendor
                          ? const Color(0xFF094B60)
                          : const Color(0xFF2E0536),
                      fontSize: 14,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.42,
                    ),
                  ),
                ),
                const Spacer(),
                /* if (!widget.isProfilePost &&
                    !(Provider.of<Auth>(context, listen: false)
                        .userData?['user_id'] ==
                        widget.data['user_id']))*/
                TouchableOpacity(
                  onTap: () async {
                    if (!_isFollowing) {
                      final dynamic response =
                          await Provider.of<Auth>(context, listen: false)
                              .follow(widget.data['user_id']);
                      if (response['code'] == 200) {
                        TOastNotification().showSuccesToast(
                            context, response['body']['message']);
                        Provider.of<Auth>(context, listen: false)
                            .userData?['followings']
                            .add({'user_id': widget.data['user_id']});
                        setState(() {
                          _isFollowing = true;
                        });
                      } else {
                        TOastNotification().showErrorToast(
                            context, response['body']['message']);
                      }
                    } else {
                      final dynamic response =
                          await Provider.of<Auth>(context, listen: false)
                              .unfollow(widget.data['user_id']);
                      if (response['code'] == 200) {
                        TOastNotification().showSuccesToast(
                            context, response['body']['message']);
                        Provider.of<Auth>(context, listen: false)
                            .userData?['followings']
                            .removeWhere((element) =>
                                element['user_id'] == widget.data['user_id']);
                        setState(() {
                          _isFollowing = false;
                        });
                      } else {
                        TOastNotification().showErrorToast(
                            context, response['body']['message']);
                      }
                    }
                    print(Provider.of<Auth>(context, listen: false)
                        .userData?['followings']);
                  },
                  child: Container(
                    width: 70,
                    height: 25,
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          offset: const Offset(3, 6),
                          color: _isVendor
                              ? const Color.fromRGBO(116, 202, 199, 0.79)
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      UserType.Supplier.name
                                  ? const Color.fromRGBO(77, 191, 74, 0.3)
                                  : const Color.fromRGBO(158, 116, 158, 0.6),
                          blurRadius: 20,
                        ),
                      ],
                      color: _isVendor
                          ? const Color.fromRGBO(124, 193, 191, 1)
                          : Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Supplier.name
                              ? const Color(0xFFA3DC76)
                              : const Color(0xFFFA6E00),
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                        cornerRadius: 5,
                        cornerSmoothing: 1,
                      )),
                    ),
                    child: Center(
                      child: Text(
                        _isFollowing ? 'Unfollow' : 'Follow',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Product Sans Medium',
                          fontWeight: FontWeight.w500,
                          height: 0.14,
                          letterSpacing: 0.36,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Space(0.5.h),
          Stack(
            children: [
              !widget._isMultiple
                  ? Hero(
                      tag: widget.data['id'],
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 5.w, bottom: 2.h, right: 5.w),
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              shadows: [
                                _isVendor
                                    ? const BoxShadow(
                                        offset: Offset(0, 4),
                                        color:
                                            Color.fromRGBO(124, 193, 191, 0.6),
                                        blurRadius: 20,
                                      )
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Supplier.name
                                        ? const BoxShadow(
                                            offset: Offset(3, 4),
                                            color: Color.fromRGBO(
                                                77, 191, 74, 0.5),
                                            blurRadius: 20,
                                          )
                                        : const BoxShadow(
                                            offset: Offset(3, 4),
                                            color: Color.fromRGBO(
                                                158, 116, 158, 0.5),
                                            blurRadius: 15,
                                          )
                              ],
                              shape: const SmoothRectangleBorder(),
                            ),
                            child: ClipSmoothRect(
                              radius: SmoothBorderRadius(
                                cornerRadius: 40,
                                cornerSmoothing: 1,
                              ),
                              child: Image.network(
                                widget.data['file_path'],
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    GlobalVariables().loadingBuilderForImage,
                                errorBuilder:
                                    GlobalVariables().ErrorBuilderForImage,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : FlutterCarousel(
                      items: (widget.data['multiple_files'] as List<dynamic>)
                          .map<Widget>((url) {
                        return Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 5.w, right: 5.w),
                              width: double.infinity,
                              // Take up full width of the screen
                              decoration: ShapeDecoration(
                                shadows: [
                                  _isVendor
                                      ? const BoxShadow(
                                          offset: Offset(0, 4),
                                          color: Color.fromRGBO(
                                              124, 193, 191, 0.6),
                                          blurRadius: 20,
                                        )
                                      : Provider.of<Auth>(context,
                                                      listen: false)
                                                  .userData?['user_type'] ==
                                              UserType.Supplier.name
                                          ? const BoxShadow(
                                              offset: Offset(3, 4),
                                              color: Color.fromRGBO(
                                                  77, 191, 74, 0.5),
                                              blurRadius: 20,
                                            )
                                          : const BoxShadow(
                                              offset: Offset(3, 4),
                                              color: Color.fromRGBO(
                                                  158, 116, 158, 0.5),
                                              blurRadius: 15,
                                            )
                                ],
                                shape: const SmoothRectangleBorder(),
                              ),
                              child: ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                  cornerRadius: 40,
                                  cornerSmoothing: 1,
                                ),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      GlobalVariables().loadingBuilderForImage,
                                  errorBuilder:
                                      GlobalVariables().ErrorBuilderForImage,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        autoPlay: false,
                        controller: buttonCarouselController,
                        enlargeCenterPage: true,
                        clipBehavior: Clip.none,
                        viewportFraction: 1.0,
                        aspectRatio: 1,
                        // Set overall carousel aspect ratio to 1:1
                        initialPage: 0,
                      ),
                    ),
              if (_showLikeIcon) // Show like icon if _showLikeIcon is true
                Positioned(
                  left: 35.w,
                  top: 15.h,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showLikeIcon ? 0.8 : 0.0,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      builder: (_, scale, __) {
                        return Transform.scale(
                          scale: scale,
                          child: const RotationTransition(
                            turns: AlwaysStoppedAnimation(
                                -0), // Rotate by 30 degrees
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 100, // Adjust size as needed
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              //search menu items sheet icon
              if (widget.data['menu_items'] != null &&
                  (widget.data['menu_items'] as List<dynamic>).length != 0)
                Positioned(
                  right: 35,
                  bottom: 5,
                  child: TouchableOpacity(
                    onTap: () async {
                      getProductDetails();
                      // context.read<TransitionEffect>().setBlurSigma(5.0);
                      //return FeedBottomSheet().ProductsInPostSheet(context, widget.data, _isLiked);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromRGBO(250, 110, 0, 1),
                            Color.fromRGBO(254, 209, 112, 1)
                          ],
                        ),
                        shadows: [
                          const BoxShadow(
                            offset: Offset(0, 4),
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 4,
                          ),
                        ],
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                          cornerRadius: 15,
                          cornerSmoothing: 1,
                        )),
                      ),
                      child: const Icon(Icons.search, size: 29),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 3,
                    ),
                    // Text('knknhkink'),
                    // SvgPicture.asset(
                    //   'assets/icons/Favorite.svg',
                    //   color: Colors.red,
                    //   allowDrawingOutsideViewBox: true,
                    //   width: 100,
                    // ),
                    //like button
                    IconButton(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity),
                      // padding: EdgeInsets.only(left: 10),
                      // pa
                      onPressed: () async {
                        print("abcds:: ${widget.userId}");
                        String code = '';

                        code = await Provider.of<Auth>(context, listen: false)
                            .likePost(
                                widget.data['id'], widget.data['user_id']);

                        if (code == '200') {
                          setState(() {
                            _isLiked = !_isLiked;
                            if (_isLiked) {
                              setState(() {
                                _likeData.add({
                                  'id':
                                      Provider.of<Auth>(context, listen: false)
                                          .userData?['user_id'],
                                  'profile_photo':
                                      Provider.of<Auth>(context, listen: false)
                                          .logo_url,
                                  'name':
                                      Provider.of<Auth>(context, listen: false)
                                          .userData?['store_name'],
                                });
                              });
                            } else {
                              setState(() {
                                _likeData.removeWhere(
                                  (element) =>
                                      element['id'] ==
                                      Provider.of<Auth>(context, listen: false)
                                          .userData?['user_id'],
                                );
                              });
                            }
                            if (_isLiked == true) _showLikeIcon = true;
                          });
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {
                              _showLikeIcon = false;
                            });
                          });
                        } else {
                          TOastNotification().showErrorToast(context, 'Error!');
                        }
                      },
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 3000),
                        curve: Curves.easeInOut,
                        child: _isLiked
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 20,
                              )
                            : SvgPicture.asset(
                                /*_isLiked ?  Assets.favourite_svg :*/
                                Assets.favourite_svg,
                                // colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.xor)
                              ),
                        /* color: _isLiked
                              ? Colors.red
                              : null,*/
                        height: 20,
                        width: 20,
                        // Change color when liked
                      ),
                    ),
                    //comment button
                    IconButton(
                        visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          AppWideLoadingBanner().loadingBanner(context);
                          List<String> userIds = [];
                          for (var item in widget.data['comments'] ?? []) {
                            String userId = item['user_id'];
                            userIds.add(userId);
                          }
                          final temp =
                              await Provider.of<Auth>(context, listen: false)
                                  .getUserInfo(userIds);
                          for (int i = 0;
                              i < (widget.data['comments'] ?? []).length;
                              i++) {
                            widget.data['comments'][i]['store_name'] =
                                temp[i]['store_name'];
                            widget.data['comments'][i]['profile_photo'] =
                                temp[i]['profile_photo'];
                          }
                          Navigator.of(context).pop();
                          AppWideBottomSheet()
                              .showSheet(
                                  context,
                                  CommentSheetContent(
                                    userData: temp,
                                    data: widget.data,
                                    isProfilePost: false,
                                  ),
                                  70.h)
                              .then((value) {
                            setState(() {});
                          });
                        },
                        icon: SvgPicture.asset(
                          Assets.comment_svg,
                          height: 20,
                          width: 20,
                        )),
                    //icon: const Icon(Icons.mode_comment_outlined)),
                    //share button
                    IconButton(
                        visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final DynamicLinkParameters parameters =
                              DynamicLinkParameters(
                            uriPrefix: 'https://app.cloudbelly.in',
                            link: Uri.parse(
                                'https://app.cloudbelly.in/?postId=${widget.data['id']}'),
                            androidParameters: const AndroidParameters(
                              packageName: 'com.app.cloudbelly_app',
                            ),
                          );

                          final Uri shortUrl = parameters.link;
                          // print(shortUrl);
                          Share.share("${shortUrl}");
                        },
                        icon: SvgPicture.asset(
                          Assets.share,
                          height: 20,
                          width: 20,
                        ))
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 3.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Space(14),
                        Row(
                          children: [
                            if (_likeData.length != 0 &&
                                _likeData[0]['profile_photo'] != '' &&
                                _likeData[0]['profile_photo'] != null)
                              Container(
                                width: 17,
                                height: 17,
                                decoration: ShapeDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        _likeData[0]['profile_photo']),
                                    fit: BoxFit.fill,
                                  ),
                                  shape: const OvalBorder(
                                    side: BorderSide(
                                      width: 2,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside,
                                      color: Color(0xFFEAF5F7),
                                    ),
                                  ),
                                ),
                              ),
                            if (_likeData.length > 1)
                              for (int i = 0;
                                  (_likeData.length > 2 ? i < 2 : i < 1);
                                  i++)
                                /* Container(
                                    width: 17,
                                    height: 17,
                                    decoration: ShapeDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            _likeData[i + 1]['profile_photo']),
                                        fit: BoxFit.fill,
                                      ),
                                      shape: const OvalBorder(
                                        side: BorderSide(
                                          width: 2,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Color(0xFFEAF5F7),
                                        ),
                                      ),
                                    ),
                                  ) :*/
                                if (_likeData[i + 1]['profile_photo'] != '' &&
                                    _likeData[i + 1]['profile_photo'] != null)
                                  Container(
                                    width: 17,
                                    height: 17,
                                    decoration: ShapeDecoration(
                                      color: const Color.fromRGBO(
                                          31, 111, 109, 0.6),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            _likeData[i + 1]['profile_photo']),
                                        fit: BoxFit.fill,
                                      ),
                                      shape: const OvalBorder(
                                        side: BorderSide(
                                          width: 2,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Color(0xFFEAF5F7),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _likeData[i + 1]['name'][0]
                                            .toUpperCase(),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                            if (_likeData.length != 0 &&
                                _likeData[0]['profile_photo'] != '')
                              const Space(
                                7,
                                isHorizontal: true,
                              ),
                            Text(
                              'Liked by',
                              style: TextStyle(
                                color: _isVendor
                                    ? const Color(0xFF519896)
                                    : const Color(0xFFB232CB),
                                fontSize: 12,
                                fontFamily: 'Product Sans Medium',
                                fontWeight: FontWeight.w500,
                                height: 0,
                                letterSpacing: 0.12,
                              ),
                            ),
                            const Space(isHorizontal: true, 5),
                            Text(
                              '${_likeData.length == 0 ? '0 people' : _likeData.length == 1 ? _likeData[0]['name'] : '${_likeData[0]['name']} and ${_likeData.length - 1} others'}',
                              style: TextStyle(
                                color: _isVendor
                                    ? const Color(0xFF0A4C61)
                                    : const Color(0xFF2E0536),
                                fontSize: 12,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w700,
                                height: 0,
                                letterSpacing: 0.12,
                              ),
                            )
                          ],
                        ),
                        if (caption1 != '')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Space(1.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.data['store_name'],
                                    style: const TextStyle(
                                      color: Color(0xFFFA6E00),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.36,
                                    ),
                                  ),
                                  const Space(isHorizontal: true, 9),
                                  Expanded(
                                    child: SizedBox(
                                      child: Text(
                                        caption1,
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: _isVendor
                                              ? const Color(0xFF0A4C61)
                                              : const Color(0xFF2E0536),
                                          fontSize: 12,
                                          fontFamily: 'Product Sans Medium',
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.12,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              if (caption2.length > 0)
                                SizedBox(
                                  // height: 1.4.h,
                                  child: Text(
                                    caption2,
                                    maxLines: null,
                                    // overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _isVendor
                                          ? const Color(0xFF0A4C61)
                                          : const Color(0xFF2E0536),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans Medium',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        TouchableOpacity(
                          onTap: () async {
                            AppWideLoadingBanner().loadingBanner(context);
                            List<String> userIds = [];
                            // print(widget.data['comments'].length);
                            // if(widget.data['comments']==null)
                            for (var item in widget.data['comments'] ?? []) {
                              String userId = item['user_id'];
                              userIds.add(userId);
                            }
                            final temp =
                                await Provider.of<Auth>(context, listen: false)
                                    .getUserInfo(userIds);

                            for (int i = 0;
                                i < (widget.data['comments'] ?? []).length;
                                i++) {
                              widget.data['comments'][i]['store_name'] =
                                  temp[i]['store_name'];
                              widget.data['comments'][i]['profile_photo'] =
                                  temp[i]['profile_photo'];
                            }
                            Navigator.of(context).pop();

                            AppWideBottomSheet()
                                .showSheet(
                                    context,
                                    CommentSheetContent(
                                      userData: temp,
                                      data: widget.data,
                                      isProfilePost: false,
                                    ),
                                    70.h)
                                .then((value) {
                              setState(() {});
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0.6.h,
                            ),
                            child: Text(
                              (widget.data['comments'] ?? []).length > 0
                                  ? 'View ${(widget.data['comments'] ?? []).length} comments'
                                  : '${(widget.data['comments'] ?? []).length} comments',
                              style: TextStyle(
                                color: _isVendor
                                    ? const Color(0xFF519796)
                                    : const Color(0xFFB232CB),
                                fontSize: 11,
                                fontFamily: 'Product Sans Medium',
                                fontWeight: FontWeight.w500,
                                height: 0,
                                letterSpacing: 0.11,
                              ),
                            ),
                          ),
                        ),
                        Space(0.3.h),
                        Text(
                          '${formatTimeDifference(widget.data['created_at'])}',
                          style: TextStyle(
                            color: _isVendor
                                ? const Color(0xFF519796)
                                : const Color(0xFFB232CB),
                            fontSize: 9,
                            fontFamily: 'Product Sans Medium',
                            fontWeight: FontWeight.w500,
                            height: 0,
                            letterSpacing: 0.09,
                          ),
                        )
                      ]),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle tap on the area around the BackdropFilter
              print('Tapped outside of the modal bottom sheet');
              // You can add any logic here, such as dismissing the modal bottom sheet
              // For example:
              // Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.transparent, // Transparent color
            ),
          )
        ],
      ),
    );
  }
}
