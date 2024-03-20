import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FeedBottomSheet {
  Future<dynamic> ProductsInPostSheet(
      BuildContext context, dynamic data, bool isLiked) {
    return showModalBottomSheet(
      // useSafeArea: true,
      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        bool _isVendor =
            Provider.of<Auth>(context, listen: false).userType == 'Vendor';
        // print(data);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        topLeft:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                        topRight:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: 2.h, bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            padding: EdgeInsets.symmetric(
                                vertical: 1.h, horizontal: 3.w),
                            width: 65,
                            height: 6,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFA6E00),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                      ProductInPostSheetWidget(
                          isVendor: _isVendor, data: data, isLiked: isLiked)
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ProductInPostSheetWidget extends StatefulWidget {
  ProductInPostSheetWidget({
    super.key,
    required this.isVendor,
    required this.data,
    required this.isLiked,
  });

  bool isVendor;
  dynamic data;
  bool isLiked;

  @override
  State<ProductInPostSheetWidget> createState() =>
      _ProductInPostSheetWidgetState();
}

class _ProductInPostSheetWidgetState extends State<ProductInPostSheetWidget> {
  PageController _pageController = PageController(initialPage: 0);
  bool _isfocused = false;
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    int menuItemsCount = widget.data['menu_items'].length;
    int pageCount = menuItemsCount % 3 == 0
        ? (menuItemsCount / 3) as int
        : (((menuItemsCount / 3).toInt()) + 1);
    print(pageCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Space(4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isfocused)
                    TouchableOpacity(
                      onTap: () {
                        setState(() {
                          _isfocused = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 10, top: 10, bottom: 10),
                        child: SizedBox(
                          width: 25,
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
                      ),
                    ),
                  Container(
                    height: _isfocused ? 50 : 88,
                    width: _isfocused ? 50 : 88,
                    decoration: ShapeDecoration(
                      shadows: [
                        // widget.isVendor
                        //     ? BoxShadow(
                        //         offset: Offset(0, 4),
                        //         color: Color.fromRGBO(124, 193, 191, 0.6),
                        //         blurRadius: 20,
                        //       )
                        //     :
                        BoxShadow(
                          offset: Offset(3, 4),
                          color: Color.fromRGBO(158, 116, 158, 0.5),
                          blurRadius: 15,
                        )
                      ],
                      shape: SmoothRectangleBorder(),
                    ),
                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius(
                        cornerRadius: _isfocused ? 15 : 25,
                        cornerSmoothing: 1,
                      ),
                      child: Image.network(
                        widget.data['file_path'],
                        fit: BoxFit.cover,
                        loadingBuilder:
                            GlobalVariables().loadingBuilderForImage,
                        errorBuilder: GlobalVariables().ErrorBuilderForImage,
                      ),
                    ),
                  ),
                  Space(
                    22,
                    isHorizontal: true,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Space(6),
                      Text(
                        widget.data['store_name'],
                        style: TextStyle(
                          color: Color(0xFF2E0435),
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.42,
                        ),
                      ),
                      Space(4),
                      SizedBox(
                        width: 188,
                        child: Text(
                          widget.data['caption'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF2E0536),
                            fontSize: 12,
                            fontFamily: 'Product Sans Medium',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ),
                      if (!_isfocused) Space(10),
                      if (!_isfocused)
                        Row(
                          children: [
                            Icon(
                              widget.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                            ),
                            Space(isHorizontal: true, 2),
                            Text(
                              '${(widget.data['likes'] ?? []).length}',
                              style: TextStyle(
                                color: Color(0xFF9327A8),
                                fontSize: 10,
                                fontFamily: 'Product Sans Medium',
                                fontWeight: FontWeight.w500,
                                height: 0,
                                letterSpacing: 0.10,
                              ),
                            ),
                            Space(isHorizontal: true, 11),
                            Icon(
                              Icons.mode_comment_outlined,
                              size: 20,
                            ),
                            Space(isHorizontal: true, 2),
                            Text(
                              '231',
                              style: TextStyle(
                                color: Color(0xFF9327A8),
                                fontSize: 10,
                                fontFamily: 'Product Sans Medium',
                                fontWeight: FontWeight.w500,
                                height: 0,
                                letterSpacing: 0.10,
                              ),
                            ),
                            Space(isHorizontal: true, 11),
                            Icon(
                              Icons.share,
                              size: 20,
                            )
                          ],
                        )
                    ],
                  )
                ],
              ),
              Space(27),
              Text(
                'Products in this post',
                style: TextStyle(
                  color: Color(0xFF2E0536),
                  fontSize: 22,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                  height: 0,
                  letterSpacing: 0.22,
                ),
              ),
            ],
          ),
        ),
        //https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1
        Space(_isfocused ? 13 : 8),
        _isfocused
            ? Container(
                margin: EdgeInsets.only(left: 7.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 202,
                            width: 202,
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  offset: Offset(3, 6),
                                  color: Color.fromRGBO(158, 116, 158, 10.5),
                                  blurRadius: 20,
                                )
                              ],
                              shape: SmoothRectangleBorder(),
                            ),
                            child: ClipSmoothRect(
                              radius: SmoothBorderRadius(
                                cornerRadius: 45,
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
                          Space(36, isHorizontal: true),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CaloriesColumnWidget(
                                  text: 'Calories', data: '230 kcal'),
                              CaloriesColumnWidget(
                                  text: 'Protein', data: '24.4 g'),
                              CaloriesColumnWidget(text: 'Carbs', data: '21 g'),
                              CaloriesColumnWidget(text: 'Fats', data: '7 g'),
                            ],
                          )
                        ],
                      ),
                      Space(15),
                      Row(
                        children: [
                          Space(
                            15,
                            isHorizontal: true,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panner Lababdar',
                                style: TextStyle(
                                  color: Color(0xFF2E0536),
                                  fontSize: 14,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.42,
                                ),
                              ),
                              Space(4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 20,
                                  ),
                                  Space(isHorizontal: true, 10),
                                  Text(
                                    '${(widget.data['likes'] ?? []).length}',
                                    style: TextStyle(
                                      color: Color(0xFF9327A8),
                                      fontSize: 10,
                                      fontFamily: 'Product Sans Medium',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                      letterSpacing: 0.10,
                                    ),
                                  ),
                                ],
                              ),
                              Space(6),
                              SizedBox(
                                width: 188,
                                child: Text(
                                  'This is by far the best biryani we ever made, come and enjoy the taste of North  Bengal.',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFF2E0536),
                                    fontSize: 12,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                    letterSpacing: 0.12,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Space(
                            10,
                            isHorizontal: true,
                          ),
                          Column(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 41,
                                    width: 113,
                                    decoration: ShapeDecoration(
                                      shape: SmoothRectangleBorder(
                                          side: BorderSide(
                                            color: Colors.black, // Border color
                                            width: 2.0, // Border width
                                          ),
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: 12,
                                            cornerSmoothing: 1,
                                          )),
                                    ),
                                    child: Center(
                                        child: Text(
                                      'Rs 256',
                                      style: TextStyle(
                                        color: Color(0xFF2E0536),
                                        fontSize: 18,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                        letterSpacing: 0.18,
                                      ),
                                    )),
                                  ),
                                  Space(11),
                                  Container(
                                    height: 41,
                                    width: 113,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFFFA6E00),
                                      shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                        cornerRadius: 12,
                                        cornerSmoothing: 1,
                                      )),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Add to Cart',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Product Sans',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                          letterSpacing: 0.14,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ]),
              )
            : Container(
                height: 28.h,
                width: double.infinity,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    Column(
                      children: [
                        Space(0.7.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ItemWidget(
                              widget: widget,
                              onTap: () {
                                setState(() {
                                  _isfocused = true;
                                });
                              },
                            ),
                            ItemWidget(
                              widget: widget,
                              onTap: () {
                                setState(() {
                                  _isfocused = true;
                                });
                              },
                            ),
                            ItemWidget(
                              widget: widget,
                              onTap: () {
                                setState(() {
                                  _isfocused = true;
                                });
                              },
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
        Space(1.h),
        if (!_isfocused)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                child: index == _currentPageIndex
                    ? Container(
                        height: 10.0,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _currentPageIndex == index
                              ? const Color.fromRGBO(148, 40, 169, 1)
                              : Color.fromRGBO(214, 175, 227, 1),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPageIndex == index
                              ? const Color.fromRGBO(148, 40, 169, 1)
                              : Color.fromRGBO(214, 175, 227, 1),
                        ),
                      ),
              ),
            ),
          ),
        Space(1.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 7.w),
          width: double.infinity,
          height: 75,
          decoration: GlobalVariables().ContainerDecoration(
              offset: Offset(3, 6),
              blurRadius: 20,
              shadowColor: Color.fromRGBO(179, 108, 179, 0.5),
              boxColor: Color.fromRGBO(123, 53, 141, 1),
              cornerRadius: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '3 Items   |   Rs 840',
                    style: TextStyle(
                      color: Color(0xFFF7F7F7),
                      fontSize: 16,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Extra chrges may apply',
                    style: TextStyle(
                      color: Color(0xFFF7F7F7),
                      fontSize: 12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              TouchableOpacity(
                onTap: () {
                  Navigator.of(context).pushNamed(ViewCart.routeName);
                },
                child: Container(
                  height: 41,
                  width: 113,
                  decoration: ShapeDecoration(
                    color: Color.fromRGBO(84, 166, 193, 1),
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    )),
                  ),
                  child: Center(
                    child: Text(
                      'View Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: 0.14,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Space(2.h),
      ],
    );
  }
}

class CaloriesColumnWidget extends StatelessWidget {
  CaloriesColumnWidget({
    super.key,
    required this.data,
    required this.text,
  });
  String text;
  String data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Color(0xFF9327A8),
            fontSize: 12,
            fontFamily: 'Product Sans Medium',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.12,
          ),
        ),
        Text(
          data,
          style: TextStyle(
            color: Color(0xFF2E0536),
            fontSize: 18,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.54,
          ),
        )
      ],
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    this.onTap,
    super.key,
    required this.widget,
  });
  final Function? onTap;

  final ProductInPostSheetWidget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: EdgeInsets.symmetric(
        vertical: 1.h,
      ),
      child: Column(
        children: [
          TouchableOpacity(
            onTap: onTap as void Function()?,
            child: Container(
              height: 90,
              width: 90,
              decoration: ShapeDecoration(
                shadows: [
                  BoxShadow(
                    offset: Offset(3, 6),
                    color: Color.fromRGBO(158, 116, 158, 0.5),
                    blurRadius: 20,
                  )
                ],
                shape: SmoothRectangleBorder(),
              ),
              child: ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 25,
                  cornerSmoothing: 1,
                ),
                child: Image.network(
                  widget.data['file_path'],
                  fit: BoxFit.cover,
                  loadingBuilder: GlobalVariables().loadingBuilderForImage,
                  errorBuilder: GlobalVariables().ErrorBuilderForImage,
                ),
              ),
            ),
          ),
          Space(8),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 20,
                    ),
                    Space(isHorizontal: true, 10),
                    Text(
                      '${(widget.data['likes'] ?? []).length}',
                      style: TextStyle(
                        color: Color(0xFF9327A8),
                        fontSize: 12,
                        fontFamily: 'Product Sans Medium',
                        fontWeight: FontWeight.w500,
                        height: 0,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ],
                ),
                Space(8),
                Text(
                  'Panner Lababdar',
                  maxLines: null,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF2E0536),
                    fontSize: 14,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.42,
                  ),
                ),
              ],
            ),
          ),
          Space(14),
          Container(
            width: 71,
            height: 30,
            decoration: GlobalVariables().ContainerDecoration(
                offset: Offset(3, 6),
                blurRadius: 20,
                shadowColor: Color.fromRGBO(158, 116, 158, 0.5),
                boxColor: Color.fromRGBO(250, 110, 0, 1),
                cornerRadius: 8),
            child: Center(
                child: Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.14,
              ),
            )),
          ),
        ],
      ),
    );
  }
}
