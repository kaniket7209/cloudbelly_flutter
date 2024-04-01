// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Feed/feed_bottom_sheet.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';

enum SampleItem { itemOne }

class PostItem extends StatefulWidget {
  PostItem({
    super.key,
    required bool isMultiple,
    required this.data,
    this.isProfilePost = true,
  }) : _isMultiple = isMultiple;

  final bool _isMultiple;
  bool isProfilePost;
  final data;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _didUpdate = true;

  String discription = '';

  String caption1 = '';
  String caption2 = '';
  @override
  void didChangeDependencies() {
    if (_didUpdate) {
      checkFollow();
      discription = widget.data['caption'] ?? '';

      caption1 = getFittedText(discription, context)[0];

      caption2 = getFittedText(discription, context)[1];
      _getLikeData();

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

  bool _isLiked = false;
  // List<dynamic> likePorfileUrlList = [];
  void _getLikeData() async {
    List<dynamic> likeIds = widget.data['likes'] ?? [];
    List<dynamic> temp = await Provider.of<Auth>(context).getUserInfo(likeIds);

    setState(() {
      temp.forEach((element) {
        _likeData.add({
          'id': element['_id'],
          'name': element['store_name'],
          'profile_photo': element['profile_photo']
        });
      });
    });

    // print(_likeData);

    _isLiked = (widget.data['likes'] ?? [])
        .contains(Provider.of<Auth>(context, listen: false).user_id);
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

  SampleItem? selectedMenu;
  bool _showLikeIcon = false;
  List<dynamic> _likeData = [];
  bool _isFollowing = false;
  bool checkFollow() {
    String id = widget.isProfilePost ? "" : widget.data['user_id'];
    List<dynamic> temp = Provider.of<Auth>(context, listen: false).followings;
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
    bool _isFollowing = checkFollow();
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userType == 'Vendor';
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
                Space(
                  10,
                  isHorizontal: true,
                ),
                (Provider.of<Auth>(context, listen: false).logo_url == '' &&
                            widget.isProfilePost) ||
                        ((widget.data['profile_photo'] == '' ||
                                widget.data['profile_photo'] == null) &&
                            !widget.isProfilePost)
                    ? Container(
                        height: 35,
                        width: 35,
                        decoration: ShapeDecoration(
                          shadows: [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: _isVendor
                                  ? Color.fromRGBO(31, 111, 109, 0.4)
                                  : Color.fromRGBO(130, 47, 130, 0.4),
                              blurRadius: 20,
                            ),
                          ],
                          color: Color.fromRGBO(31, 111, 109, 0.6),
                          shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 1,
                          )),
                        ),
                        child: Center(
                          child: Text(
                            widget.isProfilePost
                                ? Provider.of<Auth>(context, listen: true)
                                    .store_name[0]
                                    .toUpperCase()
                                : widget.data['store_name'] == ''
                                    ? 'U'
                                    : widget.data['store_name'][0]
                                        .toString()
                                        .toUpperCase(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ))
                    : Container(
                        height: 35,
                        width: 35,
                        decoration: ShapeDecoration(
                          shadows: [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: _isVendor
                                  ? Color.fromRGBO(31, 111, 109, 0.6)
                                  : Color.fromRGBO(130, 47, 130, 0.7),
                              blurRadius: 20,
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
                            widget.isProfilePost
                                ? Provider.of<Auth>(context, listen: false)
                                    .logo_url
                                : widget.data['profile_photo'],
                            fit: BoxFit.cover,
                            loadingBuilder:
                                GlobalVariables().loadingBuilderForImage,
                            errorBuilder:
                                GlobalVariables().ErrorBuilderForImage,
                          ),
                        ),
                      ),
                const Space(isHorizontal: true, 15),
                SizedBox(
                  width: 37.w,
                  child: Text(
                    widget.isProfilePost
                        ? Provider.of<Auth>(context, listen: false).store_name
                        : widget.data['store_name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _isVendor ? Color(0xFF094B60) : Color(0xFF2E0536),
                      fontSize: 14,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.42,
                    ),
                  ),
                ),
                const Spacer(),
                if (!widget.isProfilePost &&
                    !(Provider.of<Auth>(context, listen: false).user_id ==
                        widget.data['user_id']))
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
                              .followings
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
                              .followings
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
                      print(
                          Provider.of<Auth>(context, listen: false).followings);
                    },
                    child: Container(
                      width: 70,
                      height: 25,
                      decoration: ShapeDecoration(
                        shadows: const [
                          BoxShadow(
                            offset: Offset(3, 6),
                            color: Color.fromRGBO(116, 202, 199, 0.79),
                            blurRadius: 20,
                          ),
                        ],
                        color: _isVendor
                            ? const Color.fromRGBO(124, 193, 191, 1)
                            : Color(0xFFFA6E00),
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                          cornerRadius: 5,
                          cornerSmoothing: 1,
                        )),
                      ),
                      child: Center(
                        child: Text(
                          _isFollowing ? 'Unfollow' : 'Follow',
                          style: TextStyle(
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
                if (!widget.isProfilePost &&
                    !(Provider.of<Auth>(context, listen: false).user_id ==
                        widget.data['user_id']))
                IconButton(
                    onPressed: () async {
                      {
                        return MoreSheetInPostItem(context).then((value) {
                          setState(() {});
                        });
                      }
                    },
                    icon: Icon(Icons.more_vert)),
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
                                    ? BoxShadow(
                                        offset: Offset(0, 4),
                                        color:
                                            Color.fromRGBO(124, 193, 191, 0.6),
                                        blurRadius: 20,
                                      )
                                    : BoxShadow(
                                        offset: Offset(3, 4),
                                        color:
                                            Color.fromRGBO(158, 116, 158, 0.5),
                                        blurRadius: 15,
                                      )
                              ],
                              shape: SmoothRectangleBorder(),
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
                        return Container(
                          width: double
                              .infinity, // Take up full width of the screen
                          decoration: ShapeDecoration(
                            shadows: [
                              _isVendor
                                  ? BoxShadow(
                                      offset: Offset(0, 4),
                                      color: Color.fromRGBO(124, 193, 191, 0.6),
                                      blurRadius: 20,
                                    )
                                  : BoxShadow(
                                      offset: Offset(3, 4),
                                      color: Color.fromRGBO(158, 116, 158, 0.5),
                                      blurRadius: 15,
                                    )
                            ],
                            shape: SmoothRectangleBorder(),
                          ),
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 20,
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
                        );
                      }).toList(),
                      options: CarouselOptions(
                        autoPlay: false,
                        controller: buttonCarouselController,
                        enlargeCenterPage: true,

                        viewportFraction: 1.0,
                        aspectRatio:
                            1, // Set overall carousel aspect ratio to 1:1
                        initialPage: 0,
                      ),
                    ),
              if (_showLikeIcon) // Show like icon if _showLikeIcon is true
                Positioned(
                  left: 35.w,
                  top: 15.h,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: _showLikeIcon ? 0.8 : 0.0,
                    child: TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      builder: (_, scale, __) {
                        return Transform.scale(
                          scale: scale,
                          child: RotationTransition(
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
                      return FeedBottomSheet()
                          .ProductsInPostSheet(context, widget.data, _isLiked);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromRGBO(250, 110, 0, 1),
                            Color.fromRGBO(254, 209, 112, 1)
                          ],
                        ),
                        shadows: [
                          BoxShadow(
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
                      child: Icon(Icons.search, size: 29),
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
                    SizedBox(width: 3,),
                    // Text('knknhkink'),
                    // SvgPicture.asset(
                    //   'assets/icons/Favorite.svg',
                    //   color: Colors.red,
                    //   allowDrawingOutsideViewBox: true,
                    //   width: 100,
                    // ),
                    //like button
                    IconButton(
                      visualDensity: VisualDensity(
                          horizontal: VisualDensity.minimumDensity
                      ),
                     // padding: EdgeInsets.only(left: 10),
                      // pa
                      onPressed: () async {
                        // print(widget.data['likes'] ?? []);
                        String code = '';

                        code = widget.isProfilePost
                            ? await Provider.of<Auth>(context, listen: false)
                                .likePost(
                                    widget.data['id'],
                                    Provider.of<Auth>(context, listen: false)
                                        .user_id)
                            : await Provider.of<Auth>(context, listen: false)
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
                                          .user_id,
                                  'profile_photo':
                                      Provider.of<Auth>(context, listen: false)
                                          .logo_url,
                                  'name':
                                      Provider.of<Auth>(context, listen: false)
                                          .store_name,
                                });
                              });
                            } else {
                              setState(() {
                                _likeData.removeWhere(
                                  (element) =>
                                      element['id'] ==
                                      Provider.of<Auth>(context, listen: false)
                                          .user_id,
                                );
                              });
                            }
                            if (_isLiked == true) _showLikeIcon = true;
                          });
                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              _showLikeIcon = false;
                            });
                          });
                        } else {
                          TOastNotification().showErrorToast(context, 'Error!');
                        }
                      },
                      icon: AnimatedContainer(
                        duration: Duration(milliseconds: 3000),
                        curve: Curves.easeInOut,
                        child: _isLiked? Icon(Icons.favorite,color: Colors.red,size: 20,) : SvgPicture.asset(
                          /*_isLiked ?  Assets.favourite_svg :*/ Assets.favourite_svg,
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
                      visualDensity: VisualDensity(
                        horizontal: VisualDensity.minimumDensity
                      ),
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
                                    isProfilePost: widget.isProfilePost,
                                  ),
                                  70.h)
                              .then((value) {
                            setState(() {});
                          });
                        },
                      icon: SvgPicture.asset(Assets.comment_svg,height: 20,width: 20,)),
                        //icon: const Icon(Icons.mode_comment_outlined)),
                    //share button
                    IconButton(
                        visualDensity: VisualDensity(
                            horizontal: VisualDensity.minimumDensity
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final DynamicLinkParameters parameters =
                              DynamicLinkParameters(
                            uriPrefix: 'https://api.cloudbelly.in',
                            link: Uri.parse(
                                'https://api.cloudbelly.in/post/?id=${widget.data['id']}&type=post'),
                            androidParameters: const AndroidParameters(
                              packageName: 'com.app.cloudbelly_app',
                            ),
                          );

                          final Uri shortUrl = parameters.link;
                          // print(shortUrl);
                          Share.share("${shortUrl}");
                        },
                        icon: SvgPicture.asset(Assets.share,height: 20,width: 20,))
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
                                  shape: OvalBorder(
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
                                if (_likeData[i + 1]['profile_photo'] != '' &&
                                    _likeData[i + 1]['profile_photo'] != null)
                                  Container(
                                    width: 17,
                                    height: 17,
                                    decoration: ShapeDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            _likeData[i + 1]['profile_photo']),
                                        fit: BoxFit.fill,
                                      ),
                                      shape: OvalBorder(
                                        side: BorderSide(
                                          width: 2,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Color(0xFFEAF5F7),
                                        ),
                                      ),
                                    ),
                                  ),
                            if (_likeData.length != 0 &&
                                _likeData[0]['profile_photo'] != '')
                              Space(
                                7,
                                isHorizontal: true,
                              ),
                            Text(
                              'Liked by',
                              style: TextStyle(
                                color: _isVendor
                                    ? Color(0xFF519896)
                                    : Color(0xFFB232CB),
                                fontSize: 12,
                                fontFamily: 'Product Sans Medium',
                                fontWeight: FontWeight.w500,
                                height: 0,
                                letterSpacing: 0.12,
                              ),
                            ),
                            Space(isHorizontal: true, 5),
                            Text(
                              '${_likeData.length == 0 ? '0 people' : _likeData.length == 1 ? _likeData[0]['name'] : '${_likeData[0]['name']} and ${_likeData.length - 1} others'}',
                              style: TextStyle(
                                color: _isVendor
                                    ? Color(0xFF0A4C61)
                                    : Color(0xFF2E0536),
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
                                    widget.isProfilePost
                                        ? Provider.of<Auth>(context,
                                                listen: false)
                                            .store_name
                                        : widget.data['store_name'],
                                    style: const TextStyle(
                                      color: Color(0xFFFA6E00),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.36,
                                    ),
                                  ),
                                  Space(isHorizontal: true, 9),
                                  Expanded(
                                    child: SizedBox(
                                      child: Text(
                                        caption1,
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: _isVendor
                                              ? Color(0xFF0A4C61)
                                              : Color(0xFF2E0536),
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
                                          ? Color(0xFF0A4C61)
                                          : Color(0xFF2E0536),
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
                                      isProfilePost: widget.isProfilePost,
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
                                    ? Color(0xFF519796)
                                    : Color(0xFFB232CB),
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
                                ? Color(0xFF519796)
                                : Color(0xFFB232CB),
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
          )
        ],
      ),
    );
  }

  Future<void> MoreSheetInPostItem(BuildContext context) {
    return AppWideBottomSheet().showSheet(
        context,
        widget.isProfilePost
            ? Column(
                children: [
                  Space(4.h),
                  Row(
                    children: [
                      Space(
                        11.w,
                        isHorizontal: true,
                      ),
                      PostMoreButtonRowWidget(
                        icon: Icon(Icons.bookmark),
                        text: 'Save',
                      ),
                      Space(
                        12.w,
                        isHorizontal: true,
                      ),
                      PostMoreButtonRowWidget(
                        icon: Icon(Icons.qr_code),
                        text: 'QR code',
                      ),
                    ],
                  ),
                  Space(4.h),
                  Row(
                    children: [
                      Space(
                        11.w,
                        isHorizontal: true,
                      ),
                      PostMoreButtonRowWidget(
                        icon: Icon(Icons.edit),
                        text: 'Edit',
                      ),
                      Space(
                        13.5.w,
                        isHorizontal: true,
                      ),
                      PostMoreButtonRowWidget(
                        icon: Icon(Icons.qr_code),
                        text: 'View insights',
                      ),
                    ],
                  ),
                  Space(4.h),
                  PostMoreButtonBigContainerWidget(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    icon: Icon(Icons.visibility_off),
                    text: 'Turn off commenting',
                  ),
                  Space(3.h),
                  PostMoreButtonBigContainerWidget(
                    color: Color.fromRGBO(171, 171, 171, 1),
                    icon: Icon(Icons.comments_disabled),
                    text: 'Hide like counts',
                  ),
                  Space(5.h),
                  TouchableOpacity(
                    onTap: () async {
                      AppWideLoadingBanner().loadingBanner(context);
                      final code =
                          await Provider.of<Auth>(context, listen: false)
                              .deletePost(widget.data['id']);

                      if (code == '200') {
                        TOastNotification()
                            .showSuccesToast(context, 'Post deleted');
                        final Data =
                            await Provider.of<Auth>(context, listen: false)
                                .getFeed() as List<dynamic>;
                        Navigator.of(context).pop();

                        Navigator.of(context).pushReplacementNamed(
                            PostsScreen.routeName,
                            arguments: {'data': Data, 'index': 0});
                      } else {
                        Navigator.of(context).pop();
                        TOastNotification().showErrorToast(context, 'Error!');
                      }
                    },
                    child: Container(
                      decoration: GlobalVariables().ContainerDecoration(
                          offset: Offset(0, 8),
                          blurRadius: 20,
                          boxColor: Color.fromRGBO(255, 77, 77, 1),
                          cornerRadius: 10,
                          shadowColor: Color.fromRGBO(152, 202, 201, 0.8)),
                      width: double.infinity,
                      height: 6.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          Space(
                            3.w,
                            isHorizontal: true,
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.16,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            : Column(
                children: [
                  Space(4.h),
                  Row(
                    children: [
                      Space(
                        11.w,
                        isHorizontal: true,
                      ),
                      PostMoreButtonRowWidget(
                        icon: Icon(Icons.error_outline),
                        text: 'Report',
                      ),
                      // PostMoreButtonRowWidget(
                      //   icon: Icon(Icons.bookmark),
                      //   text: 'Save',
                      // ),
                      Space(
                        12.w,
                        isHorizontal: true,
                      ),
                      PostMoreButtonRowWidget(
                        icon: Icon(Icons.qr_code),
                        text: 'QR code',
                      ),
                    ],
                  ),
                  // Space(4.h),
                  // Row(
                  //   children: [
                  //     Space(
                  //       11.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: Icon(Icons.visibility_off),
                  //       text: 'Hide',
                  //     ),
                  //     Space(
                  //       13.5.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: Icon(Icons.error_outline),
                  //       text: 'Report',
                  //     ),
                  //   ],
                  // ),
                  Space(5.h),
                  FollowButtonInSHeet(data: widget.data),
                ],
              ),
        widget.isProfilePost ? 60.h : 30.h);
  }
}

class FollowButtonInSHeet extends StatefulWidget {
  FollowButtonInSHeet({
    super.key,
    required this.data,
  });
  dynamic data;

  @override
  State<FollowButtonInSHeet> createState() => _FollowButtonInSHeetState();
}

class _FollowButtonInSHeetState extends State<FollowButtonInSHeet> {
  @override
  void initState() {
    checkFollow();
    // TODO: implement initState
    super.initState();
  }

  bool _isFollowing = false;
  bool checkFollow() {
    String id = widget.data['user_id'];
    List<dynamic> temp = Provider.of<Auth>(context, listen: false).followings;
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
    return TouchableOpacity(
      onTap: () async {
        if (!_isFollowing) {
          final dynamic response =
              await Provider.of<Auth>(context, listen: false)
                  .follow(widget.data['user_id']);
          if (response['code'] == 200) {
            TOastNotification()
                .showSuccesToast(context, response['body']['message']);
            Provider.of<Auth>(context, listen: false)
                .followings
                .add({'user_id': widget.data['user_id']});
            setState(() {
              _isFollowing = true;
            });
          } else {
            TOastNotification()
                .showErrorToast(context, response['body']['message']);
          }
        } else {
          final dynamic response =
              await Provider.of<Auth>(context, listen: false)
                  .unfollow(widget.data['user_id']);
          if (response['code'] == 200) {
            TOastNotification()
                .showSuccesToast(context, response['body']['message']);
            Provider.of<Auth>(context, listen: false).followings.removeWhere(
                (element) => element['user_id'] == widget.data['user_id']);
            setState(() {
              _isFollowing = false;
            });
          } else {
            TOastNotification()
                .showErrorToast(context, response['body']['message']);
          }
        }
        print(Provider.of<Auth>(context, listen: false).followings);
      },
      child: Container(
          decoration: GlobalVariables().ContainerDecoration(
              offset: Offset(0, 8),
              blurRadius: 20,
              boxColor: Color.fromRGBO(84, 166, 193, 1),
              cornerRadius: 10,
              shadowColor: Color.fromRGBO(152, 202, 201, 0.8)),
          width: double.infinity,
          height: 6.h,
          child: Center(
            child: Text(
              _isFollowing ? 'Unfollow' : 'Follow',
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
    );
  }
}

class PostMoreButtonBigContainerWidget extends StatelessWidget {
  String text;
  Color color;
  Icon icon;
  PostMoreButtonBigContainerWidget(
      {super.key, required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GlobalVariables().ContainerDecoration(
        offset: Offset(0, 4),
        blurRadius: 20,
        boxColor: Colors.white,
        cornerRadius: 10,
        shadowColor: Color.fromRGBO(165, 200, 199, 0.6),
      ),
      width: double.infinity,
      height: 6.h,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        icon,
        Text(
          text,
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 14,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0.08,
            letterSpacing: 0.42,
          ),
        ),
        Container(
          height: 40,
          width: 40,
          decoration: ShapeDecoration(
            color: color,
            // color: const Color.fromRGBO(250, 110, 0, 1),
            shadows: const [
              BoxShadow(
                offset: Offset(0, 4),
                color: Color.fromRGBO(31, 111, 109, 0.3),
                blurRadius: 20,
              )
            ],
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: const Icon(
            Icons.done,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}

class PostMoreButtonRowWidget extends StatelessWidget {
  Icon icon;
  String text;
  PostMoreButtonRowWidget({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            height: 45,
            width: 45,
            decoration: GlobalVariables().ContainerDecoration(
              offset: Offset(0, 4),
              blurRadius: 20,
              boxColor: Color.fromRGBO(200, 233, 233, 1),
              cornerRadius: 10,
              shadowColor: Color.fromRGBO(124, 193, 191, 0.3),
            ),
            child: icon),
        Space(
          5.w,
          isHorizontal: true,
        ),
        Text(
          text,
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 14,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0.08,
            letterSpacing: 0.42,
          ),
        )
      ],
    );
  }
}

class CommentSheetContent extends StatefulWidget {
  const CommentSheetContent(
      {super.key,
      required this.data,
      required this.isProfilePost,
      required this.userData});

  final data;
  final isProfilePost;
  final userData;

  @override
  State<CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<CommentSheetContent> {
  TextEditingController _controller = TextEditingController();
  String _comment = '';

  List<bool> _isDeleting = List<bool>.filled(5000, false);

  @override
  Widget build(BuildContext context) {
    // List<dynamic> userData = widget.userData;
    dynamic newData = widget.data;
    // print('${widget.userData.length}');
    // print('${newData.length}');

    // print(widget.data);
    return Container(
      child: SingleChildScrollView(
        child: Column(children: [
          const Center(
            child: Text(
              'Comments',
              style: TextStyle(
                color: Color(0xFF0A4C61),
                fontSize: 18,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w800,
                letterSpacing: 0.18,
              ),
            ),
          ),
          Space(1.h),
          Container(
            height: 53.h,
            child: (newData['comments'] ?? []).length == 0
                ? const Center(
                    child: Text('No Comments Yet'),
                  )
                : ListView.builder(
                    itemCount: (newData['comments'] ?? []).length,
                    itemBuilder: (context, index) {
                      // bool isDeleting = false;
                      // print(newData);
                      return GestureDetector(
                        onLongPress: () {
                          // print('longpress');

                          if (newData['comments'][index]['user_id'] ==
                              Provider.of<Auth>(context, listen: false)
                                  .user_id) {
                            setState(() {
                              _isDeleting[index] =
                                  true; // Assuming isDeleting is a boolean variable to handle whether the delete button should be displayed
                            });
                          }
                          // print(_isDeleting);
                        },
                        child: Stack(
                          children: [
                            CommentItemWidget(
                              dateString: newData['comments'][index]
                                  ['created_at'],
                              url: newData['comments'][index]
                                      ['profile_photo'] ??
                                  "",
                              name: newData['comments'][index]['store_name'],
                              text: newData['comments'][index]['text'],
                            ),
                            if (_isDeleting[
                                index]) // Only display delete button if isDeleting is true
                              Positioned(
                                top: 0,
                                right: 10,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    // Handle delete action here
                                    setState(() {
                                      _isDeleting[index] =
                                          false; // Hide delete button
                                    });
                                    final code = await Provider.of<Auth>(
                                            context,
                                            listen: false)
                                        .deleteComment(newData['id'],
                                            newData['comments'][index]['text']);

                                    if (code == '200') {
                                      TOastNotification().showSuccesToast(
                                          context, 'Comment deleted');

                                      List<dynamic> _list =
                                          newData['comments'] ?? [];
                                      int indexToRemove = _list.indexWhere(
                                          (element) =>
                                              element['text'] ==
                                              newData['comments'][index]
                                                  ['text']);

                                      setState(() {
                                        if (indexToRemove != -1) {
                                          _list.removeAt(indexToRemove);
                                        }
                                        newData['comments'] = _list;
                                      });
                                    } else {
                                      TOastNotification().showErrorToast(
                                          context, 'Error!1111');
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Space(.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
            // width: 80.w,
            // rgba(165, 200, 199, 1),
            decoration: const ShapeDecoration(
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
            child: Row(
              children: [
                const Space(isHorizontal: true, 10),
                Provider.of<Auth>(context, listen: false).logo_url == ''
                    ? Container(
                        height: 30,
                        width: 30,
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
                            cornerRadius: 5,
                            cornerSmoothing: 1,
                          )),
                        ),
                        child: Center(
                          child: Text(
                            Provider.of<Auth>(context, listen: true)
                                .store_name[0]
                                .toUpperCase(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ))
                    : Container(
                        height: 30,
                        width: 30,
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
                            cornerRadius: 10,
                            cornerSmoothing: 1,
                          ),
                          child: Image.network(
                            Provider.of<Auth>(context, listen: false).logo_url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                SizedBox(
                  width: 55.w,
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(left: 14),
                        hintText:
                            ' Type your comment here for ${widget.isProfilePost ? Provider.of<Auth>(context, listen: false).store_name : widget.data['store_name']}...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF519796),
                          fontSize: 12,
                          fontFamily: 'Product Sans Medium',
                          fontWeight: FontWeight.w500,
                          height: 0,
                          letterSpacing: 0.12,
                        ),
                      ),
                      onChanged: (p0) {
                        _comment = p0.toString();
                      },
                    ),
                  ),
                ),
                const Spacer(),
                TouchableOpacity(
                  onTap: () async {
                    AppWideLoadingBanner().loadingBanner(context);

                    final code = await Provider.of<Auth>(context, listen: false)
                        .commentPost(newData['id'], _comment);
                    Navigator.of(context).pop();

                    if (code == '200') {
                      List<dynamic> _list = newData['comments'] ?? [];
                      DateFormat format =
                          DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'");
                      String formattedDate =
                          format.format(DateTime.now().toUtc());
                      _list.add({
                        'text': _comment,
                        'user_id':
                            Provider.of<Auth>(context, listen: false).user_id,
                        'created_at': formattedDate,
                        'store_name': Provider.of<Auth>(context, listen: false)
                            .store_name,
                        'profile_photo':
                            Provider.of<Auth>(context, listen: false).logo_url,
                      });
                      setState(() {
                        newData['comments'] = _list;
                      });
                      TOastNotification()
                          .showSuccesToast(context, 'Comment sent');
                    } else {
                      TOastNotification().showErrorToast(context, 'Error!');
                    }
                    _controller.clear();
                    // _controller.
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: ShapeDecoration(
                      color: const Color.fromRGBO(250, 110, 0, 1),
                      shadows: const [
                        BoxShadow(
                          offset: Offset(0, 4),
                          color: Color.fromRGBO(31, 111, 109, 0.6),
                          blurRadius: 20,
                        )
                      ],
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Space(isHorizontal: true, 10)
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class CommentItemWidget extends StatelessWidget {
  CommentItemWidget(
      {super.key,
      required this.name,
      required this.text,
      required this.url,
      required this.dateString});
  String name;
  String text;
  String url;
  String dateString;

  String formatTimeDifference(String timestampString) {
    // print(timestampString);
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
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return DateFormat('dd MMMM, yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Space(isHorizontal: true, 2.w),
          url == ''
              ? Container(
                  height: 35,
                  width: 35,
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        color: Color.fromRGBO(31, 111, 109, 0.6),
                        blurRadius: 20,
                      )
                    ],
                    color: Color.fromRGBO(31, 111, 109, 0.6),
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    )),
                  ),
                  child: Center(
                    child: Text(
                      name[0],
                      style: TextStyle(fontSize: 20),
                    ),
                  ))
              : Container(
                  height: 40,
                  width: 40,
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
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                    child: Image.network(
                      url,
                      loadingBuilder: GlobalVariables().loadingBuilderForImage,
                      errorBuilder: GlobalVariables().ErrorBuilderForImage,
                      fit: BoxFit.cover,
                    ),
                  )),
          Space(isHorizontal: true, 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF0A4C61),
                      fontSize: 10,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.10,
                    ),
                  ),
                  Space(isHorizontal: true, 6),
                  Text(
                    formatTimeDifference(dateString),
                    style: TextStyle(
                      color: Color(0xFFFA6E00),
                      fontSize: 10,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w400,
                      // height: 0.16,
                    ),
                  )
                ],
              ),
              SizedBox(
                width: 58.w,
                child: Text(
                  text,
                  maxLines: null,
                  style: const TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 12,
                    fontFamily: 'Product Sans Medium',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.12,
                  ),
                ),
              )
            ],
          ),
          const Spacer(),
          //like button for comments
          // IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border))
          // if(Provider.of<Auth>(context).user_id==)
          // IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border))
        ],
      ),
    );
  }
}
