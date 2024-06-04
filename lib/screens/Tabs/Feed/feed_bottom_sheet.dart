import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/widgets/horizontal_list.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FeedBottomSheet {
  Future<dynamic> ProductsInPostSheet(BuildContext context, dynamic data,
      bool isLiked, List<ProductDetails> productList, userId) {
    print("length:: ${productList.length}");
    return showModalBottomSheet(
      // useSafeArea: true,
      backgroundColor: Colors.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: true,
      builder: (BuildContext context) {
        bool _isVendor =
            Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                'Vendor';
        // print(data);
        return WillPopScope(
          onWillPop: () async {
            context.read<TransitionEffect>().setBlurSigma(0);
            return true;
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1),
                          topRight: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1)),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: double.infinity,
                  padding: EdgeInsets.only(
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h, horizontal: 3.w),
                              width: 55,
                              height: 5,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFA6E00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                        ProductInPostSheetWidget(
                          isVendor: _isVendor,
                          data: data,
                          isLiked: isLiked,
                          productList: productList,
                          isProfile: false,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
    required this.productList,
    required this.isProfile,
  });

  bool isVendor;
  bool isProfile;
  dynamic data;
  bool isLiked;
  List<ProductDetails> productList;

  @override
  State<ProductInPostSheetWidget> createState() =>
      _ProductInPostSheetWidgetState();
}

class _ProductInPostSheetWidgetState extends State<ProductInPostSheetWidget> {
  PageController _pageController = PageController(initialPage: 0);

  int _currentPageIndex = 0;
  bool isAddToCart = false;
  int? allProductPrice = 0;
  List<ProductDetails> tempList = [];

  void updateTotalPrice(ProductDetails product) {
    final double price = double.tryParse(product.price ?? "0.0") ?? 0.0;

    // Calculate the total price
    final int totalPrice = (price * (product.quantity ?? 0)).toInt();

    // Assign the calculated total price to the product
    product.totalPrice = totalPrice.toString();

    // Print for debugging
    print("Total price: $totalPrice");

    // If this function is called inside a StatefulWidget, call setState to trigger a UI update
    setState(() {
      // Perform any necessary UI updates here
    });
  }

  void tempPriceCalculation() {
    allProductPrice = 0;
    for (var product in tempList) {
      final int? totalPrice = int.tryParse(product.totalPrice ?? "0");
      if (totalPrice != null) {
        allProductPrice = (allProductPrice ?? 0) + totalPrice;
      }
    }
    print("allProductPrice:: $allProductPrice");
    setState(() {
      // Perform any necessary UI updates here
    });
  }

  @override
  Widget build(BuildContext context) {
    int menuItemsCount = widget.data['menu_items'].length;
    double pageCount = menuItemsCount % 3 == 0
        ? (menuItemsCount / 3) as double
        : (((menuItemsCount / 3).toInt()) + 1);
    print("data:: ${widget.data}");
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space(3.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Row(
              children: [
                Container(
                  height: /*_isfocused ?*/ 50 /*: 88*/,
                  width: /*_isfocused ?*/ 50 /*: 88*/,
                  decoration: const ShapeDecoration(
                    shadows: [
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
                      cornerRadius: /*_isfocused ?*/ 15 /*: 25*/,
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
                const Space(
                  22,
                  isHorizontal: true,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Space(6),
                    Text(
                      widget.data['store_name'] ??
                          Provider.of<Auth>(context, listen: false)
                              .userData?['store_name'],
                      style: const TextStyle(
                        color: Color(0xFF2E0435),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.42,
                      ),
                    ),
                    const Space(4),
                    SizedBox(
                      width: 188,
                      child: Text(
                        widget.data['caption'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2E0536),
                          fontSize: 12,
                          fontFamily: 'Product Sans Medium',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Space(27),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Text(
              '${widget.productList.length} Products in this post',
              style: const TextStyle(
                color: Color(0xFF2E0536),
                fontSize: 22,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: 0.32,
              ),
            ),
          ),
          const Space(18),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 600, // Set the maximum width to 800
            ),
            child: PageView.builder(
              reverse: false,
              padEnds: true,
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                _currentPageIndex = index;
                setState(() {});
              },
              itemCount: widget.productList.length,
              itemBuilder: (context, index) {
                print(widget.data);
                final product = widget.productList[index];
                product.totalPrice ??= product.price ?? "0.0";
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Column(
                    children: [
                      widget.productList[index].images!.isNotEmpty
                          ? Container(
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                              decoration: ShapeDecoration(
                                shadows: [
                                  Provider.of<Auth>(context, listen: false)
                                              .userData?['user_type'] ==
                                          UserType.Vendor.name
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
                                shape: SmoothRectangleBorder(),
                              ),
                              child: ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                  cornerRadius: 45,
                                  cornerSmoothing: 1,
                                ),
                                child: Image.network(
                                  widget.productList[index].images?.first ?? "",
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      GlobalVariables().loadingBuilderForImage,
                                  errorBuilder:
                                      GlobalVariables().ErrorBuilderForImage,
                                ),
                              ),
                            )
                          : Image.asset(
                              Assets.noProduct,
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width,
                            ),
                      const Space(26),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.productList[index].name ?? "",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Color(0xFF2E0536),
                                    fontSize: 14,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.42,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Space(4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.favorite_border,
                                      size: 20,
                                    ),
                                    const Space(isHorizontal: true, 10),
                                    Text(
                                      "${(widget.data['likes'] ?? []).length}",
                                      style: const TextStyle(
                                        color: Color(0xFF9327A8),
                                        fontSize: 12,
                                        fontFamily: 'Product Sans Medium',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                        letterSpacing: 0.10,
                                      ),
                                    ),
                                  ],
                                ),
                                const Space(6),
                                SizedBox(
                                  width: 188,
                                  child: Text(
                                    widget.productList[index].description ?? "",
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
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
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 41,
                                width: 113,
                                decoration: ShapeDecoration(
                                  shape: SmoothRectangleBorder(
                                    side: const BorderSide(
                                      color: Color(0xFF000000),
                                      width: 2.0,
                                    ),
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 12,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Rs ${widget.productList[index].totalPrice.toString()}",
                                    style: const TextStyle(
                                      color: Color(0xFF2E0536),
                                      fontSize: 18,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                      letterSpacing: 0.18,
                                    ),
                                  ),
                                ),
                              ),
                              const Space(11),
                              widget.productList[index].isAddToCart == true
                                  ? Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (product.quantity! > 1) {
                                                product.quantity =
                                                    product.quantity! - 1;
                                                updateTotalPrice(product);
                                                tempPriceCalculation();
                                              } else {
                                                widget.productList[index]
                                                    .isAddToCart = false;
                                                tempList.remove(
                                                    widget.productList[index]);
                                                tempPriceCalculation();
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: 33,
                                            width: 33,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFFA6E00),
                                              shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius(
                                                  cornerRadius: 12,
                                                  cornerSmoothing: 1,
                                                ),
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '-',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w700,
                                                  height: 0,
                                                  letterSpacing: 0.14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Space(
                                          16,
                                          isHorizontal: true,
                                        ),
                                        Text(
                                          "${widget.productList[index].quantity}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w700,
                                            height: 0,
                                            letterSpacing: 0.14,
                                          ),
                                        ),
                                        const Space(
                                          16,
                                          isHorizontal: true,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (product.quantity! < 10) {
                                                product.quantity =
                                                    product.quantity! + 1;
                                                updateTotalPrice(product);
                                                tempPriceCalculation();
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: 33,
                                            width: 33,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFFA6E00),
                                              shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius(
                                                  cornerRadius: 12,
                                                  cornerSmoothing: 1,
                                                ),
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
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
                                    )
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          widget.productList[index]
                                              .isAddToCart = true;
                                          isAddToCart = widget
                                              .productList[index].isAddToCart;
                                          widget.productList[index].quantity =
                                              1;
                                          tempList
                                              .add(widget.productList[index]);
                                          tempPriceCalculation();
                                        });
                                      },
                                      child: Container(
                                        height: 41,
                                        width: 113,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFFA6E00),
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 12,
                                              cornerSmoothing: 1,
                                            ),
                                          ),
                                        ),
                                        child: const Center(
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
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const Space(25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CaloriesColumnWidget(
                              text: 'Calories',
                              data:
                                  '${widget.productList[index].macros?.calories} kcal'),
                          CaloriesColumnWidget(
                              text: 'Protein',
                              data:
                                  '${widget.productList[index].macros?.proteins} g'),
                          CaloriesColumnWidget(
                              text: 'Carbs',
                              data:
                                  '${widget.productList[index].macros?.carbohydrates} g'),
                          CaloriesColumnWidget(
                              text: 'Fats',
                              data:
                                  '${widget.productList[index].macros?.fats} g'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.productList.length,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                child: index == _currentPageIndex
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6.0),
                        height: 10.0,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _currentPageIndex == index
                              ? const Color.fromRGBO(148, 40, 169, 1)
                              : const Color.fromRGBO(214, 175, 227, 1),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6.0),
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPageIndex == index
                              ? const Color.fromRGBO(148, 40, 169, 1)
                              : const Color.fromRGBO(214, 175, 227, 1),
                        ),
                      ),
              ),
            ),
          ),
          if (isAddToCart == true && tempList.isNotEmpty) ...[
            const Space(17),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 7.w),
              width: double.infinity,
              height: 75,
              decoration: GlobalVariables().ContainerDecoration(
                offset: const Offset(3, 6),
                blurRadius: 20,
                shadowColor: const Color.fromRGBO(179, 108, 179, 0.5),
                boxColor: const Color.fromRGBO(123, 53, 141, 1),
                cornerRadius: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${tempList.length} Items   |   Rs $allProductPrice',
                        style: const TextStyle(
                          color: Color(0xFFF7F7F7),
                          fontSize: 16,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Extra charges may apply',
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
                      Provider.of<ViewCartProvider>(context, listen: false)
                          .getProductList(tempList);
                      context.read<TransitionEffect>().setBlurSigma(0);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ViewCart()));
                    },
                    child: Container(
                      height: 41,
                      width: 113,
                      decoration: ShapeDecoration(
                        color: const Color.fromRGBO(84, 166, 193, 1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                      child: const Center(
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
                  ),
                ],
              ),
            ),
          ],
          const Space(30),
        ],
      ),
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
          style: const TextStyle(
            color: Color(0xFF9327A8),
            fontSize: 12,
            fontFamily: 'Product Sans Medium',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.12,
          ),
        ),
        Text(
          data,
          style: const TextStyle(
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
              decoration: const ShapeDecoration(
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
          const Space(8),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 20,
                    ),
                    const Space(isHorizontal: true, 10),
                    Text(
                      '${(widget.data['likes'] ?? []).length}',
                      style: const TextStyle(
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
                const Space(8),
                const Text(
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
          const Space(14),
          Container(
            width: 71,
            height: 30,
            decoration: GlobalVariables().ContainerDecoration(
                offset: const Offset(3, 6),
                blurRadius: 20,
                shadowColor: const Color.fromRGBO(158, 116, 158, 0.5),
                boxColor: const Color.fromRGBO(250, 110, 0, 1),
                cornerRadius: 8),
            child: const Center(
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
