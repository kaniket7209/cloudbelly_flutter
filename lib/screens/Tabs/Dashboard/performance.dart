// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/coupon_action.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/inventory_bottom_sheet.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/rating_widget.dart';
import 'package:cloudbelly_app/screens/Tabs/coupon_screen.dart';
import 'package:cloudbelly_app/widgets/appwide_bottom_sheet.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Performance extends StatefulWidget {
  const Performance({super.key});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  List<Map<String, dynamic>> coupons = []; // State to hold the list of coupons
  bool darkMode = false;
 @override
  void dispose() {
    // bool _isLoading = false;
    // TODO: implement dispose
    super.dispose();
    getDarkModeStatus();
  }

  @override
  void initState() {
    // print('counter: $counter ');
    // TODO: implement initState
    super.initState();
    getDarkModeStatus();
  }

  Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });

    return prefs.getString('dark_mode');
  }

  Future<void> _fetchAndShowCoupons() async {
    // Fetch the coupons
    final fetchedCoupons = await _fetchCoupons(context);

    // Update the state with the fetched coupons
    setState(() {
      coupons = fetchedCoupons;
    });

    // Show the coupons in a modal bottom sheet
    _showCouponsModal(context, coupons, (updatedCoupons) {
      setState(() {
        coupons = updatedCoupons; // Update the list after deletion
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
           Center(
          child: Text(
            "Manage your coupons",
            style: TextStyle(
              color:darkMode?Colors.white:Color.fromRGBO(10, 76, 97, 1),
              fontSize: 20,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
              height: 0,
              letterSpacing: 0.14,
            ),
          ),
        ),
        const Space(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              GestureDetector(
                onTap: () async {
                  // Fetch the updated list of coupons after any modification
                  await _fetchAndShowCoupons();
                },
                child: Container(
                  height: 5.h,
                  width: 30.w,
                  decoration: ShapeDecoration(
                    shadows: const [
                      BoxShadow(
                        offset: Offset(5, 6),
                        color: Color.fromRGBO(72, 138, 136, 0.5),
                        blurRadius: 20,
                      )
                    ],
                    color: Color(0xff0A4C61),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'All Coupons',
                      style: const TextStyle(
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
             const Space(
              25,
              isHorizontal: true,
            ),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewCouponScreen()),
                  );
                },
                child: Container(
                  height: 5.h,
                  width: 30.w,
                  decoration: ShapeDecoration(
                    shadows: const [
                      BoxShadow(
                        offset: Offset(5, 6),
                        color: Color.fromRGBO(72, 138, 136, 0.5),
                        blurRadius: 20,
                      )
                    ],
                    color: Color(0xff0A4C61),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'New Coupon',
                      style: const TextStyle(
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
          Space(3.h),
           Text(
            'Sample data',
            style: TextStyle(
              color:darkMode?Colors.white: Color(0xFF094B60),
              fontSize: 20,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
              height: 0.05,
              letterSpacing: 0.60,
            ),
          ),
          Space(2.5.h),
          Space(1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               BoldTextWidgetHomeScreen(
                txt: 'Top selling items',
                darkMode: darkMode,
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
               BoldTextWidgetHomeScreen(
                txt: 'Your favourite customers',
darkMode: darkMode,
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
               BoldTextWidgetHomeScreen(
                txt: 'Highest rated items',
                darkMode: darkMode,
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
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCoupons(BuildContext context) async {
    final response =
        await Provider.of<Auth>(context, listen: false).getCouponsByUserId();

    if (response['code'] == 200) {
      return List<Map<String, dynamic>>.from(response['coupons']);
    } else if (response['code'] == 400 &&
        response['msg'] == 'No coupons found') {
      return [];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load coupons.')),
      );
      return [];
    }
  }

void _showCouponsModal(
    BuildContext context,
    List<Map<String, dynamic>> coupons,
    Function(List<Map<String, dynamic>>) onCouponsChanged) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // Enable full-screen modal for better pull-down gesture
    isDismissible: true, // Make the bottom sheet dismissible by dragging down
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9, // Initial height of the sheet when opened (50% of the screen height)
        minChildSize: 0.5,  // Minimum height the sheet can be dragged down to (50% of the screen)
        maxChildSize: 0.9, // Maximum height the sheet can expand to (90% of the screen)
        expand: false, // Prevent the sheet from expanding to full height automatically
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x7FB1D9D8),
                  blurRadius: 6,
                  offset: Offset(0, -4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Wrap(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'All Coupons',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0A4C61),
                          ),
                        ),
                        SizedBox(height: 20), // Space between title and first item
                        if (coupons.isNotEmpty)
                          ...coupons.map<Widget>((coupon) {
                            return CouponCard(
                              coupon: coupon,
                              onDelete: () {
                                coupons.remove(coupon); // Remove the coupon from the list
                                onCouponsChanged(coupons); // Update parent state
                                setState(() {});
                              },
                            );
                          }).toList(),
                        if (coupons.isEmpty)
                          Center(
                            child: Text(
                              'No coupons found.',
                              style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  color: Color(0xff0A4C61).withOpacity(0.5),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  
  Widget buildCouponPreviewCard(
      BuildContext context, Map<String, dynamic> coupon) {
    final String discountValue = coupon['discount_value'];
    final String minCartValue = coupon['min_cart_value'];
    final String couponCode = coupon['coupon_code'];
    bool isActive =
        coupon['is_active'] ?? false; // Assuming there is an 'is_active' field

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Provider.of<Auth>(context, listen: false)
                    .deleteCoupon(coupon['_id']);
                if (result['code'] == 200) {
                  // Success: show a success message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Coupon deleted successfully."),
                  ));
                } else {
                  // Error: show an error message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to delete coupon: ${result['msg']}"),
                  ));
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: ShapeDecoration(
                    color: Color(0xffFA6E00),
                    shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 9, cornerSmoothing: 1)),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0xffFA6E00).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            SizedBox(
              width: 2.w,
            ),
            GestureDetector(
              onTap: () async {
                // Toggle Active/Inactive state
                bool newStatus = !isActive;
                final updData = {
                  'is_active': newStatus
                }; // The field you want to update
                final result = await Provider.of<Auth>(context, listen: false)
                    .updateCoupon(coupon['_id'], updData);

                if (result['code'] == 200) {
                  // Success: show success message and update UI if necessary
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Coupon ${newStatus ? 'activated' : 'deactivated'} successfully."),
                  ));
                } else {
                  // Error: show error message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to update coupon: ${result['msg']}"),
                  ));
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: ShapeDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 9, cornerSmoothing: 1)),
                    ),
                    shadows: [
                      BoxShadow(
                        color: isActive
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(isActive ? "Active" : "Inactive",
                      style: TextStyle(color: Colors.white))),
            ),
            SizedBox(
              width: 8.w,
            )
          ],
        ),
        Container(
          padding: EdgeInsets.all(25),
          margin: EdgeInsets.only(bottom: 20),
          decoration: ShapeDecoration(
            shadows: [
              BoxShadow(
                color: Color(0xffD3EEEE),
                blurRadius: 30,
                offset: Offset(5, 6),
                spreadRadius: 0,
              ),
            ],
            color: Color(0xffD3EEEE),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 50,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buttons Row

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs $discountValue OFF',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Product Sans Black',
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0A4C61),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'On all orders with a minimum order value of Rs $minCartValue',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff0A4C61),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                color: Color(0xff0A4C61).withOpacity(0.45),
                                blurRadius: 30,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                            color: Color(0xff0A4C61),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 13,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Coupon: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Product Sans',
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                couponCode,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Product Sans',
                                  color: Color(0xffA3DBDB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          color: Color(0xff0A4C61).withOpacity(0.15),
                          blurRadius: 20,
                          offset: Offset(5, 6),
                          spreadRadius: 0,
                        ),
                      ],
                      color: Color(0xff519896),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 30,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/Coupon.png', // Replace with your asset path
                        width: 50,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Visible on your store. Can be availed by all customers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// class _PerformanceState extends State<Performance> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [

//         Space(3.h),

//         Space(2.h),
//         const Text(
//           'Sample data',
//           style: TextStyle(
//             color: Color(0xFF094B60),
//             fontSize: 20,
//             fontFamily: 'Jost',
//             fontWeight: FontWeight.w600,
//             height: 0.05,
//             letterSpacing: 0.60,
//           ),
//         ),
//         Space(2.5.h),

//         Space(1.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const BoldTextWidgetHomeScreen(
//               txt: 'Top selling items',
//             ),
//             SeeAllWidget(),
//           ],
//         ),
//         Space(1.h),
//         TopSellingItemWidget(
//           title: 'Chicken tandoori',
//           text: 'Last week (Dec23-31)',
//           tail: '176 units sold already',
//         ),
//         TopSellingItemWidget(
//           title: 'Chicken tandoori',
//           text: 'Last week (Dec23-31)',
//           tail: '176 units sold already',
//         ),
//         TopSellingItemWidget(
//           title: 'Chicken tandoori',
//           text: 'Last week (Dec23-31)',
//           tail: '176 units sold already',
//         ),
//         Space(2.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const BoldTextWidgetHomeScreen(
//               txt: 'Your favourite customers',
//             ),
//             SeeAllWidget(),
//           ],
//         ),
//         Space(1.h),
//         TopSellingItemWidget(
//           title: 'Pinki Yadav',
//           text: 'Fav dish - Kaju paneer',
//           tail: '16 times ordered!',
//         ),
//         TopSellingItemWidget(
//           title: 'Pinki Yadav',
//           text: 'Fav dish - Kaju paneer',
//           tail: '16 times ordered!',
//         ),
//         TopSellingItemWidget(
//           title: 'Pinki Yadav',
//           text: 'Fav dish - Kaju paneer',
//           tail: '16 times ordered!',
//         ),
//         Space(2.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const BoldTextWidgetHomeScreen(
//               txt: 'Highest rated items',
//             ),
//             SeeAllWidget(),
//           ],
//         ),
//         Space(1.h),
//         TopSellingItemWidget(
//           title: 'Chicken tandoori',
//           text: 'Last week (Dec23-31)',
//           tail: '',
//         ),
//         TopSellingItemWidget(
//           title: 'Chicken tandoori',
//           text: 'Last week (Dec23-31)',
//           tail: '',
//         ),
//         TopSellingItemWidget(
//           title: 'Chicken tandoori',
//           text: 'Last week (Dec23-31)',
//           tail: '',
//         ),
//       ],
//     );
//   }

// }

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
