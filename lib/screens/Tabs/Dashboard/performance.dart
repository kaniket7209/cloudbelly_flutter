import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/rating_widget.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Performance extends StatefulWidget {
  const Performance({super.key});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Space(2.h),
        const Text(
          'Manage your menu',
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 20,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            height: 0.05,
            letterSpacing: 0.60,
          ),
        ),
        Space(2.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Make_Update_ListWidget(
              onTap: () {
                AppWideBottomSheet().showSheet(
                    context,
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Space(1.h),
                          const Text(
                            '  Scan your menu',
                            style: TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 26,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600,
                              height: 0.03,
                              letterSpacing: 0.78,
                            ),
                          ),
                          Space(3.h),
                          TouchableOpacity(
                            onTap: () async {
                              AppWideLoadingBanner().loadingBanner(context);
                              dynamic data = await Provider.of<Auth>(context,
                                      listen: false)
                                  .ScanMenu('Gallery');
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              if (data == 'file size very large') {
                                TOastNotification().showErrorToast(
                                    context, 'file size very large');
                              } else if (data != 'No image picked' &&
                                  data != '') {
                                ScannedMenuBottomSheet(
                                    context, data['data'], true);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.photo_album_outlined),
                                  Space(isHorizontal: true, 15),
                                  Text(
                                    'Upload from gallery',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 0.10,
                                      letterSpacing: 0.36,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          TouchableOpacity(
                            onTap: () async {
                              AppWideLoadingBanner().loadingBanner(context);
                              dynamic data = await Provider.of<Auth>(context,
                                      listen: false)
                                  .ScanMenu('Camera');
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              print(data);
                              if (data == 'file size very large') {
                                TOastNotification().showErrorToast(
                                    context, 'file size very large');
                              } else if (data != 'No image picked' &&
                                  data != '') {
                                ScannedMenuBottomSheet(
                                    context, data['data'], true);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.camera),
                                  Space(isHorizontal: true, 15),
                                  Text(
                                    'Click photo',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 0.10,
                                      letterSpacing: 0.36,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    25.h);
              },
              txt: 'Add products',
            ),
            Make_Update_ListWidget(
              onTap: () async {
                final data =
                    await Provider.of<Auth>(context, listen: false).getMenu();
                print(data);
                // Sc
                ScannedMenuBottomSheet(context, data, false);
              },
              txt: 'Edit product',
            )
          ],
        ),
        Space(4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BoldTextWidgetHomeScreen(
              txt: 'Top selling items',
            ),
            SeeAllWidget(),
          ],
        ),
        Space(1.h),
        TopSellingItemWidget(
          title: 'Chicken tandoori',
          text: 'Last week (Dec23-31)',
          tail: '176 units sold already',
        ),
        TopSellingItemWidget(
          title: 'Chicken tandoori',
          text: 'Last week (Dec23-31)',
          tail: '176 units sold already',
        ),
        TopSellingItemWidget(
          title: 'Chicken tandoori',
          text: 'Last week (Dec23-31)',
          tail: '176 units sold already',
        ),
        Space(2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BoldTextWidgetHomeScreen(
              txt: 'Your favourite customers',
            ),
            SeeAllWidget(),
          ],
        ),
        Space(1.h),
        TopSellingItemWidget(
          title: 'Pinki Yadav',
          text: 'Fav dish - Kaju paneer',
          tail: '16 times ordered!',
        ),
        TopSellingItemWidget(
          title: 'Pinki Yadav',
          text: 'Fav dish - Kaju paneer',
          tail: '16 times ordered!',
        ),
        TopSellingItemWidget(
          title: 'Pinki Yadav',
          text: 'Fav dish - Kaju paneer',
          tail: '16 times ordered!',
        ),
        Space(2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BoldTextWidgetHomeScreen(
              txt: 'Highest rated items',
            ),
            SeeAllWidget(),
          ],
        ),
        Space(1.h),
        TopSellingItemWidget(
          title: 'Chicken tandoori',
          text: 'Last week (Dec23-31)',
          tail: '',
        ),
        TopSellingItemWidget(
          title: 'Chicken tandoori',
          text: 'Last week (Dec23-31)',
          tail: '',
        ),
        TopSellingItemWidget(
          title: 'Chicken tandoori',
          text: 'Last week (Dec23-31)',
          tail: '',
        ),
      ],
    );
  }

  Future<dynamic> ScannedMenuBottomSheet(
      BuildContext context, dynamic data, bool isUpload) {
    // bool isEditing = false;/
    // TextEditingController textEditingController = TextEditingController();
    // String text = 'Click me to edit';

    List<Map<String, dynamic>> list = [];

    for (var item in data) {
      var newItem = Map<String, dynamic>.from(item);
      newItem['VEG'] = true; // Adding VEG element with value true
      list.add(newItem);

      list.reversed;
    }
    var uniqueCategories = data.map((e) => e['category']).toSet();

    // Counting the number of unique categories
    var numberOfCategories = uniqueCategories.length;

    return showModalBottomSheet(
      // useSafeArea: true,
      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
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
                      Space(1.h),
                      if (isUpload)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TouchableOpacity(
                              onTap: () {
                                setState(() {
                                  list.insert(0, {
                                    'category': 'Category',
                                    'name': 'Item',
                                    'price': '00.00',
                                    'VEG': true
                                  });
                                });
                              },
                              child: Container(
                                  height: 4.h,
                                  width: 30.w,
                                  decoration: const ShapeDecoration(
                                    color: Color.fromRGBO(177, 217, 216, 1),
                                    shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius.all(
                                        SmoothRadius(
                                            cornerRadius: 15,
                                            cornerSmoothing: 1),
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Add more  +  ',
                                      style: TextStyle(
                                        color: Color(0xFF094B60),
                                        fontSize: 12,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 0.14,
                                        letterSpacing: 0.36,
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        ),
                      Space(2.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isUpload ? 'Scan complete' : 'Edit your menu',
                            style: const TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 30,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600,
                              height: 0.02,
                              letterSpacing: 0.90,
                            ),
                          ),
                          const Text(
                            'Powered by BellyAI',
                            style: TextStyle(
                              color: Color(0xFFFA6E00),
                              fontSize: 13,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 0.15,
                            ),
                          )
                        ],
                      ),
                      if (isUpload) Space(5.h),
                      if (isUpload)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'Categories Scanned',
                              style: TextStyle(
                                color: Color(0xFF1E6F6D),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w400,
                                height: 0.10,
                                letterSpacing: 0.42,
                              ),
                            ),
                            Text(
                              numberOfCategories.toString(),
                              style: const TextStyle(
                                color: Color(0xFFFA6E00),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w700,
                                height: 0.10,
                                letterSpacing: 0.42,
                              ),
                            ),
                            const Text(
                              'Products Scanned',
                              style: TextStyle(
                                color: Color(0xFF1E6F6D),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w400,
                                height: 0.10,
                                letterSpacing: 0.42,
                              ),
                            ),
                            Text(
                              (data as List<dynamic>).length.toString(),
                              style: const TextStyle(
                                color: Color(0xFFFA6E00),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w700,
                                height: 0.10,
                                letterSpacing: 0.42,
                              ),
                            )
                          ],
                        ),
                      Space(3.h),
                      const Divider(
                        color: Color(0xFFFA6E00),
                      ),
                      Space(1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SheetLabelWidget(
                            txt: 'Product',
                            width: 25.w,
                          ),
                          SheetLabelWidget(
                            txt: 'Price',
                            width: 22.w,
                          ),
                          SheetLabelWidget(
                            txt: 'V/N',
                            width: 15.w,
                          ),
                          Space(
                            5.w,
                            isHorizontal: true,
                          ),
                          SheetLabelWidget(
                            txt: 'Category',
                            width: 20.w,
                          ),
                        ],
                      ),
                      Space(1.h),
                      const Divider(
                        color: Color(0xFFFA6E00),
                      ),
                      Space(1.5.h),
                      Column(
                        children: List.generate((list as List<dynamic>).length,
                            (index) {
                          TextEditingController nameController =
                              TextEditingController(
                            text: list[index]['name'],
                          );
                          TextEditingController priceController =
                              TextEditingController(
                            text: list[index]['price'],
                          );
                          TextEditingController categoryController =
                              TextEditingController(
                            text: list[index]['category'],
                          );

                          return Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 25.w,
                                  child: TextField(
                                    maxLines: null,
                                    style: const TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 13,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (newValue) async {
                                      if (!isUpload) {
                                        await Provider.of<Auth>(context,
                                                listen: false)
                                            .updateMenuItem(
                                          list[index]['_id'],
                                          list[index]['price'],
                                          newValue,
                                          list[index]['VEG'],
                                          list[index]['category'],
                                        );
                                      }
                                      setState(() {
                                        list[index]['name'] = newValue;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Rs ',
                                        style: TextStyle(
                                          color: Color(0xFF094B60),
                                          fontSize: 13,
                                          fontFamily: 'Product Sans',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15.w,
                                        child: TextField(
                                          style: const TextStyle(
                                            color: Color(0xFF094B60),
                                            fontSize: 13,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w400,
                                          ),
                                          controller: priceController,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (newValue) async {
                                            if (!isUpload) {
                                              await Provider.of<Auth>(context,
                                                      listen: false)
                                                  .updateMenuItem(
                                                list[index]['_id'],
                                                newValue,
                                                list[index]['name'],
                                                list[index]['VEG'],
                                                list[index]['category'],
                                              );
                                            }
                                            setState(() {
                                              list[index]['price'] = newValue;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                  child: Transform.scale(
                                    scale: 0.9,
                                    child: CupertinoSwitch(
                                      value: !list[index]['VEG'],
                                      onChanged: (value) async {
                                        if (!isUpload) {
                                          await Provider.of<Auth>(context,
                                                  listen: false)
                                              .updateMenuItem(
                                            list[index]['_id'],
                                            list[index]['price'],
                                            list[index]['name'],
                                            !value,
                                            list[index]['category'],
                                          );
                                        }
                                        setState(() {
                                          list[index]['VEG'] = !value;
                                        });
                                      },
                                      activeColor:
                                          const Color.fromRGBO(232, 89, 89, 1),
                                      trackColor:
                                          const Color.fromRGBO(77, 171, 75, 1),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 20.w,
                                  child: TextField(
                                    maxLines: null,
                                    style: const TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 13,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    controller: categoryController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (newValue) async {
                                      if (!isUpload) {
                                        await Provider.of<Auth>(context,
                                                listen: false)
                                            .updateMenuItem(
                                                list[index]['_id'],
                                                list[index]['price'],
                                                list[index]['name'],
                                                list[index]['VEG'],
                                                newValue);
                                      }
                                      setState(() {
                                        list[index]['category'] = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      Space(1.h),
                      if (isUpload)
                        AppWideButton(
                          onTap: () async {
                            print(list);
                            AppWideLoadingBanner().loadingBanner(context);
                            final code =
                                await Provider.of<Auth>(context, listen: false)
                                    .AddProductsForMenu(list);
                            Navigator.of(context).pop();

                            if (code == '200') {
                              TOastNotification().showSuccesToast(
                                  context, 'Menu Uploaded successfully');
                              Navigator.of(context).pop();
                            } else {
                              TOastNotification().showErrorToast(context,
                                  'Error happened while uploading menu');
                            }
                          },
                          num: 1,
                          txt: 'Complete menu upload',
                        ),
                      Space(2.h),
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

class TopSellingItemWidget extends StatelessWidget {
  String title;
  String text;
  String tail;

  TopSellingItemWidget({
    super.key,
    required this.title,
    required this.text,
    required this.tail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      margin: EdgeInsets.only(bottom: 2.h),
      height: 7.h,
      width: double.infinity,
      decoration: GlobalVariables().ContainerDecoration(
        offset: Offset(0, 4),
        blurRadius: 15,
        boxColor: Colors.white,
        cornerRadius: 15,
        shadowColor: Color.fromRGBO(177, 202, 202, 0.6),
      ),
      child: Row(
        children: [
          Container(
            decoration: GlobalVariables().ContainerDecoration(
              offset: Offset(0, 4),
              blurRadius: 20,
              boxColor: Colors.white,
              cornerRadius: 10,
              shadowColor: Color.fromRGBO(124, 193, 191, 0.3),
            ),
            height: 35,
            width: 35,
            child: ClipRRect(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 8,
                cornerSmoothing: 1,
              ),
              child: Image.network(
                text.contains('Fav')
                    ? 'https://images.pexels.com/photos/1162983/pexels-photo-1162983.jpeg?auto=compress&cs=tinysrgb&w=600'
                    : 'https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                fit: BoxFit.cover,
                loadingBuilder: GlobalVariables().loadingBuilderForImage,
                errorBuilder: GlobalVariables().ErrorBuilderForImage,
              ),
            ),
          ),
          Space(isHorizontal: true, 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF0A4C61),
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w400,
                  // height: 0.05,
                  letterSpacing: 0.14,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  color: Color(0xFFFA6E00),
                  fontSize: 10,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w400,
                  // height: 0.10,
                  letterSpacing: 0.10,
                ),
              )
            ],
          ),
          Spacer(),
          if (tail != '')
            Container(
              height: 3.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              // width: double.infinity,
              decoration: GlobalVariables().ContainerDecoration(
                offset: Offset(0, 4),
                blurRadius: 15,
                boxColor: Color.fromRGBO(223, 244, 248, 1),
                cornerRadius: 15,
                shadowColor: Colors.white,
              ),
              child: Center(
                child: Text(
                  tail,
                  style: TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 10,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                    letterSpacing: 0.10,
                  ),
                ),
              ),
            )
          else
            RatingIcons(rating: 3),
        ],
      ),
    );
  }
}
