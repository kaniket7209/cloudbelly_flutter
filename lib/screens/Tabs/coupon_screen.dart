import 'dart:convert';

import 'package:cloudbelly_app/api_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NewCouponScreen extends StatefulWidget {
  @override
  _NewCouponScreenState createState() => _NewCouponScreenState();
}

class _NewCouponScreenState extends State<NewCouponScreen> {
  String selectedCouponType = 'Fixed amount discount';
  String selectedApplicableFor = 'All customers';
  String discountValue = '';
  String minCartValue = '';
  String couponCode = '';
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
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
        title: Text(
          'New Coupon',
          style: TextStyle(
            color: Color(0xff0A4C61),
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildSectionTitle('Coupon information'),
              SizedBox(height: 10),
              _buildDropdownField(
                'Coupon type',
                selectedCouponType,
                [
                  'Fixed amount discount',
                  
                  'Free delivery coupon',
                ],
                // [
                //   'Fixed amount discount',
                //   'Percentage discount',
                //   'Free delivery coupon',
                // ],
                (value) {
                  setState(() {
                    selectedCouponType = value;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildTextField(
                'Discount value',
                (value) {
                  setState(() {
                    discountValue = value;
                  });
                },
              ),
              SizedBox(height: 30),
              _buildSectionTitle('Coupon access'),
              SizedBox(height: 10),
              _buildTextField(
                'Min cart value (optional)',
                (value) {
                  setState(() {
                    minCartValue = value;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildDropdownField(
                'Applicable for',
                selectedApplicableFor,
                [
                  'All customers',
                  'Repeat customers only',
                  'New customers only'
                  
                ],
                //  [
                //   'All customers',
                //   'Repeat customers only',
                //   'New customers only',
                //   'Customers with abandoned cart',
                //   'Customers who have followed your store',
                // ],
                (value) {
                  setState(() {
                    selectedApplicableFor = value;
                  });
                },
              ),
              SizedBox(height: 30),
              _buildSectionTitle('Coupon code'),
              SizedBox(height: 10),
              _buildTextField(
                'Coupon Code',
                (value) {
                  setState(() {
                    couponCode = value;
                  });
                },
              ),
              SizedBox(height: 30),
              Center(
                  child: Container(
                child: Text(
                  'COUPON PREVIEW',
                  style: TextStyle(
                      color: Color(0xff519896),
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontSize: 15),
                ),
              )),
              SizedBox(height: 10),
              _buildCouponPreview(),
              SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final responseData =
                        await Provider.of<Auth>(context, listen: false)
                            .createNewCoupons(
                                selectedCouponType,
                                discountValue,
                                minCartValue,
                                selectedApplicableFor,
                                couponCode);
                    // Define the API endpoint
                    try {
                      if (responseData['code'] == 200) {
                        // Success: Coupon created
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Coupon created successfully!'),
                          backgroundColor: Colors.green,
                        ));
                        // Add a delay of 2 seconds before closing the modal
                        await Future.delayed(Duration(seconds: 2));

                        Navigator.pop(context);
                      } else {
                        // Handle error from API
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              responseData['msg'] ?? 'Error creating coupon'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    } catch (e) {
                      // Handle network or other errors
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('An error occurred: $e'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child:
                   Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Color(0xffFA6E00),
                      shape: const SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius.all(
                            SmoothRadius(cornerRadius: 15, cornerSmoothing: 1)),
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
                      'Save coupon',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xff0A4C61),
      ),
    );
  }

  Widget _buildDropdownField(
    String title,
    String selectedValue,
    List<String> options,
    Function(String) onSelected,
  ) {
    return GestureDetector(
      onTap: () {
        _showDropdown(context, title, options, onSelected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: const SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
                SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
          ),
          shadows: [
            BoxShadow(
              color: Color(0xffA5C8C7).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValue,
                style: TextStyle(
                    color: Color(0xff519896).withOpacity(0.8),
                    fontFamily: 'Product Sans',
                    fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Color(0xff519896)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, Function(String) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
        ),
        shadows: [
          BoxShadow(
            color: Color(0xffA5C8C7).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: Color(0xff519896)),
        cursorColor: Color(0xff519896),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Color(0xff519896).withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _buildCouponPreview() {
    return 
    Container(
      padding: EdgeInsets.all(25),
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
        )),
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
                        // color: Colors.red,
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
                            '$couponCode',
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
            //  decoration: ShapeDecoration(
            //       shadows: [
            //         BoxShadow(
            //           color: Color(0xffD3EEEE),
            //           blurRadius: 30,
            //           offset: Offset(5, 6),
            //           spreadRadius: 0,
            //         ),
            //       ],
            //       color: Color(0xffD3EEEE).withOpacity(0.59),
            //       // color: Colors.red,
            //       shape: SmoothRectangleBorder(
            //         borderRadius: SmoothBorderRadius(
            //           cornerRadius: 30,
            //           cornerSmoothing: 1,
            //         ),
            //       ),
            //     ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     Switch(
                //       value: isActive,
                //       onChanged: (value) {
                //         setState(() {
                //           isActive = value;
                //         });
                //       },
                //       activeColor: Colors.teal,
                //     ),
                //     SizedBox(width: 5),
                //     Text(
                //       'Active',
                //       style: TextStyle(
                //         fontSize: 16,
                //         color: Colors.teal[600],
                //       ),
                //     ),
                //   ],
                // ),

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
    );
  
  }

  void _showDropdown(BuildContext context, String title, List<String> options,
      Function(String) onSelected) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          decoration: const ShapeDecoration(
            shadows: [
              BoxShadow(
                color: Color(0x7FB1D9D8),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.only(
                topLeft: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
                topRight: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 1,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.bold,
                    color: Color(0xff519896),
                  ),
                ),
                SizedBox(height: 20),
                ...options.map((option) {
                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.8,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xff519896),
                      ),
                    ),
                    onTap: () {
                      onSelected(option);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
