
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/supplier_bulk_order.dart';
import 'package:cloudbelly_app/screens/supplier/components/constants.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/graphs.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory_bottom_sheet.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/make_list_inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class BulkOrderSectionItem extends StatefulWidget {
  final SupplierBulkOrder itemDetails;

  const BulkOrderSectionItem({super.key, required this.itemDetails});

  @override
  State<BulkOrderSectionItem> createState() => _BulkOrderSectionItemState();
}

class _BulkOrderSectionItemState extends State<BulkOrderSectionItem> {
  late bool _setPrice = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Space(
              1.h,
              isHorizontal: true,
            ),
            Container(
                padding: EdgeInsets.all(1),
                decoration: ShapeDecoration(
                  shadows: const [
                    BoxShadow(
                      offset: Offset(0, 8),
                      color: Color.fromRGBO(162, 210, 167, 0.6),
                      // rgba
                      blurRadius: 25,
                    )
                  ],
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 15,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: ImageWidgetInventory(
                  height: 40,
                  radius: 10,
                  url: widget.itemDetails.imageUrl,
                )),
            Space(
              2.h,
              isHorizontal: true,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemDetails.nameId,
                  style: const TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w600,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                ),
                Text(
                  '${widget.itemDetails.quantity} ${widget.itemDetails.unitType}',
                  style: const TextStyle(
                    color: const Color.fromRGBO(250, 110, 0, 1),
                    // background: rgba(250, 110, 0, 1);
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w600,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )
              ],
            )
          ],
        ),
        _setPrice
            ? TextField(
          onChanged: (var val){
            widget.itemDetails.price=int.parse(val);
          },
          keyboardType: TextInputType.number,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            constraints: BoxConstraints(minHeight: 40, minWidth: 10.h, maxHeight: 50, maxWidth: 15.h),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF094B60)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),  // Adjusted padding
            suffixText: '/-',
            // prefixIcon: Icon(
            //   Icons.currency_rupee,
            //   size: 18,
            // ),
            prefixStyle: TextStyle(
              color: Color(0xFF094B60)
            ),
            prefixText: 'Rs-',
            prefixIconColor: Color(0xFF094B60),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF094B60)),
            ),
          ),
        )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _setPrice = true;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: ShapeDecoration(
                        shadows: const [
                          BoxShadow(
                            offset: Offset(0, 8),
                            color: Color.fromRGBO(162, 210, 167, 0.6),
                            // rgba
                            blurRadius: 25,
                          )
                        ],
                        color: Colors.white,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 5,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Add Price',
                            style: const TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 12,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              // height: 0.06,
                              letterSpacing: 0.54,
                            ),
                          ),
                          Space(1.h),
                          const Icon(
                            Icons.add,
                            size: 16,
                            color: Color(0xFFFA6E00),
                          ),
                        ],
                      ),
                    ),
                    Space(
                      2.h,
                      isHorizontal: true,
                    )
                  ],
                ),
              ),
      ],
    );
  }
}

class ImageWidgetInventory extends StatelessWidget {
  double height;
  String url;
  double radius;

  ImageWidgetInventory({
    super.key,
    required this.height,
    required this.url,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    String newUrl = '';
    if (url != '') {
      String originalLink = url;
      String fileId = originalLink.substring(
          originalLink.indexOf('/d/') + 3, originalLink.indexOf('/view'));
      newUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    print(newUrl);
    return Container(
      height: height,
      width: height,
      decoration: ShapeDecoration(
        shadows: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(124, 193, 191, 0.3),
            blurRadius: 20,
          )
        ],
        color: const Color.fromRGBO(200, 233, 233, 1),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: radius,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: url != ''
          ? ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: radius,
                cornerSmoothing: 1,
              ),
              child: Image(
                fit: BoxFit.cover,
                image: NetworkImage(newUrl),
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  print(error.toString());
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error loading image'),
                  );
                },
              ),
            )
          : null,
    );
  }
}

class StocksNearExpiryWidget extends StatelessWidget {
  String name;
  String volume;
  String url;

  StocksNearExpiryWidget({
    super.key,
    required this.name,
    required this.volume,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 120,
      width: 90,
      decoration: ShapeDecoration(
        shadows: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(124, 193, 191, 0.3),
            blurRadius: 15 + 5,
          )
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 10,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        const Space(3),
        ImageWidgetInventory(height: 75, url: url, radius: 15),
        const Space(5),
        Text(
          name,
          maxLines: 2,
          style: const TextStyle(
            color: Color(0xFF0A4C61),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0,
            letterSpacing: 0.12,
          ),
        ),
        Text(
          volume,
          style: const TextStyle(
            color: Color(0xFFFA6E00),
            fontSize: 9,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w400,
            height: 0,
            letterSpacing: 0.09,
          ),
        )
      ]),
    );
  }
}

class LowStocksWidget extends StatelessWidget {
  double percentage;
  String text;
  String amountLeft;
  String item;
  bool isSheet;
  String url;

  // String url;
  LowStocksWidget({
    super.key,
    required this.amountLeft,
    required this.text,
    required this.percentage,
    required this.item,
    this.isSheet = false,
    required this.url,
    // required this.url,
  });

  @override
  Widget build(BuildContext context) {
    double widhth = !isSheet ? 50.w : 40.w;
    Color color = percentage < 0.1
        ? const Color.fromRGBO(245, 75, 75, 1)
        : percentage < 0.2
            ? const Color.fromRGBO(250, 110, 0, 1)
            : percentage < 0.3
                ? const Color.fromARGB(255, 237, 172, 123)
                : const Color(0xFF8EE239);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      width: double.infinity,
      height: 7.h,
      decoration: ShapeDecoration(
        shadows: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Color.fromRGBO(177, 202, 202, 0.6),
            blurRadius: 15,
          )
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 10,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Space(isHorizontal: true, 3.w),
          ImageWidgetInventory(height: 35, url: url, radius: 10),
          Space(isHorizontal: true, 11),
          SizedBox(
            width: 20.w,
            child: Text(
              item,
              style: const TextStyle(
                color: Color(0xFF0A4C61),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w600,
                // height: 0.05,
                letterSpacing: 0.14,
              ),
            ),
          ),
          Space(isHorizontal: true, 17),
          Stack(
            children: [
              Container(
                height: 20,
                decoration: ShapeDecoration(
                  shadows: const [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(124, 193, 191, 0.3),
                      blurRadius: 20,
                    )
                  ],
                  color: const Color.fromRGBO(223, 244, 248, 1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                width: widhth,
              ),
              Container(
                height: 20,
                decoration: ShapeDecoration(
                  shadows: const [
                    BoxShadow(
                      offset: Offset(0, 4),
                      color: Color.fromRGBO(124, 193, 191, 0.3),
                      blurRadius: 20,
                    )
                  ],
                  color: text == 'Expired' ? Colors.red : color,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                width: percentage < 0.1
                    ? widhth * percentage + 7.w
                    : percentage < 0.2
                        ? widhth * percentage + 5.w
                        : widhth * percentage,
              ),
              Positioned(
                  left: 10,
                  top: 5,
                  child: Text(
                    amountLeft,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w500,
                      height: 0,
                      letterSpacing: 0.08,
                    ),
                  )),
              Positioned(
                  right: 10,
                  top: 5,
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 8,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      height: 0,
                      letterSpacing: 0.08,
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class StocksMayBeNeedWidget extends StatelessWidget {
  String url;
  String txt;

  StocksMayBeNeedWidget({super.key, this.txt = 'chicken', this.url = ''});

  @override
  Widget build(BuildContext context) {
    String newUrl = '';
    if (url != '') {
      String originalLink = url;
      String fileId = originalLink.substring(
          originalLink.indexOf('/d/') + 3, originalLink.indexOf('/view'));
      newUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: ShapeDecoration(
              shadows: const [
                BoxShadow(
                  offset: Offset(0, 4),
                  color: Color.fromRGBO(124, 193, 191, 0.3),
                  blurRadius: 20,
                )
              ],
              color: const Color.fromRGBO(200, 233, 233, 1),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 10,
                  cornerSmoothing: 1,
                ),
              ),
            ),
            child: url != ''
                ? ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                    child: Image(
                      fit: BoxFit.cover,
                      image: NetworkImage(newUrl),
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Error loading image'),
                        );
                      },
                    ),
                  )
                : null,
          ),
          Space(1.h),
          Text(
            txt,
            style: const TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 11,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              height: 0,
              letterSpacing: 0.11,
            ),
          )
        ],
      ),
    );
  }
}

class SeeAllWidget extends StatelessWidget {
  const SeeAllWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'See all',
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w700,
            height: 0.14,
            letterSpacing: 0.36,
          ),
        ),
        Space(isHorizontal: true, 2.w),
        const Icon(
          Icons.arrow_forward_ios,
          size: 13,
          color: Color(0xFFFA6E00),
        ),
      ],
    );
  }
}

class Supplier_Make_Update_ListWidget extends StatelessWidget {
  String txt;
  final Function? onTap;

  Supplier_Make_Update_ListWidget({
    super.key,
    required this.txt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Container(
          height: 5.h,
          width: 30.w,
          decoration: ShapeDecoration(
            shadows: const [
              BoxShadow(
                offset: Offset(3, 6),
                color: Color.fromRGBO(77, 191, 74, 1),
                // rgba(77, 191, 74, 1)
                blurRadius: 20,
              )
            ],
            color: const Color.fromRGBO(77, 191, 74, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              txt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                height: 0,
                letterSpacing: 0.14,
              ),
            ),
          )),
    );
  }
}

//endregion

//region Supplier profile banner
class SupplierBanner extends StatefulWidget {
  // const SupplierBanner({super.key});
  double height;

  SupplierBanner({super.key, this.height = 300});

  @override
  State<SupplierBanner> createState() => _SupplierBannerState();
}

class _SupplierBannerState extends State<SupplierBanner>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800, // Set the maximum width to 800
        ),
        child: Provider.of<Auth>(context, listen: true).cover_image == ''
            ? Container(
                width: 100.w,
                height: widget.height == 300 ? 30.h : widget.height,
                decoration: ShapeDecoration(
                  color: Color.fromRGBO(163, 220, 118, 1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        bottomLeft:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                        bottomRight:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1)),
                  ),
                ))
            : Container(
                width: 100.w,
                height: widget.height == 300 ? 30.h : widget.height,
                decoration: ShapeDecoration(
                  color: Color(0xFFB1D9D8),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        bottomLeft:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                        bottomRight:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1)),
                  ),
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius.only(
                      bottomLeft:
                          SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                      bottomRight:
                          SmoothRadius(cornerRadius: 40, cornerSmoothing: 1)),
                  child: Image.network(
                    Provider.of<Auth>(context, listen: true).cover_image,
                    fit: BoxFit.cover,
                    loadingBuilder: GlobalVariables().loadingBuilderForImage,
                    errorBuilder: GlobalVariables().ErrorBuilderForImage,
                  ),
                ),
              ),
      ),
    );
  }
}

//endregion

//region Bulk Order Item widget
class BulkOrderItem extends StatelessWidget {
  final SupplierBulkOrder itemDetails;

  const BulkOrderItem({super.key, required this.itemDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(1),
          decoration: ShapeDecoration(
            shadows: const [
              BoxShadow(
                offset: Offset(0, 8),
                color: Color.fromRGBO(162, 210, 167, 0.6),
                // rgba
                blurRadius: 25,
              )
            ],
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 15,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: ImageWidgetInventory(
            height: 40,
            radius: 10,
            url: itemDetails.imageUrl,
          ),
        ),
        Space(1.h),
        Text(
          itemDetails.nameId.replaceAll(' ', '\n'),
          style: const TextStyle(
            color: Color(0xFF094B60),
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w600,
            // height: 0.06,
            letterSpacing: 0.54,
          ),
        ),
        Text(
          '${itemDetails.quantity} ${itemDetails.unitType}',
          style: const TextStyle(
            color: const Color.fromRGBO(250, 110, 0, 1),
            // background: rgba(250, 110, 0, 1);
            fontSize: 12,
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.w600,
            // height: 0.06,
            letterSpacing: 0.54,
          ),
        )
      ],
    );
  }
}
//
