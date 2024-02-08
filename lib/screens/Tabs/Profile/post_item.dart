// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PostItem extends StatefulWidget {
  PostItem({
    super.key,
    required bool isMultiple,
    required this.data,
  }) : _isMultiple = isMultiple;

  final bool _isMultiple;
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
      discription = widget.data['caption'];

      caption1 = getFittedText(discription, context)[0];
      print(caption1);
      caption2 = getFittedText(discription, context)[1];
      _getLikeData();
      _didUpdate = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // bool _isExpanded = false;
  List<String> getFittedText(String text, BuildContext context) {
    text = widget.data['caption'];
    final screenWidth = MediaQuery.of(context).size.width;
    final textStyle = const TextStyle(
      color: Color(0xFF0A4C61),
      fontSize: 12,
      fontFamily: 'Product Sans Medium',
      fontWeight: FontWeight.w500,
      height: 0,
      letterSpacing: 0.12,
    ); // Adjust the font size as needed

    // Initialize variables
    String fittedText = '';
    // String extraText = '';
    double totalWidth = 0;

    for (int i = 0; i < text.length; i++) {
      final testText = fittedText + text[i];
      final textPainter = TextPainter(
        text: TextSpan(text: testText, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: double.infinity);

      final textWidth = textPainter.size.width;
      totalWidth += textWidth;

      if (totalWidth <= screenWidth) {
        // Text fits within available width
        fittedText = testText;
      } else {
        // Text exceeds available width
        // extraText = text.substring(i);
        break;
      }
    }
    // print(fittedText);
    if (text.length < 50) {
      return [text, ''];
    } else {
      String text1 = text.substring(0, 50);
      print(text1);
      text1 = text1 + ' - ';
      String text2 = text.length > 50 ? text.substring(50) : '';

      return [text1, text2];
    }
  }

  bool _isLiked = false;

  void _getLikeData() {
    _isLiked = (widget.data['likes'] ?? [] as List<dynamic>)
        .contains(Provider.of<Auth>(context, listen: false).user_id);
  }

  @override
  Widget build(BuildContext context) {
    CarouselController buttonCarouselController = CarouselController();
    return Container(
      height: 65.h,
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    Provider.of<Auth>(context, listen: false).logo_url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Space(isHorizontal: true, 5.w),
              Text(
                Provider.of<Auth>(context, listen: false).store_name,
                style: const TextStyle(
                  color: Color(0xFF094B60),
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  height: 0.10,
                  letterSpacing: 0.42,
                ),
              ),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          Space(1.5.h),
          !widget._isMultiple
              ? Hero(
                  tag: widget.data['id'],
                  child: Center(
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
                            widget.data['file_path'],
                            fit: BoxFit.cover,
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
              IconButton(
                  onPressed: () async {
                    await Provider.of<Auth>(context, listen: false)
                        .likePost(widget.data['id']);
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                  icon: !_isLiked
                      ? const Icon(Icons.favorite_border)
                      : const Icon(Icons.favorite)),
              IconButton(
                  onPressed: () {
                    AppWideBottomSheet().showSheet(
                        context, CommentSheetContent(data: widget.data), 70.h);
                  },
                  icon: const Icon(Icons.mode_comment_outlined)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share))
            ],
          ),
          Space(0.5.h),
          Row(
            children: [
              const Text(
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
              Space(isHorizontal: true, 5.w),
              Text(
                '${(widget.data['likes'] ?? [] as List<dynamic>).length} peoples',
                style: const TextStyle(
                  color: Color(0xFF0A4C61),
                  fontSize: 12,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  height: 0,
                  letterSpacing: 0.12,
                ),
              )
            ],
          ),
          Space(1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Provider.of<Auth>(context, listen: false).store_name,
                style: const TextStyle(
                  color: Color(0xFFFA6E00),
                  fontSize: 12,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.36,
                ),
              ),
              Space(isHorizontal: true, 3.w),
              Expanded(
                child: SizedBox(
                  child: Text(
                    caption1.toString(),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF0A4C61),
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
              height: 1.4.h,
              child: Text(
                caption2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0A4C61),
                  fontSize: 12,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.12,
                ),
              ),
            ),
          TouchableOpacity(
            onTap: () {
              AppWideBottomSheet().showSheet(
                  context, CommentSheetContent(data: widget.data), 70.h);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0.6.h,
              ),
              child: Text(
                'View ${(widget.data['comments'] ?? [] as List<dynamic>).length} comments',
                style: const TextStyle(
                  color: Color(0xFF519796),
                  fontSize: 11,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w500,
                  height: 0,
                  letterSpacing: 0.11,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CommentSheetContent extends StatefulWidget {
  const CommentSheetContent({super.key, required this.data});

  final data;

  @override
  State<CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<CommentSheetContent> {
  TextEditingController _controller = TextEditingController();
  String _comment = '';

  @override
  Widget build(BuildContext context) {
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
                fontWeight: FontWeight.w700,
                height: 0,
                letterSpacing: 0.18,
              ),
            ),
          ),
          Container(
            height: 53.h,
            child: (newData['comments'] ?? [] as List<dynamic>).length == 0
                ? Center(
                    child: Text('No Comments Yet'),
                  )
                : ListView.builder(
                    itemCount:
                        (newData['comments'] ?? [] as List<dynamic>).length,
                    itemBuilder: (context, index) {
                      return CommentItemWidget(
                        name: 'user_name',
                        text: newData['comments'][index]['text'],
                      );
                    },
                  ),
          ),
          Space(1.h),
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
                Container(
                  height: 40,
                  width: 40,
                  decoration: const ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        color: Color.fromRGBO(31, 111, 109, 0.3),
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
                            ' Type your comment here for ${Provider.of<Auth>(context, listen: false).store_name}...',
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
                      _list.add({
                        'text': _comment,
                        'user_id':
                            Provider.of<Auth>(context, listen: false).user_id,
                        'created_at': DateTime.now().toString(),
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
                    height: 40,
                    width: 40,
                    decoration: ShapeDecoration(
                      color: const Color.fromRGBO(250, 110, 0, 1),
                      shadows: const [
                        BoxShadow(
                          offset: Offset(0, 4),
                          color: Color.fromRGBO(31, 111, 109, 0.3),
                          blurRadius: 20,
                        )
                      ],
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 5,
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
  CommentItemWidget({
    super.key,
    required this.name,
    required this.text,
  });
  String name;
  String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Space(isHorizontal: true, 2.w),
          Container(
            height: 40,
            width: 40,
            decoration: const ShapeDecoration(
              shadows: [
                BoxShadow(
                  offset: Offset(0, 4),
                  color: Color.fromRGBO(31, 111, 109, 0.3),
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
                'https://yt3.googleusercontent.com/MANvrSkn-NMy7yTy-dErFKIS0ML4F6rMl-aE4b6P_lYN-StnCIEQfEH8H6fudTC3p0Oof3Pd=s176-c-k-c0x00ffffff-no-rj',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Space(isHorizontal: true, 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF0A4C61),
                  fontSize: 10,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.10,
                ),
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border))
        ],
      ),
    );
  }
}
