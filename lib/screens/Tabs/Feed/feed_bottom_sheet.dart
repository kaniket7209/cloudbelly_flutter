import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
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
      bool isLiked, List<ProductDetails> productList) {
    print("length:: ${productList.length}");
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
                height: MediaQuery.of(context).size.height * 0.9,
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
                      )
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
    required this.productList,
  });

  bool isVendor;
  dynamic data;
  bool isLiked;
  List<ProductDetails> productList;

  @override
  State<ProductInPostSheetWidget> createState() =>
      _ProductInPostSheetWidgetState();
}

class _ProductInPostSheetWidgetState extends State<ProductInPostSheetWidget> {
  PageController _pageController = PageController(initialPage: 0);

  // bool _isfocused = false;
  int _currentPageIndex = 0;
  bool isAddToCart = false;
  int? allProductPrice;
  List<ProductDetails> tempList = [];
  List<int> intList = [1, 2, 3, 4, 5, 6, 7, 8, 9];

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

  void abc() {
    intList.forEach((element) {
      int value = element += element;
      print(value);
    });
    setState(() {});
  }

  void tempPriceCalculation(ProductDetails product) {
    if (product.isAddToCart == false) {
      // Check if product.totalPrice is null or empty
      if (product.totalPrice == null || product.totalPrice!.isEmpty) {
        product.totalPrice = product.price;
      }
      // Parse totalPrice to int
      final int? totalPrice = int.tryParse(product.totalPrice ?? "");
      // Check if totalPrice is not null
      if (totalPrice != null) {
        // Update allProductPrice
        allProductPrice = (allProductPrice ?? 0) + totalPrice;
        print("allProductPrice:: $allProductPrice");
      }
    }
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
    print(pageCount);
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
                      widget.data['store_name'],
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
          SizedBox(
            //  fit: BoxFit.cover,
            height:/* widget.productList.first.macros?.fats != ""
                ? MediaQuery.of(context).size.height * 0.8
                :*/ MediaQuery.of(context).size.height *
                    0.7, // Adjust the multiplier as needed
            child: PageView.builder(
                reverse: false,
                padEnds: true,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index) {
                  _currentPageIndex = index;
                  setState(() {});
                },
                itemCount: widget.productList.length,
                /*onPageChange: (index) {
                     _currentPageIndex = index;
                     setState(() {});
                },*/
                itemBuilder: (context, index) {
                  final product = widget.productList[index];
                  product.totalPrice ??=
                      widget.productList[index].price ?? "0.0";
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44),
                    child: Column(
                      children: [
                        widget.productList[index].images!.isNotEmpty
                            ? Container(
                                height: MediaQuery.of(context).size.height * .4,
                                width: MediaQuery.of(context).size.width,
                                decoration: const ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
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
                                    cornerRadius: 45,
                                    cornerSmoothing: 1,
                                  ),
                                  child: Image.network(
                                    widget.productList[index].images?.first ??
                                        "",
                                    fit: BoxFit.cover,
                                    loadingBuilder: GlobalVariables()
                                        .loadingBuilderForImage,
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
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.favorite_border,
                                        size: 20,
                                      ),
                                      Space(isHorizontal: true, 10),
                                      Text(
                                        "0",
                                        style: TextStyle(
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
                                      // widget.data['caption'],
                                      widget.productList[index].description ??
                                          "",
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
                                          color: Color(0xFF000000), // Border color
                                          width: 2.0, // Border width
                                        ),
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 12,
                                          cornerSmoothing: 1,
                                        )),
                                  ),
                                  child: Center(
                                      child: Text(
                                    // widget.productList[index].totalPrice != 0 ?'Rs ${widget.productList[index].price ?? ""}' :"Rs ${widget.productList[index].totalPrice}",
                                    "Rs ${widget.productList[index].totalPrice.toString()}",
                                    style: const TextStyle(
                                      color: Color(0xFF2E0536),
                                      fontSize: 18,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                      letterSpacing: 0.18,
                                    ),
                                  )),
                                ),
                                const Space(11),
                                widget.productList[index].isAddToCart == true
                                    ? Row(
                                        //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              /*(widget.productList[index]
                                                          .quantity ??
                                                      0) -
                                                  1;*/
                                              //print(product.quantity = product.quantity! + 1);
                                              setState(() {
                                                if (product.quantity! > 1) {
                                                  product.quantity =
                                                      product.quantity! - 1;
                                                  updateTotalPrice(product);
                                                  tempPriceCalculation(product);
                                                  /*product.totalPrice =
                                                      int.tryParse(
                                                          product.price ??
                                                              "0.0");
                                                  var price = product.quantity! *
                                                      double.parse(
                                                          product.price ?? "");
                                                  product.totalPrice =
                                                      price.toInt();*/
                                                  print(
                                                      "price:: ${product.totalPrice}, ${product.quantity}");
                                                } else {
                                                  widget.productList[index]
                                                      .isAddToCart = false;
                                                  tempList.remove(widget
                                                      .productList[index]);
                                                  tempPriceCalculation(product);
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
                                                )),
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
                                            style: TextStyle(
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
                                                  tempPriceCalculation(product);
                                                  /*product.totalPrice =
                                                      int.tryParse(
                                                          product.price ?? "0.0");
                                                  var price = product.quantity! *
                                                      double.parse(
                                                          product.price ?? "");
                                                  product.totalPrice =
                                                      price.toInt();*/
                                                  print(
                                                      "price:: ${product.totalPrice}");
                                                }

                                                // print((product.quantity ?? 0) * double.parse(product.price ?? ""));
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
                                                )),
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
                                          widget.productList[index]
                                              .isAddToCart = true;
                                          tempPriceCalculation(product);
                                          isAddToCart = widget
                                              .productList[index].isAddToCart;
                                          widget.productList[index].quantity =
                                              1;
                                          tempList
                                              .add(widget.productList[index]);
                                          setState(() {});
                                          print("data:: ${widget.data}");
                                        },
                                        child: Container(
                                          height: 41,
                                          width: 113,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFFA6E00),
                                            shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius(
                                              cornerRadius: 12,
                                              cornerSmoothing: 1,
                                            )),
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
                            )
                          ],
                        ),
                        const Space(34),
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
                        /*if (widget.productList[index].macros?.calories != "" ||
                            widget.productList[index].macros?.proteins != "" ||
                            widget.productList[index].macros?.carbohydrates !=
                                "" ||
                            widget.productList[index].macros?.fats != "") ...[

                        ],*/
                      ],
                    ),
                  );
                }),
          ),
          // const Space(20),
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
                        '${tempList.length} Items   |   Rs $allProductPrice',
                        style: const TextStyle(
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
                      Provider.of<ViewCartProvider>(context, listen: false)
                          .getProductList(tempList);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ViewCart()));
                      /* Navigator.of(context).pushNamed(ViewCart.routeName,arguments: {
                        tempList,
                      });*/
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
                        )),
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

/*Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Space(4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /*if (_isfocused)*/
                  TouchableOpacity(
                    onTap: () {
                      setState(() {
                        //_isfocused = false;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
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
                    height: /*_isfocused ?*/ 50 /*: 88*/,
                    width: /*_isfocused ?*/ 50 /*: 88*/,
                    decoration: const ShapeDecoration(
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
                        cornerRadius: /*_isfocused ?*/ 15 /*: 25*/,
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
                  const Space(
                    22,
                    isHorizontal: true,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Space(6),
                      Text(
                        widget.data['store_name'],
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
                      /*if (!_isfocused)*/ const Space(10),
                      /* if (!_isfocused)*/
                      Row(
                        children: [
                          Icon(
                            widget.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                          ),
                          const Space(isHorizontal: true, 2),
                          Text(
                            '${(widget.data['likes'] ?? []).length}',
                            style: const TextStyle(
                              color: Color(0xFF9327A8),
                              fontSize: 10,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w500,
                              height: 0,
                              letterSpacing: 0.10,
                            ),
                          ),
                          const Space(isHorizontal: true, 11),
                          const Icon(
                            Icons.mode_comment_outlined,
                            size: 20,
                          ),
                          const Space(isHorizontal: true, 2),
                          const Text(
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
                          const Space(isHorizontal: true, 11),
                          const Icon(
                            Icons.share,
                            size: 20,
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
              const Space(27),
              const Text(
                'Products in this post',
                style: TextStyle(
                  color: Color(0xFF2E0536),
                  fontSize: 22,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                  height: 0,
                  letterSpacing: 0.32,
                ),
              ),
            ],
          ),
        ),
        //https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1
        Space(/*_isfocused ?*/ 13 /*: 8*/),
        /*_isfocused
            ?*/
        HorizontalPageView(
            onPageChange: (index) {
              _currentPageIndex = index;
              setState(() {});
            },
            // scrollDirection: Axis.horizontal,
            itemCount: widget.productList.length,
            itemBuilder: (context, index) {
              return Container(
                height:MediaQuery.of(context).size.height,
                //width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 7.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          // height: 202,
                          width: 202,
                          decoration: const ShapeDecoration(
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
                        const Space(36, isHorizontal: true),
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
                    const Space(15),
                    Row(
                      children: [
                        const Space(
                          15,
                          isHorizontal: true,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Panner Lababdar',
                              style: TextStyle(
                                color: Color(0xFF2E0536),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.42,
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
                                  '${(widget.data['likes'] ?? []).length}',
                                  style: const TextStyle(
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
                            const Space(6),
                            SizedBox(
                              width: 188,
                              child: Text(
                                widget.data['caption'],
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
                        const Space(
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
                                        side: const BorderSide(
                                          color: Colors.black, // Border color
                                          width: 2.0, // Border width
                                        ),
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 12,
                                          cornerSmoothing: 1,
                                        )),
                                  ),
                                  child: const Center(
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
                                const Space(11),
                                InkWell(
                                  onTap: () {
                                    print("data:: ${widget.data}");
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
                                      )),
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
                                )
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
        Space(1.h),
        //if (!_isfocused)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount.toInt(),
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
                        : const Color.fromRGBO(214, 175, 227, 1),
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
                        : const Color.fromRGBO(214, 175, 227, 1),
                  ),
                ),
              ),
            ),
          ),

        Space(1.h),
        /* Container(
          margin: EdgeInsets.symmetric(horizontal: 7.w),
          width: double.infinity,
          height: 75,
          decoration: GlobalVariables().ContainerDecoration(
              offset: const Offset(3, 6),
              blurRadius: 20,
              shadowColor: const Color.fromRGBO(179, 108, 179, 0.5),
              boxColor: const Color.fromRGBO(123, 53, 141, 1),
              cornerRadius: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Column(
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
                    color: const Color.fromRGBO(84, 166, 193, 1),
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    )),
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
              )
            ],
          ),
        ),*/
        Space(2.h),
      ],
    )*/

/*: HorizontalList(
                spacing: 25,
                padding: const EdgeInsets.symmetric(horizontal: 44),
                itemCount: widget.productList.length,
                itemBuilder: (context, index) {
                  print("list:: ${widget.productList.length}");
                  return Container(
                    width: 90,
                    margin: EdgeInsets.symmetric(
                      vertical: 1.h,
                    ),
                    child: Column(
                      children: [
                        TouchableOpacity(
                          onTap: () {},
                          child: widget.productList[index].images!.isNotEmpty ? Container(
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
                              child:widget.productList[index].images!.isNotEmpty ? Image.network(
                                widget.productList[index].images?.first ?? "",
                                fit: BoxFit.cover,
                                loadingBuilder: GlobalVariables().loadingBuilderForImage,
                                */ /*errorBuilder: (context, _,stackTrace) {
                                  return Image.asset(Assets.noProduct);
                                },*/ /*
                              ) : Image.asset(Assets.noProduct,fit: BoxFit.cover,height: 50,),
                            ),
                          ): Image.asset(Assets.noProduct,fit: BoxFit.cover,height: 50,),
                        ),
                        const Space(8),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 20,
                                  ),
                                  Space(isHorizontal: true, 10),
                                  Text(
                                    '0',
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
                              const Space(8),
                               Text(
                                widget.productList[index].name ?? "",
                                maxLines: null,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
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
                }),*/
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
