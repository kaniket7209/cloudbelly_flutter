import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CreateFeed {
  Future<dynamic> showModalSheetForNewPost(
      BuildContext context, List<String> imageUrlList, List<dynamic> menuList) {
    CarouselController buttonCarouselController = CarouselController();
    return showModalBottomSheet(
      // useSafeArea: true,

      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        return Container(
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.only(
                  topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          padding: EdgeInsets.only(
              left: 6.w,
              right: 6.w,
              top: 2.h,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TouchableOpacity(
                  onTap: () {
                    return Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                      width: 65,
                      height: 9,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFA6E00),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ),
                Space(4.h),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '<<',
                        style: TextStyle(
                          color: Color(0xFFFA6E00),
                          fontSize: 22,
                          fontFamily: 'Kavoon',
                          fontWeight: FontWeight.w400,
                          height: 0.04,
                          letterSpacing: 0.66,
                        ),
                      ),
                    ),
                    Text(
                      'New post',
                      style: TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 22,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0.04,
                        letterSpacing: 0.66,
                      ),
                    )
                  ],
                ),
                Space(3.h),
                imageUrlList.length == 1
                    ? Center(
                        child: Container(
                          height: 200,
                          width: 200,
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
                              imageUrlList[0],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  GlobalVariables().loadingBuilderForImage,
                              errorBuilder:
                                  GlobalVariables().ErrorBuilderForImage,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: FlutterCarousel(
                          items: imageUrlList.map((url) {
                            return Container(
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
                                  width: 200, // Adjust the width as needed
                                  height: 200, // Adjust the height as needed
                                  fit: BoxFit.cover, // Adjust the fit as needed
                                ),
                              ),
                            );
                          }).toList(),
                          options: CarouselOptions(
                            autoPlay: false,
                            controller: buttonCarouselController,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            aspectRatio: 2.0,
                            initialPage: 0,
                          ),
                        ),
                      ),
                menuSuggestionWIdget(
                    imageUrlList: imageUrlList, menuList: menuList),
              ],
            ),
          ),
        );
      },
    );
  }
}

class menuSuggestionWIdget extends StatefulWidget {
  menuSuggestionWIdget({
    super.key,
    required this.menuList,
    required this.imageUrlList,
  });

  final List<dynamic> menuList;
  List<String> imageUrlList;
  @override
  State<menuSuggestionWIdget> createState() => _menuSuggestionWIdgetState();
}

class _menuSuggestionWIdgetState extends State<menuSuggestionWIdget> {
  String check = '';
  String caption = '';
  List<String> _hasTagList = [
    '#chicken',
    '#tandoori',
    '#boneless',
    '#For2',
    '#chicken',
    '#eggless',
    '#tranding',
  ];
  List<dynamic> selectedMenuItems = [];

  TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Space(3.h),
        TextField(
          onChanged: (value) {
            caption = value.toString();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
            hintText: 'Write a caption...',
            hintStyle: const TextStyle(
              color: Color(0xFF094B60),
              fontSize: 12,
              fontFamily: 'Product Sans Medium',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.36,
            ),
            border: InputBorder.none,
          ),
        ),
        Center(
          child: Container(
            width: 85.w,
            height: 2,
            decoration: const BoxDecoration(color: Color(0xFFFA6E00)),
          ),
        ),
        Space(5.h),
        const Text(
          'Link Menu Items',
          style: TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 14,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0,
            letterSpacing: 0.14,
          ),
        ),
        TextField(
          controller: _textEditingController,
          onChanged: (value) {
            setState(() {
              check = value;
            });
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
            hintText: 'Type something',
            hintStyle: const TextStyle(
              color: Color(0xFF094B60),
              fontSize: 12,
              fontFamily: 'Product Sans Medium',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.36,
            ),
            border: InputBorder.none,
          ),
        ),
        Center(
          child: Container(
            width: 85.w,
            height: 2,
            decoration: const BoxDecoration(color: Color(0xFFFA6E00)),
          ),
        ),
        SizedBox(height: 10),
        if (check != '')
          SizedBox(
            height: 10.h,
            child: ListView.builder(
              itemCount: widget.menuList.length,
              itemBuilder: (context, index) {
                if (_textEditingController.text.isEmpty ||
                    widget.menuList[index]['name']
                        .toLowerCase()
                        .contains(_textEditingController.text.toLowerCase())) {
                  return ListTile(
                    title: Text(widget.menuList[index]['name']),
                    onTap: () {
                      String idToFind =
                          widget.menuList[index]['_id']; // Example ID to find
                      bool isPresent = false;
                      for (var item in selectedMenuItems) {
                        if (item["_id"] == idToFind) {
                          isPresent = true;
                          break;
                        }
                      }
                      setState(() {
                        if (!isPresent)
                          selectedMenuItems.add(widget.menuList[index]);
                        _textEditingController.clear();
                      });
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        SizedBox(height: 10),
        if ((selectedMenuItems).length != 0) Text('Selected Suggestions:'),
        SizedBox(height: 5),
        Wrap(
          children: selectedMenuItems
              .map((suggestion) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Chip(
                      label: Text(suggestion['name']),
                      onDeleted: () {
                        setState(() {
                          selectedMenuItems.remove(suggestion);
                        });
                      },
                    ),
                  ))
              .toList(),
        ),
        const Text(
          'Give hashtags',
          style: TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 14,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0,
            letterSpacing: 0.14,
          ),
        ),
        Space(2.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
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
          child: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              contentPadding: EdgeInsets.only(left: 14),
              hintText: 'Link your post with your menu by #tags',
              hintStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0A4C61),
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w400),
              border: InputBorder.none,
            ),
            onChanged: (value) {},
          ),
        ),
        Space(2.h),
        SizedBox(
          height: 10.h,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            shrinkWrap: true, // Allow the GridView to shrink-wrap its content
            addAutomaticKeepAlives: true,

            padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 3.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 2.1,
              crossAxisCount: 4, // Number of items in a row
              crossAxisSpacing: 3.w, // Spacing between columns
              mainAxisSpacing: 1.5.h, // Spacing between rows
            ),
            itemCount: _hasTagList.length,
            itemBuilder: (context, index) {
              return TouchableOpacity(
                  onTap: () {
                    _textFieldController.text = _textFieldController.text == ''
                        ? _textFieldController.text + '${_hasTagList[index]}'
                        : _textFieldController.text + ', ${_hasTagList[index]}';
                  },
                  child: Container(
                      decoration: const ShapeDecoration(
                        color: Color.fromRGBO(239, 255, 254, 1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.all(SmoothRadius(
                              cornerRadius: 10, cornerSmoothing: 1)),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _hasTagList[index],
                          style: const TextStyle(
                            color: Color(0xFF0A4C61),
                            fontSize: 12,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w400,
                            height: 0,
                            letterSpacing: 0.12,
                          ),
                        ),
                      )));
            },
          ),
        ),
        Space(10.h),
        TouchableOpacity(
          onTap: () async {
            AppWideLoadingBanner().loadingBanner(context);
            List<String> tags = _textFieldController.text
                .split(',')
                .map((String s) => s.trim())
                .toList();

            String msg = await Provider.of<Auth>(context, listen: false)
                .createPost(
                    widget.imageUrlList, tags, caption, selectedMenuItems);
            Navigator.of(context).pop();
            if (msg == "Post metadata updated successfully") {
              TOastNotification()
                  .showSuccesToast(context, 'Post Created successfully!');

              Navigator.of(context).pop();
            } else {
              TOastNotification().showErrorToast(context, 'Error!');
            }
          },
          child: Container(
              height: 6.h,
              decoration: const ShapeDecoration(
                color: Color.fromRGBO(250, 110, 0, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.all(
                      SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                ),
              ),
              child: const Center(
                child: Text(
                  'Share',
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
        ),
        Space(15.h),
      ],
    );
  }
}
