import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../api_service.dart';
import '../../models/supplier_bulk_order.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/space.dart';
import '../../widgets/touchableOpacity.dart';
import 'components/components.dart';

class BulkOrderSheet extends StatefulWidget {
  final List<SupplierBulkOrder> bulkOrders;

  const BulkOrderSheet({super.key, required this.bulkOrders});

  @override
  State<BulkOrderSheet> createState() => _BulkOrderSheetState();
}

class _BulkOrderSheetState extends State<BulkOrderSheet> {
  late bool _showDeliveryRoute = false;

  late String googleMapDummyImage =
      'https://th.bing.com/th/id/OIP.BkaMPU9wX3ZUndILIVi3hgHaIQ?rs=1&pid=ImgDetMain';
  late List<Map<String, dynamic>> bulkOrderItemsDummyData = [
    {
      'itemName': 'Tomato',
      'volume': '181',
      'imageUrl':
          'https://media.istockphoto.com/id/1450576005/photo/tomato-isolated-tomato-on-white-background-perfect-retouched-tomatoe-side-view-with-clipping.jpg?s=612x612&w=0&k=20&c=lkQa_rpaKpc-ELRRGobYVJH-eMJ0ew9BckCqavkSTA0='
    },
    {
      'itemName': 'Red Cabbage',
      'volume': '62',
      'imageUrl':
          'https://media.istockphoto.com/id/175433477/photo/red-cabbage-leaves.jpg?s=612x612&w=0&k=20&c=CVC-6nTaKtQ0Gw5l8Nk5aGb8oA47Ce6eba2qSYYauq0='
    },
    {
      'itemName': 'Potato',
      'volume': '105',
      'imageUrl':
          'https://dukaan.b-cdn.net/700x700/webp/upload_file_service/asg/7e813d1d-0eac-456f-ba82-4a6b81efa130/Potato.png'
    },
    {
      'itemName': 'Green Cabbage',
      'volume': '35',
      'imageUrl':
          'https://www.shutterstock.com/image-photo/cabbage-isolated-on-white-background-600nw-1556699831.jpg'
    },
    {
      'itemName': 'Karela',
      'volume': '120',
      'imageUrl':
          'https://lazyshoppy.com/cdn/shop/products/Bitter_melon_4f3277d7-4f06-4908-9768-b8baa2e78bfb.png?v=1643607808'
    },
    {
      'itemName': 'Brocolli',
      'volume': '50',
      'imageUrl':
          'https://cdn.pixabay.com/photo/2016/06/11/15/33/broccoli-1450274_640.png'
    },
    {
      'itemName': 'Carut',
      'volume': '120',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrMKkDu9OSVJelgM1bSu08TvVJvp_ZtfBIdefBjqCRnA&s'
    },
  ];
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 2.h),
      padding: EdgeInsets.only(
        top: 2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(
              cornerRadius: 35,
              cornerSmoothing: 1,
            ),
            topRight: SmoothRadius(
              cornerRadius: 35,
              cornerSmoothing: 1,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TouchableOpacity(
              onTap: () {
                context.read<TransitionEffect>().setBlurSigma(0);
                return Navigator.of(context).pop();
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 1.h,
                    horizontal: 3.w,
                  ),
                  width: 65,
                  height: 6,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            !_showDeliveryRoute ? _bulkOrderItemSheet() : _deliveryRoute()
          ],
        ),
      ),
    );
  }

  Widget _bulkOrderItemSheet() {
    return Column(
      children: [
        Space(1.h),
        GestureDetector(
          onTap: () {
            print('Im tapped');
            setState(() {
              _showDeliveryRoute = true;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            // crossAxisAlignment: CrossAxisAlignment,// Set mainAxisSize to min
            children: [
              const Text(
                'Delivery route',
                style: TextStyle(
                  color: Color(0xFF094B60),
                  fontSize: 12,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  // height: 0.14,
                  letterSpacing: 0.36,
                ),
              ),
              Space(isHorizontal: true, 2.w),
              Icon(
                Icons.double_arrow_outlined,
                size: 16,
                color: Color(0xFFFA6E00),
              ),
            ],
          ),
        ),
        Space(1.h),
        Row(
          children: [
            Space(
              1.h,
              isHorizontal: true,
            ),
            Text(
              'New Bulk Order',
              style: const TextStyle(
                color: Color(0xFF094B60),
                fontSize: 25,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w500,
                // height: 0.06,
                letterSpacing: 0.54,
              ),
            ),
          ],
        ),
        Container(
          height: 350,
          child: Scrollbar(
            interactive: true,
            thumbVisibility: true,
            // Set to true to always show scrollbar
            controller: _controller,
            // Pass the controller
            child: ListView.builder(
              controller: _controller,
              // Pass the controller to the ListView as well
              itemCount: widget.bulkOrders.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    index == 0 ? Space(2.h) : SizedBox(),
                    BulkOrderSectionItem(
                        itemDetails:widget.bulkOrders[index] ,),
                    index == 0 ? Space(2.h) : SizedBox(),
                    index > 0 ? Space(2.h) : SizedBox(),
                  ],
                );
              },
            ),
          ),
        ),
        Space(2.h),
        Center(
            child: Container(
          height: 45,
          margin: EdgeInsets.symmetric(horizontal: 1.h),
          decoration: ShapeDecoration(
            shadows: [
              BoxShadow(
                  offset: Offset(5, 6),
                  spreadRadius: 0.1,
                  color: Color.fromRGBO(232, 128, 55, 0.5),
                  blurRadius: 10)
            ],
            color: const Color.fromRGBO(250, 110, 0, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Center(
              child: Text(
            'Submit your bid',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              height: 0,
              letterSpacing: 0.30,
            ),
          )),
        )),
        Space(1.h)
      ],
    );
  }

  Widget _deliveryRoute() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Space(2.h),
        Stack(children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                googleMapDummyImage,
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 2.h,
            left: 2.h,
            child: CustomIconButton(
              // color: Colors.white,
              // boxColor: Color.fromRGBO(250, 110, 0, 1),
              text: 'back',
              ic: Icons.arrow_back_ios_new_outlined,
              onTap: () {
                setState(() {
                  _showDeliveryRoute = false;
                });
              },
            ),
          )
        ]),
        Space(2.h),
        Text(
          'DELIVERY LOCATION',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontFamily: 'Product Sans',
              color: Color.fromRGBO(10, 76, 97, 1)),
        ),
        Space(2.h),
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Color.fromRGBO(250, 110, 0, 1),
              size: 28,
            ),
            Space(
              1.h,
              isHorizontal: true,
            ),
            Text(
              'Hotel Gardenia',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Jost',
                  color: Color.fromRGBO(10, 76, 97, 1)),
            ),
          ],
        ),
        Space(0.5.h),
        Text(
            '23rd Main Rd, Hosapalya, Bangalore, Karnataka , 560102, India (Colive Garden)',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Product Sans',
                color: Color.fromRGBO(10, 76, 97, 1))),
        Space(2.h),
        Container(
          padding: EdgeInsets.only(left: 20, top: 20),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Color.fromRGBO(243, 246, 240, 1),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35), topRight: Radius.circular(35))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Items needed',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Jost',
                    color: Color.fromRGBO(10, 76, 97, 1)),
              ),
              Space(2.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BulkOrderItem(
                    //   itemData: {
                    //     'itemName': 'Green Cabbage',
                    //     'volume': '120',
                    //     'imageUrl':
                    //         'https://www.shutterstock.com/image-photo/cabbage-isolated-on-white-background-600nw-1556699831.jpg'
                    //   },
                    // ),
                    // Space(
                    //   2.h,
                    //   isHorizontal: true,
                    // ),
                    // BulkOrderItem(
                    //   itemData: {
                    //     'itemName': 'Tomato',
                    //     'volume': '120',
                    //     'imageUrl':
                    //         'https://media.istockphoto.com/id/1450576005/photo/tomato-isolated-tomato-on-white-background-perfect-retouched-tomatoe-side-view-with-clipping.jpg?s=612x612&w=0&k=20&c=lkQa_rpaKpc-ELRRGobYVJH-eMJ0ew9BckCqavkSTA0='
                    //   },
                    // ),
                    // Space(
                    //   2.h,
                    //   isHorizontal: true,
                    // ),
                    // BulkOrderItem(
                    //   itemData: {
                    //     'itemName': 'Red Cabbage',
                    //     'volume': '120',
                    //     'imageUrl':
                    //         'https://media.istockphoto.com/id/175433477/photo/red-cabbage-leaves.jpg?s=612x612&w=0&k=20&c=CVC-6nTaKtQ0Gw5l8Nk5aGb8oA47Ce6eba2qSYYauq0='
                    //   },
                    // ),
                    // Space(
                    //   2.h,
                    //   isHorizontal: true,
                    // ),
                    // BulkOrderItem(
                    //   itemData: {
                    //     'itemName': 'Potato',
                    //     'volume': '120',
                    //     'imageUrl':
                    //         'https://dukaan.b-cdn.net/700x700/webp/upload_file_service/asg/7e813d1d-0eac-456f-ba82-4a6b81efa130/Potato.png'
                    //   },
                    // ),
                    // Space(
                    //   2.h,
                    //   isHorizontal: true,
                    // ),
                    // BulkOrderItem(
                    //   itemData: {
                    //     'itemName': 'Green Cabbage',
                    //     'volume': '120',
                    //     'imageUrl':
                    //         'https://www.shutterstock.com/image-photo/cabbage-isolated-on-white-background-600nw-1556699831.jpg'
                    //   },
                    // ),
                    // Space(
                    //   2.h,
                    //   isHorizontal: true,
                    // ),
                    // BulkOrderItem(
                    //   itemData: {
                    //     'itemName': 'Tomato',
                    //     'volume': '120',
                    //     'imageUrl':
                    //         'https://media.istockphoto.com/id/1450576005/photo/tomato-isolated-tomato-on-white-background-perfect-retouched-tomatoe-side-view-with-clipping.jpg?s=612x612&w=0&k=20&c=lkQa_rpaKpc-ELRRGobYVJH-eMJ0ew9BckCqavkSTA0='
                    //   },
                    // ),
                    // Space(
                    //   2.h,
                    //   isHorizontal: true,
                    // ),
                    // BulkOrderItem(
                    //   itemData: {
                    //     'itemName': 'Red Cabbage',
                    //     'volume': '120',
                    //     'imageUrl':
                    //         'https://media.istockphoto.com/id/175433477/photo/red-cabbage-leaves.jpg?s=612x612&w=0&k=20&c=CVC-6nTaKtQ0Gw5l8Nk5aGb8oA47Ce6eba2qSYYauq0='
                    //   },
                    // ),
                    // Space(
                    //   2.h,
                    //   isHorizontal: true,
                    // ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
