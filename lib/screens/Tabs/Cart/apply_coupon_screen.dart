import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:figma_squircle/figma_squircle.dart';

class ApplyCouponScreen extends StatefulWidget {
  @override
  _ApplyCouponScreenState createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  List<Map<String, dynamic>> coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  // Fetching Coupons using the seller's ID
  Future<void> _fetchCoupons() async {
    try {
      var sellerId =
          Provider.of<ViewCartProvider>(context, listen: false).SellterId;
      final fetchedCoupons = await Provider.of<Auth>(context, listen: false)
          .getCustomersCoupons(sellerId);

      if (fetchedCoupons['code'] == 200 && fetchedCoupons['coupons'] != null) {
        setState(() {
          coupons = List<Map<String, dynamic>>.from(fetchedCoupons['coupons']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFEF7FE),
      body: Column(
        children: [
          _buildTopCouponEntry(),
          // Custom Header

          // Top Coupon Entry Section

          SizedBox(height: 20),

          // Coupons List Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Great deals you are missing out on!",
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2E0536),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (coupons.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: coupons.length,
                              itemBuilder: (context, index) {
                                final coupon = coupons[index];
                                return _buildCouponCard(context, coupon);
                              },
                            )
                          else
                            Center(
                              child: Text(
                                'No coupons found.',
                                style: TextStyle(
                                    fontFamily: 'Product Sans',
                                    color: Color(0xff2E0536).withOpacity(0.5),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCouponEntry() {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.only(
              bottomLeft: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
              bottomRight: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0xffBC73BC).withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/back_double_arrow.png', // Replace with your actual asset path
                        color: Color(0xffFA6E00),
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        child: Text(
                          'Apply Coupon',
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2E0536),
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Text(
                        'Your cart: Rs 165', // Dynamic value can be fetched from cart provider
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff2E0536),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                      SmoothRadius(cornerRadius: 15, cornerSmoothing: 1),
                    ),
                    side: BorderSide(
                      color: Color(
                          0xffCBC0CD), // Light border color for the outline
                      width: 1, // Border width
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 2), // Adjust padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        cursorColor: Color(0xff2E0536),
                        decoration: InputDecoration(
                          hintText: "Enter Coupon Code",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 16,
                            color: Color(0xff2E0536),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle apply coupon code logic
                      },
                      child: Text(
                        "APPLY",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xffFA6E00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, Map<String, dynamic> coupon) {
    final String couponCode = coupon['coupon_code'];
    final String discountValue = coupon['discount_value'];
    final String minCartValue = coupon['min_cart_value'] ?? "0";

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discount badge
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Color(0xffFA6E00),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                "$discountValue% OFF",
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 20),
            // Coupon details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    couponCode,
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Save Rs $minCartValue on this order',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Use code $couponCode & get upto $discountValue% off on orders above Rs $minCartValue. Max discount: Rs 50',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Apply button
            TextButton(
              onPressed: () {
                // Apply the coupon
              },
              child: Text(
                "APPLY",
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontSize: 16,
                  color: Color(0xffFA6E00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
