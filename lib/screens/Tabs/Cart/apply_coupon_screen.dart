import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:figma_squircle/figma_squircle.dart';

class ApplyCouponScreen extends StatefulWidget {
  double totalAmount;
  ApplyCouponScreen({super.key, required this.totalAmount});
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
    TextEditingController _couponCodeController = TextEditingController();
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
                        height: 2.5.h,
                      ),
                      Container(
                        child: Text(
                          'Apply Coupon',
                          style: TextStyle(
                            fontFamily: 'Product Sans Black',
                            fontWeight: FontWeight.w700,
                            color: Color(0xff2E0536),
                            fontSize: 21,
                          ),
                        ),
                      ),
                      Text(
                        'Your cart: Rs ${widget.totalAmount}', // Dynamic value can be fetched from cart provider
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
                        controller: _couponCodeController,
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
                    TextButton(
                      onPressed: () {
                        _applyCoupon(_couponCodeController
                            .text); // Apply the coupon entered in the text field
                      },
                      child: Text(
                        "APPLY",
                        style: TextStyle(
                          fontFamily: 'Product Sans Black',
                          fontSize: 14,
                          color: Color(0xffFA6E00),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
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
  final bool isActive = coupon['is_active'] ?? false;

  final double minCartValueDouble = double.tryParse(minCartValue) ?? 0.0;
  final double totalCartValue = widget.totalAmount;
  String couponMessage;
  bool added;
  if (totalCartValue >= minCartValueDouble) {
    added = true;
    couponMessage = 'Save Rs $discountValue on this order';
  } else {
    added = false;
    final double amountNeeded = minCartValueDouble - totalCartValue;
    couponMessage =
        'Add Rs ${amountNeeded.toStringAsFixed(2)} more to get a discount up to Rs $discountValue';
  }

  final Color backgroundColor =
      isActive ? Color(0xffF8D2F8) : Color(0xffE3E3E3);
  final Color discountBadgeColor =
      isActive ? Color(0xffFA6E00) : Color(0xff343434);

  return Container(
    margin: EdgeInsets.only(bottom: 20),
    decoration: ShapeDecoration(
      color: backgroundColor,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        children: [
          // Coupon Details and Discount Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vertical Discount Badge
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                decoration: ShapeDecoration(
                  color: discountBadgeColor,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                      SmoothRadius(cornerRadius: 13, cornerSmoothing: 1),
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
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    "Rs $discountValue OFF",
                    style: TextStyle(
                      fontFamily: 'Product Sans Black',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              // Coupon Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      couponCode,
                      style: TextStyle(
                        fontFamily: 'Product Sans Black',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff343434),
                      ),
                    ),
             
                    Text(
                      couponMessage,
                      style: TextStyle(
                        fontFamily: 'Product Sans',
                        fontSize: 12,
                        color: Color(0xffFA0000),
                      ),
                    ),
                    SizedBox(height: 5),
                    if(!isActive && added)...[
Divider(
                      color: Color(0xff7A128F),
                      thickness: 1,
                      height: 20,
                    ),
                    ],
                    
                    SizedBox(height: 5),
                    Text(
                      'Use code $couponCode & get upto Rs $discountValue off on orders above Rs $minCartValue. Max discount: Rs 50',
                      style: TextStyle(
                        fontFamily: 'Product Sans',
                        fontSize: 12,
                        color: Color(0xff343434),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Apply Button at the Top Right Corner
          Positioned(
            top: 0,
            right: 0,
            child: TextButton(
              onPressed: () {
                if (isActive && added) {
                  _showBottomSheet(context, couponCode, discountValue);
                }
              },
              child: Text(
                "APPLY",
                style: TextStyle(
                  fontFamily: 'Product Sans Black',
                  fontSize: 16,
                  color: isActive && added
                      ? discountBadgeColor
                      : Color(0xffA2A2A2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showBottomSheet(
      BuildContext context, String couponCode, String discountValue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '‘$couponCode’ Applied',
                    style: TextStyle(
                      fontFamily: 'Product Sans Black',
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff343434),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 30, // Ensuring the container is a square
                      height: 35,

                      decoration: ShapeDecoration(
                        color: Color(0xffFA6E00),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.all(
                            SmoothRadius(cornerRadius: 9, cornerSmoothing: 1),
                          ),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0xffFA6E00).withOpacity(0.44),
                            blurRadius: 20,
                            offset: Offset(3, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20, // Adjust icon size to fit the container
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Rs $discountValue saves with this coupon',
                style: TextStyle(
                  fontFamily: 'Product Sans Black',
                  height: 1.2,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2E0536),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Your coupon is successfully applied',
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  fontSize: 20,
                  color: Color(0xff343434),
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Color(0xffFA6E00),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 15, cornerSmoothing: 1),
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0xffFA6E00).withOpacity(0.44),
                          blurRadius: 20,
                          offset: Offset(3, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'NICE!',
                      style: TextStyle(
                          fontFamily: 'Product Sans Black',
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyCoupon(String enteredCouponCode) {
    // Check if the coupon code is empty
    if (enteredCouponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a coupon code')),
      );
      return;
    }

    try {
      // Search for the coupon in the list of fetched coupons
      final coupon = coupons.firstWhere(
        (c) =>
            c['coupon_code'].toLowerCase() == enteredCouponCode.toLowerCase(),
      );

      if (coupon != null) {
        // Validate the coupon based on cart total and coupon requirements
        double minCartValue =
            double.tryParse(coupon['min_cart_value'] ?? '0') ?? 0.0;

        // Fetch the total amount from the CartProvider
        double currentTotalAmount = context.read<CartProvider>().totalAmount;

        // Fetch the delivery fee from the ViewCartProvider
        double deliveryFee =
            context.read<ViewCartProvider>().deliveryFee ?? 0.0;

        // Combine total amount and delivery fee
        double totalAmountWithDelivery = currentTotalAmount + deliveryFee;

        // Apply the discount from the coupon
        double discountValue =
            double.tryParse(coupon['discount_value'] ?? '0') ?? 0.0;
        double newTotalAmount = totalAmountWithDelivery - discountValue;

        // Check if the total amount is greater than or equal to the minimum required for the coupon
        if (totalAmountWithDelivery >= minCartValue) {
          // Update the CartProvider with the new total
          context
              .read<CartProvider>()
              .updateProductTotal(newTotalAmount);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coupon applied successfully!')),
          );

          // Optionally show bottom sheet or any other UI to reflect applied coupon
          _showBottomSheet(
            context,
            coupon['coupon_code'],
            discountValue.toString(),
          );
        } else {
          // Show error if the cart value is less than the required minimum cart value
          double difference = minCartValue - totalAmountWithDelivery;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Add Rs ${difference.toStringAsFixed(2)} more to apply this coupon')),
          );
        }
      } else {
        // Show error if the coupon is invalid or not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid coupon code')),
        );
      }
    } catch (e) {
      // Handle any error during the search for the coupon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupon code not found or invalid')),
      );
    }
  }
}
