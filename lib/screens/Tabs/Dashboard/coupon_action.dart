import 'package:cloudbelly_app/api_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class CouponCard extends StatefulWidget {
  final Map<String, dynamic> coupon;
  final VoidCallback onDelete; // Callback for deletion

  CouponCard({required this.coupon, required this.onDelete});

  @override
  _CouponCardState createState() => _CouponCardState();
}

class _CouponCardState extends State<CouponCard> {
  late bool isActive;
  bool isLoading = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    isActive = widget.coupon['is_active'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final String discountValue = widget.coupon['discount_value'];
    final String minCartValue = widget.coupon['min_cart_value'];
    final String couponCode = widget.coupon['coupon_code'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  isDeleting = true;
                });
                final result = await Provider.of<Auth>(context, listen: false)
                    .deleteCoupon(widget.coupon['_id']);
                setState(() {
                  isDeleting = false;
                });
                if (result['code'] == 200) {
                  // Success: show a success message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Coupon deleted successfully."),
                  ));
                  widget.onDelete(); // Call the callback to remove the card
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
                child: isDeleting
                    ? SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            SizedBox(
              width: 2.w,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true; // Show loader in active/inactive button
                });
                // Toggle Active/Inactive state
                bool newStatus = !isActive;
                final updData = {
                  'is_active': newStatus
                }; // The field you want to update
                final result = await Provider.of<Auth>(context, listen: false)
                    .updateCoupon(widget.coupon['_id'], updData);

                setState(() {
                  isLoading = false; // Hide loader after API response
                  if (result['code'] == 200) {
                    // Update the local state to reflect the new status
                    isActive = newStatus;
                  }
                });

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
                child: isLoading
                    ? SizedBox(
                        width: 20.0, // Set the desired width
                        height: 20.0, // Set the desired height
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isActive ? "Active" : "Inactive",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
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