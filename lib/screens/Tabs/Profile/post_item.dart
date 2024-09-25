// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cloudbelly_app/widgets/modal_list_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Feed/feed_bottom_sheet.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_view.dart';
import 'package:cloudbelly_app/screens/Tabs/supplier/components/constants.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SampleItem { itemOne }

class PostItem extends StatefulWidget {
  PostItem({
    super.key,
    required bool isMultiple,
    required this.data,
    required this.isSharePost,
    this.userId,
    this.userModel,
    this.isProfilePost = true,
  }) : _isMultiple = isMultiple;

  final bool _isMultiple;
  bool isProfilePost;
  final String isSharePost;
  final data;
  final String? userId;
  UserModel? userModel;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isFollowing = false;
  bool _didUpdate = true;

  String discription = '';

  String caption1 = '';
  String caption2 = '';
  bool darkMode = true;
  List<ProductDetails> productDetails = [];
  @override
  void initState() {
    super.initState();
    _isFollowing = checkFollow();
    getDarkModeStatus();
    _getLikeData();
    _loadAspectRatio();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //  getDarkModeStatus();
    // _getLikeData();
  }

  @override
  void didUpdateWidget(PostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    getDarkModeStatus();
    // if (widget.data != oldWidget.data) {
    //   _getLikeData();
    //   // setState(() {}); // Force rebuild when data changes
    // }
  }

  Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });
    return prefs.getString('dark_mode');
  }

  List<String> getFittedText(String text) {
    if (text.length <= 50) {
      return [text, ''];
    } else {
      String text1 = text.substring(0, 50) + ' - ';
      String text2 = text.substring(50);
      return [text1, text2];
    }
  }

  void getProductDetails() async {
    AppWideLoadingBanner().loadingBanner(context);
    // print("Full data");

    List<dynamic> productIds = widget.data['menu_items'];
    productDetails = await Provider.of<Auth>(context, listen: false)
        .getProductDetails(productIds)
        .then((value) {
      print("details:: $value");
      Navigator.of(context).pop();
      Provider.of<ViewCartProvider>(context, listen: false)
          .setSellterId(widget.data["user_id"]);
      context.read<TransitionEffect>().setBlurSigma(5.0);
      FeedBottomSheet().ProductsInPostSheet(
          context, widget.data, _isLiked, value, widget.data['user_id']);
      return [];
    });

    setState(() {});
  }

  bool _isLiked = false;

  // List<dynamic> likePorfileUrlList = [];
  void _getLikeData() async {
    setState(() {
      _likeData.clear();
    });

    List<dynamic> likeIds = widget.data['likes'] ?? [];
    if (likeIds.isEmpty) {
      print('No likes found for this post');
      return;
    }

    List<dynamic> temp =
        await Provider.of<Auth>(context, listen: false).getUserInfo(likeIds);

    temp.forEach((element) {
      if (element is Map) {
        _likeData.add({
          'id': element['_id'] ?? 'default_id',
          'name': element['store_name'] ?? 'default_name',
          'profile_photo': element['profile_photo'] ??
              'https://static.vecteezy.com/system/resources/previews/005/337/799/original/icon-image-not-found-free-vector.jpg'
        });
      } else {
        print('Unexpected data type: $element');
      }
    });

    setState(() {
      itemsToShow = min(_likeData.length, 2);
      _isLiked = (widget.data['likes'] ?? []).contains(
          Provider.of<Auth>(context, listen: false).userData?['user_id']);
    });

    // print("$_isLiked likedbyh");
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
  List<String> userId = [];
  int itemsToShow = 0;
  double _aspectRatio = 1;

  bool checkFollow() {
    String id = widget.isProfilePost ? "" : widget.data['user_id'];
    List<dynamic> temp =
        Provider.of<Auth>(context, listen: false).userData?['followings'] ?? [];
    for (var user in temp) {
      if (user['user_id'] == id) {
        return true;
      }
    }
    return false;
  }

  Future<double?> getImageAspectRatio(String imageUrl) async {
    final Completer<double?> completer = Completer<double?>();
    final Image image = Image.network(imageUrl);

    image.image.resolve(ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo info, bool syncCall) {
            final width = info.image.width.toDouble();
            final height = info.image.height.toDouble();
            completer.complete(width / height);
          }, onError: (exception, stackTrace) {
            completer.complete(null); // Handle error case
          }),
        );

    return completer.future;
  }

  Future<void> _loadAspectRatio() async {
    var filePath = '';
    if (!widget._isMultiple) filePath = widget.data['file_path'];

    final aspectRatio = await getImageAspectRatio(filePath);
    print("$_aspectRatio  _aspectRatio  $filePath");
    setState(() {
      _aspectRatio = aspectRatio ?? 1; // Default to 1.0 if null
    });
  }

  double getClosestAspectRatio(double aspectRatio) {
    print("closest $aspectRatio");

    // Define the aspect ratios for comparison
    const double aspect16_9 = 16 / 9; // 1.777... (approximately 1.78)
    const double aspect4_3 = 4 / 3; // 1.333... (approximately 1.33)
    const double aspect3_4 = 3 / 4; // 0.75

    // Determine which aspect ratio to use
    if (aspectRatio == 1.0) {
      return 1.0; // Use 16:9 for aspect ratios 1.78 or greater
    } else if (aspectRatio > 0.4 && aspectRatio < aspect3_4) {
      return aspect3_4; // Use 4:3 for aspect ratios between 1.33 and 1.78
    } else if (aspectRatio >= aspect3_4 && aspectRatio < 1.1) {
      return 1.0; // Use 4:3 for aspect ratios between 1.33 and 1.78
    } else if (aspectRatio >= aspect3_4 && aspectRatio < aspect4_3) {
      return 1.0; // Use 4:3 for aspect ratios between 1.33 and 1.78
    } else {
      return aspectRatio; // Use 1:1 for aspect ratios less than 0.75
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "who is user:: $darkMode ${widget.isProfilePost}  ${widget.data['user_id']}  ${Provider.of<Auth>(context, listen: false).userData?['user_id'] != widget.data['user_id']}");

    bool shouldShowIcon = widget.isProfilePost ||
        (!widget.isProfilePost &&
            Provider.of<Auth>(context, listen: false).userData?['user_id'] !=
                widget.data['user_id']);
    // bool shouldShowIcon = (widget.isProfilePost);
    // bool shouldShowIcon = false;
    // bool _isFollowing = checkFollow();
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';
    // print("isSharePost ${widget.isSharePost}" );
    // final date_time = formatTimeDifference('created_at');
    CarouselController buttonCarouselController = CarouselController();
    return Container(
      decoration: ShapeDecoration(
        shadows: [
          BoxShadow(
            offset: const Offset(0, 10), // Position the shadow down
            color: darkMode
                ? Color(0xff000000).withOpacity(0.35)
                : _isVendor
                    ? Color(0xffB1D9D8).withOpacity(0.35)
                    : Provider.of<Auth>(context, listen: false)
                                .userData?['user_type'] ==
                            UserType.Supplier.name
                        ? const Color.fromRGBO(198, 239, 161, 0.6)
                            .withOpacity(0.3)
                        : const Color.fromRGBO(130, 47, 130, 0.6)
                            .withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0, // Optional: Adjusts the size of the shadow
          ),
        ],
        color: darkMode
            ? Color(0xff313030)
            : _isVendor
                ? Color.fromARGB(102, 243, 255, 255).withOpacity(1)
                : Provider.of<Auth>(context, listen: false)
                            .userData?['user_type'] ==
                        UserType.Supplier.name
                    ? Color.fromARGB(153, 218, 243, 197).withOpacity(0.1)
                    : Color.fromARGB(255, 255, 246, 255).withOpacity(1),
        shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
          cornerRadius: 40,
          cornerSmoothing: 1,
        )),
      ),

      margin: EdgeInsets.only(bottom: 2.7.h),
      // padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space(1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
            child: Row(
              children: [
                const Space(
                  10,
                  isHorizontal: true,
                ),
                // (Provider.of<Auth>(context, listen: false).logo_url == '' &&
                //             widget.isProfilePost) ||
                //         ((widget.data['profile_photo'] == '' ||
                //                 widget.data['profile_photo'] == null) &&
                //             !widget.isProfilePost)
                (widget.isSharePost == 'Yes' &&
                        widget.data['profile_photo'] == '')
                    ? InkWell(
                        onTap: () {
                          if (!widget.isProfilePost) {
                            // print("data:: ${widget.data}");
                            if (widget.data['profile_photo'] != '' &&
                                widget.data['profile_photo'] != null)
                              openFullScreen(
                                  context,
                                  widget.isSharePost == "No"
                                      ? widget.userModel?.profilePhoto ?? ''
                                      : widget.isProfilePost
                                          ? (Provider.of<Auth>(context,
                                                  listen: false)
                                              .userData?['profile_photo'])
                                          : widget.data['profile_photo']);
                          }
                        },
                        //for shared post logo
                        child: Container(
                            height: 35,
                            width: 35,
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: darkMode
                                      ? Colors.black.withOpacity(0.61)
                                      : _isVendor
                                          ? const Color.fromRGBO(
                                                  31, 111, 109, 1)
                                              .withOpacity(0.01)
                                          : Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?['user_type'] ==
                                                  UserType.Supplier.name
                                              ? const Color.fromRGBO(
                                                      198, 239, 161, 0.6)
                                                  .withOpacity(0.3)
                                              : const Color.fromRGBO(
                                                      130, 47, 130, 0.6)
                                                  .withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                              color: _isVendor
                                  ? const Color.fromRGBO(31, 111, 109, 0.4)
                                  : Provider.of<Auth>(context, listen: false)
                                              .userData?['user_type'] ==
                                          UserType.Supplier.name
                                      ? const Color.fromRGBO(198, 239, 161, 0.6)
                                          .withOpacity(0.3)
                                      : const Color.fromRGBO(130, 47, 130, 0.6)
                                          .withOpacity(0.3),
                              shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                cornerRadius: 10,
                                cornerSmoothing: 1,
                              )),
                            ),
                            child: Center(
                              child: Text(
                                widget.isSharePost == "No"
                                    ? widget.userModel?.storeName![0]
                                    : widget.isProfilePost
                                        ? Provider.of<Auth>(context,
                                                        listen: true)
                                                    .userData !=
                                                null
                                            ? Provider.of<Auth>(context,
                                                        listen: true)
                                                    .userData!['store_name']
                                                    .isNotEmpty
                                                ? Provider.of<Auth>(context,
                                                        listen: true)
                                                    .userData!['store_name'][0]
                                                    .toUpperCase()
                                                : Provider.of<Auth>(context,
                                                        listen: true)
                                                    .userData!['store_name'][0]
                                                    .toUpperCase()
                                            : widget.data['store_name'] !=
                                                        null &&
                                                    widget.data['store_name']
                                                        .isNotEmpty
                                                ? widget.data['store_name'][0]
                                                    .toUpperCase()
                                                : widget.data['store_name'][0]
                                                    .toUpperCase()
                                        : widget.data['store_name'][0]
                                            .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )),
                      )
                    : InkWell(
                        onTap: () {
                          openFullScreen(
                            context,
                            widget.isSharePost == "No"
                                ? widget.userModel?.profilePhoto ?? ''
                                : widget.isProfilePost
                                    ? (Provider.of<Auth>(context, listen: false)
                                        .userData?['profile_photo'])
                                    : widget.data['profile_photo'],
                          );
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: darkMode
                                      ? Colors.black.withOpacity(0.61)
                                      : _isVendor
                                          ? const Color.fromRGBO(
                                              31, 111, 109, 0.4)
                                          : Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?['user_type'] ==
                                                  UserType.Supplier.name
                                              ? const Color.fromRGBO(
                                                  77, 191, 74, 0.5)
                                              : const Color.fromRGBO(
                                                      130, 47, 130, 0.7)
                                                  .withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 0)
                            ],
                            shape: const SmoothRectangleBorder(),
                          ),
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 10,
                              cornerSmoothing: 1,
                            ),
                            child: Image.network(
                              widget.isSharePost == "No"
                                  ? widget.userModel?.profilePhoto ?? ''
                                  : widget.isProfilePost
                                      ? (Provider.of<Auth>(context,
                                              listen: false)
                                          .userData?['profile_photo'])
                                      : widget.data['profile_photo'],
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

                InkWell(
                  onTap: () {
                    setState(() {
                      userId.add(widget.data['user_id']);
                    });
                    // print("userIdfrom post:: $userId");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileView(
                                  userIdList: userId,
                                )));
                  },
                  child: SizedBox(
                    width: 37.w,
                    child: Text(
                      widget.isSharePost == "No"
                          ? widget.userModel?.storeName
                          : widget.isProfilePost
                              ? Provider.of<Auth>(context, listen: false)
                                  .userData!['store_name']
                              : widget.data['store_name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: darkMode
                            ? Colors.white
                            : _isVendor
                                ? const Color(0xFF094B60)
                                : const Color(0xFF2E0536),
                        fontSize: 16,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                const Spacer(),
                if (!widget.isProfilePost &&
                    !(Provider.of<Auth>(context, listen: false)
                            .userData?['user_id'] ==
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
                      // print(Provider.of<Auth>(context, listen: false)
                      //     .userData?['followings']);
                    },
                    child: Container(
                      width: 70,
                      height: 25,
                      decoration: ShapeDecoration(
                        shadows: [
                          BoxShadow(
                            offset: const Offset(3, 6),
                            color: darkMode
                                ? Color(0xff282C2B).withOpacity(0.79)
                                : _isVendor
                                    ? const Color.fromRGBO(116, 202, 199, 0.5)
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Supplier.name
                                        ? const Color.fromRGBO(77, 191, 74, 0.3)
                                        : const Color.fromRGBO(
                                            158, 116, 158, 0.6),
                            blurRadius: 20,
                          ),
                        ],
                        color: darkMode
                            ? Color(0xffFA6E00)
                            : _isVendor
                                ? const Color(0xff54A6C1)
                                : Provider.of<Auth>(context, listen: false)
                                            .userData?['user_type'] ==
                                        UserType.Supplier.name
                                    ? const Color(0xFFA3DC76)
                                    : const Color(0xFFFA6E00),
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                          cornerRadius: 8,
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
                if (shouldShowIcon ||
                    Provider.of<Auth>(context, listen: false)
                            .userData?['user_id'] ==
                        widget.userId) ...{
                  IconButton(
                      onPressed: () async {
                        {
                          return MoreSheetInPostItem(context).then((value) {
                            setState(() {});
                          });
                        }
                      },
                      icon: Icon(Icons.more_vert,
                          color: darkMode
                              ? Colors.white
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      'Vendor'
                                  ? const Color(0xFF094B60)
                                  : Provider.of<Auth>(context, listen: false)
                                              .userData?['user_type'] ==
                                          UserType.Supplier.name
                                      ? const Color.fromARGB(255, 26, 48, 10)
                                      : const Color(0xFF2E0536))),
                }
                //  for mantaining icon space
                else ...{
                  // const SizedBox(height: 50),
                  SizedBox(
                    height: 50,
                    width: 30,
                  ),
                }
              ],
            ),
          ),
          Space(0.5.h),
          // posts multiple
          Stack(
            children: [
              !widget._isMultiple
                  ? Hero(
                      tag: widget.data['id'],
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: getClosestAspectRatio(_aspectRatio),
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 3.w, bottom: 2.h, right: 3.w),
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              shadows: [
                                if (darkMode) // Check for dark mode first
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color(0xff030303).withOpacity(0.77),
                                    blurRadius: 25,
                                  )
                                else if (_isVendor) // Check if it's a vendor
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color.fromRGBO(124, 193, 191, 1)
                                        .withOpacity(0.3),
                                    blurRadius: 25,
                                  )
                                else if (Provider.of<Auth>(context,
                                            listen: false)
                                        .userData?['user_type'] ==
                                    UserType
                                        .Supplier.name) // Check for supplier
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color.fromRGBO(77, 191, 74, 1)
                                        .withOpacity(0.3),
                                    blurRadius: 25,
                                  )
                                else // Default case for other user types
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color.fromRGBO(158, 116, 158, 1)
                                        .withOpacity(0.3),
                                    blurRadius: 25,
                                  )
                              ],
                              shape: const SmoothRectangleBorder(),
                            ),
                           
                            child: GestureDetector(
                              onDoubleTap: () async {
                                print("_aspectRatio_aspectRatio $_aspectRatio");
                                var code = widget.isProfilePost
                                    ? await Provider.of<Auth>(context,
                                            listen: false)
                                        .likePost(widget.data['id'],
                                            widget.userId ?? "")
                                    : await Provider.of<Auth>(context,
                                            listen: false)
                                        .likePost(widget.data['id'],
                                            widget.data['user_id']);

                                if (code == '200') {
                                  setState(() {
                                    _isLiked = !_isLiked;
                                    if (_isLiked) {
                                      setState(() {
                                        // Get the current user ID
                                        final userId = Provider.of<Auth>(
                                                context,
                                                listen: false)
                                            .userData?['user_id'];

                                        // Check if the user is already in the list
                                        final isAlreadyLiked = _likeData.any(
                                            (like) => like['id'] == userId);

                                        // If not present, add the user to the list
                                        if (!isAlreadyLiked) {
                                          _likeData.add({
                                            'id': userId,
                                            'profile_photo': Provider.of<Auth>(
                                                    context,
                                                    listen: false)
                                                .logo_url,
                                            'name': Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['store_name'],
                                          });
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        _likeData.removeWhere(
                                          (element) =>
                                              element['id'] ==
                                              Provider.of<Auth>(context,
                                                      listen: false)
                                                  .userData?['user_id'],
                                        );
                                      });
                                    }
                                    if (_isLiked == true) _showLikeIcon = true;
                                  });

                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    setState(() {
                                      _showLikeIcon = false;
                                    });
                                  });
                                }
                              },
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
                      ),
                    )
                  : FlutterCarousel(
                      items: (widget.data['multiple_files'] as List<dynamic>)
                          .map<Widget>((url) {
                        return Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              margin: EdgeInsets.only(left: 3.w, right: 3.w),
                              width: double.infinity,

                              // Take up full width of the screen
                             decoration: ShapeDecoration(
                              shadows: [
                                if (darkMode) // Check for dark mode first
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color(0xff030303).withOpacity(0.77),
                                    blurRadius: 25,
                                  )
                                else if (_isVendor) // Check if it's a vendor
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color.fromRGBO(124, 193, 191, 1)
                                        .withOpacity(0.3),
                                    blurRadius: 25,
                                  )
                                else if (Provider.of<Auth>(context,
                                            listen: false)
                                        .userData?['user_type'] ==
                                    UserType
                                        .Supplier.name) // Check for supplier
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color.fromRGBO(77, 191, 74, 1)
                                        .withOpacity(0.3),
                                    blurRadius: 25,
                                  )
                                else // Default case for other user types
                                  BoxShadow(
                                    offset: Offset(3, 4),
                                    color: Color.fromRGBO(158, 116, 158, 1)
                                        .withOpacity(0.3),
                                    blurRadius: 25,
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
                  left: 30.w,
                  top: 15.h,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showLikeIcon ? 0.8 : 0.0,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(begin: 0.2, end: 1.0),
                      builder: (_, scale, __) {
                        return Transform.scale(
                          scale: scale,
                          child: const RotationTransition(
                            turns: AlwaysStoppedAnimation(
                                -0), // Rotate by 30 degrees
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 150, // Adjust size as needed
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              //search icon menu items sheet icon
              if (!_isVendor &&
                  widget.data['menu_items'] != null &&
                  (widget.data['menu_items'] as List<dynamic>).length != 0)
                Positioned(
                  right: 35,
                  bottom: 0,
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
                          begin: Alignment(-1.0, 1),
                          end: Alignment(1, -1.0),
                          colors: [
                            Color.fromRGBO(250, 110, 0, 1),
                            Color.fromRGBO(254, 209, 112, 1)
                          ],
                        ),
                        shadows: [
                          _isVendor
                              ? BoxShadow(
                                  offset: Offset(3, 6),
                                  color: Color.fromRGBO(124, 193, 191, 1)
                                      .withOpacity(0.3),
                                  blurRadius: 35,
                                )
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      UserType.Supplier.name
                                  ? BoxShadow(
                                      offset: Offset(1, 4),
                                      color: Color.fromRGBO(77, 191, 74, 1)
                                          .withOpacity(0.3),
                                      blurRadius: 35,
                                    )
                                  : BoxShadow(
                                      offset: Offset(3, 4),
                                      color: Color.fromRGBO(158, 116, 158, 1)
                                          .withOpacity(0.3),
                                      blurRadius: 35,
                                    )
                        ],
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                          cornerRadius: 15,
                          cornerSmoothing: 1,
                        )),
                      ),
                      child: const Icon(Icons.search, size: 25),
                    ),
                  ),
                ),
            ],
          ),
          Space(0.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 3,
                    ),

                    //like button
                    IconButton(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity),
                      onPressed: () async {
                        // print("abcds:: ${widget.userId}");
                        String code = '';

                        code = widget.isProfilePost
                            ? await Provider.of<Auth>(context, listen: false)
                                .likePost(
                                    widget.data['id'], widget.userId ?? "")
                            : await Provider.of<Auth>(context, listen: false)
                                .likePost(
                                    widget.data['id'], widget.data['user_id']);

                        if (code == '200') {
                          setState(() {
                            _isLiked = !_isLiked;
                            if (_isLiked) {
                              setState(() {
                                // Get the current user ID
                                final userId =
                                    Provider.of<Auth>(context, listen: false)
                                        .userData?['user_id'];

                                // Check if the user is already in the list
                                final isAlreadyLiked = _likeData
                                    .any((like) => like['id'] == userId);

                                // If not present, add the user to the list
                                if (!isAlreadyLiked) {
                                  _likeData.add({
                                    'id': userId,
                                    'profile_photo': Provider.of<Auth>(context,
                                            listen: false)
                                        .logo_url,
                                    'name': Provider.of<Auth>(context,
                                            listen: false)
                                        .userData?['store_name'],
                                  });
                                }
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
                        /* color: _isLiked
                              ? Colors.red
                              : null,*/
                        height: 25,
                        width: 25,
                        child: _isLiked
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 25,
                              )
                            : SvgPicture.asset(
                                /*_isLiked ?  Assets.favourite_svg :*/
                                Assets.favourite_svg,
                                // ignore: deprecated_member_use
                                color: _isVendor
                                    ? const Color(0xFF094B60)
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Supplier.name
                                        ? Color.fromARGB(255, 26, 48, 10)
                                        : const Color(0xFF2E0536),
                                // colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.xor)
                              ),
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
                                    isProfilePost: widget.isProfilePost,
                                  ),
                                  70.h)
                              .then((value) {
                            setState(() {});
                          });
                        },
                        icon: SvgPicture.asset(
                          Assets.comment_svg,
                          // ignore: deprecated_member_use
                          color: _isVendor
                              ? const Color(0xFF094B60)
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      UserType.Supplier.name
                                  ? Color.fromARGB(255, 26, 48, 10)
                                  : const Color(0xFF2E0536),
                          height: 25,
                          width: 25,
                        )),
                    //icon: const Icon(Icons.mode_comment_outlined)),
                    //share button
                    IconButton(
                        visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          try {
                            // 1. Generate the Dynamic Link
                            final DynamicLinkParameters parameters =
                                DynamicLinkParameters(
                              uriPrefix: 'https://app.cloudbelly.in',
                              link: Uri.parse(
                                  'https://app.cloudbelly.in/profile?profileId=${widget.data['user_id'] ?? widget.userId}'),
                              androidParameters: const AndroidParameters(
                                packageName: 'com.app.cloudbelly_app',
                              ),
                            );

                            final Uri shortUrl = parameters.link;

                            // 2. Download the image
                            final imageUrl = widget.data['file_path'];
                            final response =
                                await http.get(Uri.parse(imageUrl));

                            if (response.statusCode == 200) {
                              // 3. Save the image to the device's storage
                              final tempDir = await getTemporaryDirectory();
                              final filePath =
                                  '${tempDir.path}/shared_image.png';
                              final file = File(filePath);
                              await file.writeAsBytes(response.bodyBytes);

                              // 4. Share the image and dynamic link
                              Share.shareFiles([filePath], text: "$shortUrl");
                            } else {
                              print('Failed to download image.');
                            }
                          } catch (e) {
                            print('Error: $e');
                          }
                        },
                        icon: SvgPicture.asset(
                          Assets.share,
                          // ignore: deprecated_member_use
                          color: _isVendor
                              ? const Color(0xFF094B60)
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      UserType.Supplier.name
                                  ? Color.fromARGB(255, 26, 48, 10)
                                  : const Color(0xFF2E0536),
                          height: 25,
                          width: 25,
                        ))
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 3.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Space(14),
                        GestureDetector(
                          onTap: () {
                            if (_likeData.length != 0)
                              openLikedBy(context, _likeData);
                          },
                          child: Row(
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
                                  if (_likeData[i + 1]['profile_photo'] != '' &&
                                      _likeData[i + 1]['profile_photo'] != null)
                                    Container(
                                      width: 17,
                                      height: 17,
                                      decoration: ShapeDecoration(
                                        color: const Color.fromRGBO(
                                            31, 111, 109, 0.6),
                                        image: DecorationImage(
                                          image: NetworkImage(_likeData[i + 1]
                                              ['profile_photo']),
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
                                      : Provider.of<Auth>(context,
                                                      listen: false)
                                                  .userData?['user_type'] ==
                                              UserType.Supplier.name
                                          ? Color.fromARGB(255, 26, 48, 10)
                                          : const Color(0xFFB232CB),
                                  fontSize: 13,
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
                                      ? const Color(0xFF094B60)
                                      : Provider.of<Auth>(context,
                                                      listen: false)
                                                  .userData?['user_type'] ==
                                              UserType.Supplier.name
                                          ? Color.fromARGB(255, 26, 48, 10)
                                          : const Color(0xFF2E0536),
                                  fontSize: 13,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                  letterSpacing: 0.12,
                                ),
                              )
                            ],
                          ),
                        ),
                        if (widget.data['caption'] != null &&
                            widget.data['caption'].isNotEmpty)
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
                                            .userData!['store_name']
                                        : widget.data['store_name'],
                                    style: const TextStyle(
                                      color: Color(0xFFFA6E00),
                                      fontSize: 13,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.36,
                                    ),
                                  ),
                                  const Space(isHorizontal: true, 9),
                                  Expanded(
                                    child: SizedBox(
                                      child: Text(
                                        widget.data['caption'],
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: _isVendor
                                              ? const Color(0xFF0A4C61)
                                              : const Color(0xFF2E0536),
                                          fontSize: 13,
                                          fontFamily: 'Product Sans Medium',
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.12,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              if (widget.data['caption'].length > 50)
                                SizedBox(
                                  child: Text(
                                    widget.data['caption'].substring(50),
                                    maxLines: null,
                                    style: TextStyle(
                                      color: _isVendor
                                          ? const Color(0xFF0A4C61)
                                          : const Color(0xFF2E0536),
                                      fontSize: 13,
                                      fontFamily: 'Product Sans Medium',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        Space(0.2.h),
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
                        // Space(0.2.h),
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
                        ),
                        Space(1.h),
                      ]),
                )
              ],
            ),
          ),
          Space(0.5.h),
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
                  // Space(4.h),
                  // Row(
                  //   children: [
                  //     Space(
                  //       11.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: const Icon(Icons.bookmark),
                  //       text: 'Save',
                  //     ),
                  //     Space(
                  //       12.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: const Icon(Icons.qr_code),
                  //       text: 'QR code',
                  //     ),
                  //   ],
                  // ),
                  // Space(4.h),
                  // Row(
                  //   children: [
                  //     Space(
                  //       11.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: const Icon(Icons.edit),
                  //       text: 'Edit',
                  //     ),
                  //     Space(
                  //       13.5.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: const Icon(Icons.qr_code),
                  //       text: 'View insights',
                  //     ),
                  //   ],
                  // ),
                  // Space(4.h),
                  // PostMoreButtonBigContainerWidget(
                  //   color: const Color.fromRGBO(250, 110, 0, 1),
                  //   icon: const Icon(Icons.visibility_off),
                  //   text: 'Turn off commenting',
                  // ),
                  // Space(3.h),
                  // PostMoreButtonBigContainerWidget(
                  //   color: const Color.fromRGBO(171, 171, 171, 1),
                  //   icon: const Icon(Icons.comments_disabled),
                  //   text: 'Hide like counts',
                  // ),
                  // Space(5.h),
                  TouchableOpacity(
                    onTap: () async {
                      AppWideLoadingBanner().loadingBanner(context);
                      final code =
                          await Provider.of<Auth>(context, listen: false)
                              .deletePost(widget.data['id']);

                      if (code == '200') {
                        Navigator.of(context).pop();
                        TOastNotification()
                            .showSuccesToast(context, 'Post deleted');
                        final Data =
                            await Provider.of<Auth>(context, listen: false)
                                .getFeed(widget.data['id']) as List<dynamic>;

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
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                          boxColor: Color.fromARGB(255, 227, 123, 123),
                          cornerRadius: 10,
                          shadowColor:
                              const Color.fromRGBO(152, 202, 201, 0.8)),
                      width: double.infinity,
                      height: 6.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          Space(
                            3.w,
                            isHorizontal: true,
                          ),
                          const Text(
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
                  // Space(4.h),
                  // Row(
                  //   children: [
                  //     Space(
                  //       11.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: const Icon(Icons.error_outline),
                  //       text: 'Report',
                  //     ),
                  //     // PostMoreButtonRowWidget(
                  //     //   icon: Icon(Icons.bookmark),
                  //     //   text: 'Save',
                  //     // ),
                  //     Space(
                  //       12.w,
                  //       isHorizontal: true,
                  //     ),
                  //     PostMoreButtonRowWidget(
                  //       icon: const Icon(Icons.qr_code),
                  //       text: 'QR code',
                  //     ),
                  //   ],
                  // ),

                  // Space(5.h),
                  FollowButtonInSHeet(data: widget.data),
                ],
              ),
        widget.isProfilePost ? 15.h : 15.h);
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
    List<dynamic> temp =
        Provider.of<Auth>(context, listen: false).userData?['followings'];
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
                .userData?['followings']
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
            Provider.of<Auth>(context, listen: false)
                .userData?['followings']
                .removeWhere(
                    (element) => element['user_id'] == widget.data['user_id']);
            setState(() {
              _isFollowing = false;
            });
          } else {
            TOastNotification()
                .showErrorToast(context, response['body']['message']);
          }
        }
      },
      child: Container(
          decoration: GlobalVariables().ContainerDecoration(
              offset: const Offset(0, 8),
              blurRadius: 20,
              boxColor: const Color.fromRGBO(84, 166, 193, 1),
              cornerRadius: 10,
              shadowColor: const Color.fromRGBO(152, 202, 201, 0.8)),
          width: double.infinity,
          height: 6.h,
          child: Center(
            child: Text(
              _isFollowing ? 'Unfollow' : 'Follow',
              style: const TextStyle(
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
        offset: const Offset(0, 4),
        blurRadius: 20,
        boxColor: Colors.white,
        cornerRadius: 10,
        shadowColor: const Color.fromRGBO(165, 200, 199, 0.6),
      ),
      width: double.infinity,
      height: 6.h,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        icon,
        Text(
          text,
          style: const TextStyle(
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
              offset: const Offset(0, 4),
              blurRadius: 20,
              boxColor: const Color.fromRGBO(200, 233, 233, 1),
              cornerRadius: 10,
              shadowColor: const Color.fromRGBO(124, 193, 191, 0.3),
            ),
            child: icon),
        Space(
          5.w,
          isHorizontal: true,
        ),
        Text(
          text,
          style: const TextStyle(
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
                                  .userData?['user_id']) {
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
                                      TOastNotification()
                                          .showErrorToast(context, 'Error!');
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
                Provider.of<Auth>(context, listen: true)
                            .userData!['proifle_photo'] ==
                        ''
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
                          color: const Color.fromRGBO(31, 111, 109, 0.6),
                          shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                            cornerRadius: 5,
                            cornerSmoothing: 1,
                          )),
                        ),
                        child: Center(
                          child: Text(
                            Provider.of<Auth>(context, listen: true)
                                .userData?['store_name'][0]
                                .toUpperCase(),
                            style: const TextStyle(fontSize: 20),
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
                            Provider.of<Auth>(context, listen: true)
                                .userData!['profile_photo'],
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
                            ' Type your comment here for ${widget.isProfilePost ? Provider.of<Auth>(context, listen: false).userData != null ? [
                                'store_name'
                              ] : widget.data['store_name'] : ""}...',
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
                        'user_id': Provider.of<Auth>(context, listen: false)
                            .userData?['user_id'],
                        'created_at': formattedDate,
                        'store_name': Provider.of<Auth>(context, listen: false)
                            .userData?['store_name'],
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
                      const BoxShadow(
                        offset: Offset(0, 4),
                        color: Color.fromRGBO(31, 111, 109, 0.6),
                        blurRadius: 20,
                      )
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
                      name[0],
                      style: const TextStyle(fontSize: 20),
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
                  const Space(isHorizontal: true, 6),
                  Text(
                    formatTimeDifference(dateString),
                    style: const TextStyle(
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
