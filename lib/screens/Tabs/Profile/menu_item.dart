// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/home.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/inventory.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MenuItem extends StatefulWidget {
  MenuItem({super.key, required this.data});

  dynamic data;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller =
        TextEditingController(text: widget.data['description']);
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 55.w,
                  child: Text(
                    widget.data['name'],
                    // 'jshfj sbdjs n dhsgdjh h h h h g f f h h nsdeghujsdnsb  jugug ',
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
                        fontSize: 10,
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
                          fontSize: 10,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (newValue) async {
                        print(newValue);
                        await updateProductDetails(
                            widget.data['_id'], '', newValue);
                        setState(() {
                          widget.data['description'] = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  height: 11.h,
                  width: 24.w,
                  decoration: ShapeDecoration(
                    shadows: [
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
                        cornerRadius: 15,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: (widget.data['images'] as List<dynamic>).length != 0
                      ? ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 1,
                          ),
                          child: Image.network(
                            widget.data['images'][0],
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                ),
                Positioned(
                    right: 0,
                    top: 2.h,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: ShapeDecoration(
                        color:
                            widget.data['VEG'] ? Color(0xFF4CF910) : Colors.red,
                        shape: OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: Color(0x7FB1D9D8),
                            blurRadius: 6,
                            offset: Offset(-2, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                    )),
                Positioned(
                  bottom: 2,
                  left: 2.5.h,
                  child: TouchableOpacity(
                    onTap: () async {
                      // ignore: use_build_context_synchronously
                      final url =
                          await updateProductImageSheet(context, widget.data);
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
                    Text(
                      'Scan your menu',
                      style: TextStyle(
                        color: const Color(0xFF094B60),
                        fontSize: 26,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                        height: 0.03,
                        letterSpacing: 0.78,
                      ),
                    ),
                    Space(4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TouchableOpacity(
                          onTap: () async {
                            AppWideLoadingBanner().loadingBanner(context);

                            final temp = await updateProductImage(
                                data['_id'], context, 'Gallery');
                            // Navigator.of(context).pop();

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            if (temp != null && temp != '') {
                              url = temp;
                            }
                            print(url);
                          },
                          child:
                              StocksMayBeNeedWidget(txt: 'Upload from gallery'),
                        ),
                        TouchableOpacity(
                            onTap: () async {
                              AppWideLoadingBanner().loadingBanner(context);
                              final temp = await updateProductImage(
                                  data['_id'], context, 'Camera');
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              if (temp != null && temp != '') {
                                url = temp;
                              }
                              print(url);
                            },
                            child: StocksMayBeNeedWidget(txt: 'Click photo')),
                        Space(isHorizontal: true, 5.w),
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
