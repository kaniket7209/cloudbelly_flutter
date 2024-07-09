// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MenuItem extends StatefulWidget {
  MenuItem({super.key, required this.data, required this.scroll});
  var scroll;
  dynamic data;

  @override
  State<MenuItem> createState() => _MenuItemState();
}
// Function to calculate total items and total price

class _MenuItemState extends State<MenuItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Auth>(context, listen: false).clearAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller =
        TextEditingController(text: widget.data['description']);

    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 55.w,
                  child: Text(
                    widget.data['name'],
                    style: TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 16,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              
                Text('Rs  ${widget.data['price']}',
                    style: const TextStyle(
                      color: Color(0xFFFA6E00),
                      fontSize: 14,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                    )),
                if (widget.data['description'] == '') Space(1.h),
                if (Provider.of<Auth>(context, listen: false)
                        .userData?['user_id'] ==
                    widget.data['user_id'])
                  Container(
                    width: 55.w,
                    decoration: widget.data['description'] == ''
                        ? ShapeDecoration(
                            color: const Color.fromRGBO(239, 255, 254, 1),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 1,
                              ),
                            ),
                          )
                        : null,
                    child: Center(
                      child: TextField(
                        maxLines: null,
                        style: const TextStyle(
                          color: Color(0xFF094B60),
                          fontSize: 12,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                        ),
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: widget.data['description'] == ''
                              ? '                         Add description'
                              : '',
                          hintStyle: const TextStyle(
                            color: Color(0xFF094B60),
                            fontSize: 12,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (newValue) async {
                          print(newValue);
                          await Provider.of<Auth>(context, listen: false)
                              .updateProductDetails(
                                  widget.data['_id'], '', newValue);
                          setState(() {
                            widget.data['description'] = newValue;
                          });
                        },
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      widget.data['description'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 12,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 1.4.h),
                  height: 11.h,
                  width: 24.w,
                  decoration: ShapeDecoration(
                    shadows: const [
                      BoxShadow(
                        color: Color(0x7FB1D9D8),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                    color: const Color.fromRGBO(239, 255, 254, 1),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 24,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: (widget.data['images'] as List<dynamic>).isNotEmpty
                      ? ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 24,
                            cornerSmoothing: 1,
                          ),
                          child: Image.network(
                            widget.data['images'][0],
                            fit: BoxFit.cover,
                            loadingBuilder:
                                GlobalVariables().loadingBuilderForImage,
                            errorBuilder:
                                GlobalVariables().ErrorBuilderForImage,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0.5.w,
                  top: 1.5.h,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: ShapeDecoration(
                      color: widget.data['type'] == 'Veg'
                          ? Color(0xFF4CF910)
                          : Colors.red,
                      shape: OvalBorder(),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x7FB1D9D8),
                          blurRadius: 6,
                          offset: Offset(-2, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: (Provider.of<Auth>(context)
                          .itemAdd
                          .where(
                            (element) => element.id == widget.data["_id"],
                          )
                          .isEmpty)
                      ? 2.5.h
                      : 0.h,
                  child: (Provider.of<Auth>(context)
                          .itemAdd
                          .where(
                            (element) => element.id == widget.data["_id"],
                          )
                          .isEmpty)
                      ? TouchableOpacity(
                          onTap: () async {
                            print("widget.data ${widget.data}");
                            print(Provider.of<Auth>(context, listen: false)
                                .userData?['user_id']);
                            if (Provider.of<Auth>(context, listen: false)
                                    .userData?['user_id'] !=
                                widget.data['user_id']) {
                              Provider.of<Auth>(context, listen: false)
                                  .bannerTogger(
                                      ProductDetails.fromJson(widget.data));
                              return;
                            }
                            print(widget.data);
                            // ignore: use_build_context_synchronously
                            final url = await updateProductImageSheet(
                                context, widget.data);
                            print("url: $url");
                            if (url != '') {
                              setState(() {
                                widget.data['images'] = [url];
                                print(url);
                              });
                            }
                          },
                          child: ButtonWidgetHomeScreen(
                              radius: 4,
                              isActive: true,
                              height: 2.5.h,
                              width: 15.w,
                              txt: 'ADD'),
                        )
                      : Container(
                          width: 24.w,
                          // padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Provider.of<Auth>(context, listen: false)
                                      .removeItem(
                                          ProductDetails.fromJson(widget.data));
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
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
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 1.0,
                                        letterSpacing: 0.14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 30,
                                decoration: ShapeDecoration(
                                  color: const Color(0xff0A4C61),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 12,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    Provider.of<Auth>(context)
                                        .itemAdd
                                        .lastWhere(
                                          (element) =>
                                              element.id == widget.data["_id"],
                                        )
                                        .quantity
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                      letterSpacing: 0.14,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (widget.scroll != null) {
                                    print("scrolling");
                                    // Handle scroll action if needed
                                  }
                                  Provider.of<Auth>(context, listen: false)
                                      .addItem(
                                          ProductDetails.fromJson(widget.data));
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
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
                                      '+',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 1.0,
                                        letterSpacing: 0.14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            )
          ],
        ));
  
  }

  Future<String> updateProductImageSheet(
      BuildContext context, dynamic data) async {
    String url = '';
    await showModalBottomSheet(
      // useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
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
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              padding: EdgeInsets.only(
                  left: 10.w, right: 10.w, top: 2.h, bottom: 2.h),
              child: SingleChildScrollView(
                child: Column(
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
                          height: 9,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFA6E00),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                    Space(6.h),
                    const Text(
                      'Upload product Photo',
                      style: TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 26,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                        height: 0.03,
                        letterSpacing: 0.78,
                      ),
                    ),
                    Space(4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TouchableOpacity(
                            onTap: () async {
                              AppWideLoadingBanner().loadingBanner(context);
                              final temp = await Provider.of<Auth>(context,
                                      listen: false)
                                  .updateProductImage(
                                      data['_id'], context, 'Camera');
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              if (temp != null && temp != '') {
                                url = temp;
                              }
                              print(url);
                            },
                            child: StocksMayBeNeedWidget(
                                txt: 'Click photo',
                                icon: 'assets/images/Camera.png')),
                       
                        TouchableOpacity(
                          onTap: () async {
                            AppWideLoadingBanner().loadingBanner(context);

                            final temp =
                                await Provider.of<Auth>(context, listen: false)
                                    .updateProductImage(
                                        data['_id'], context, 'Gallery');
                            // Navigator.of(context).pop();

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            if (temp != null && temp != '') {
                              url = temp;
                            }
                            print(url);
                          },
                          child: StocksMayBeNeedWidget(
                              txt: 'Upload photo',
                              icon: 'assets/images/gallery.png'),
                        ),
                        
                        TouchableOpacity(
                            onTap: () async {
                              AppWideLoadingBanner().loadingBanner(context);
                              final temp = await Provider.of<Auth>(context,
                                      listen: false)
                                  .updateProductImageusingAI(data['_id'],
                                      data['description'], context);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              if (temp != null && temp != '') {
                                url = temp;
                              }
                              print(url);
                            },
                            child: StocksMayBeNeedWidget(
                              txt: 'Let AI do it!',
                              icon: 'assets/images/Bot.png',
                            )),
                        // Space(isHorizontal: true, 5.w),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return url;
  }
}
