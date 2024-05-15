import 'dart:convert';
import 'dart:ui';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/delivery_address.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_item.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

AddressModel? addressModel = AddressModel();

class ViewCart extends StatefulWidget {
  static const routeName = '/view-cart';

  ViewCart({
    super.key,
  });

  @override
  State<ViewCart> createState() => _ViewCartState();
}

class _ViewCartState extends State<ViewCart> {
  bool _isAddressExpnaded = false;
  ScrollController _scrollController = ScrollController();
  bool _showContainer = false;
  bool _scrollingDown = false;
  DeliveryAddressModel? addressList;
  double totalAmount = 0.0;
  Map<String, dynamic> response = {};
  String? orderId;
  List<Map<String, dynamic>> convertedList = [];
  final Razorpay _razorpay = Razorpay();
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Scrolling down
      setState(() {
        _showContainer = true;
        _scrollingDown = true;
      });
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Scrolling up
      setState(() {
        _scrollingDown = false;
      });
      // To hide the container after some scrolling up, you can add a condition here
      // For example, if you want to hide it after scrolling up by 100 pixels
      if (_scrollController.offset <= 100) {
        setState(() {
          _showContainer = false;
        });
      }
    }
  }

  void getAddressDetails() async {
    AppWideLoadingBanner().loadingBanner(context);

    addressList = await Provider.of<Auth>(context, listen: false)
        .getAddressList()
        .then((value) {
      print("details:: ${jsonEncode(value)}");
      Navigator.of(context).pop();
      context.read<TransitionEffect>().setBlurSigma(5.0);
      AddressBottomSheet()
          .DelievryAddressSheet(context, value.deliveryAddresses);
      return null;
    });
    print("list:: ${jsonEncode(addressList)}");

    setState(() {});
  }

  void createProductOrder() async {
    if (context.read<ViewCartProvider>().addressModel == null) {
      TOastNotification().showErrorToast(context, "Please Select Address");
    } else {
      AppWideLoadingBanner().loadingBanner(context);
      response = await Provider.of<Auth>(context, listen: false)
          .createProductOrder(
              convertedList, context.read<ViewCartProvider>().addressModel);
      Navigator.pop(context);
      if (response['message'] == 'Order processed successfully') {
        orderId = response['order_id'];
        TOastNotification().showSuccesToast(context, response['message']);
        openCheckout();
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PostItem()));
      } else {
        TOastNotification().showErrorToast(context, response['message']);
      }
      setState(() {});
    }
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': 100,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
    };
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    _razorpay.open(options);
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    print("successResponse:: ${response.data.toString()}");
    submitOrder();
  }

  void submitOrder() async {
    print("hdjnvd");
    AppWideLoadingBanner().loadingBanner(context);
    dynamic response = await Provider.of<Auth>(context, listen: false)
        .submitOrder(orderId, "Cash");
    Navigator.pop(context);
    if (response['message'] == "Order submitted successfully") {
      TOastNotification().showSuccesToast(context, response['message']);
    }
  }

  void updateTotalPrice(ProductDetails product) {
    final double price = double.tryParse(product.price ?? "0.0") ?? 0.0;

    // Calculate the total price
    final int totalPrice = (price * (product.quantity ?? 0)).toInt();

    // Assign the calculated total price to the product
    product.totalPrice = totalPrice.toString();

    // Print for debugging
    print("Total price: $totalPrice");

    // If this function is called inside a StatefulWidget, call setState to trigger a UI update
    setState(() {
      // Perform any necessary UI updates here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(254, 247, 254, 1),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 100.w,
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    bottomLeft:
                        SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                    bottomRight:
                        SmoothRadius(cornerRadius: 40, cornerSmoothing: 1)),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  Space(5.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TouchableOpacity(
                        onTap: () {
                          Navigator.of(context).maybePop();
                        },
                        child: const Padding(
                          padding:
                              EdgeInsets.only(right: 10, top: 10, bottom: 10),
                          child: SizedBox(
                            //width: 25,
                            child: Text(
                              '<<',
                              style: TextStyle(
                                color: Color(0xFFFA6E00),
                                fontSize: 22,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.66,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60.w,
                        child: const Text(
                          'Geeta’s Kitchen',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 16,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                  Space(0.5.h),
                  Container(
                    width: double.infinity,
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 0.50,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color(0xFF2E0536),
                        ),
                      ),
                    ),
                  ),
                  Space(1.7.h),
                  Consumer<ViewCartProvider>(
                      builder: (context, notifier, child) {
                    return notifier.addressModel?.location != null
                        ? Row(
                            // crossAxisAlignment: CrossAxisAlignment.st,
                            children: [
                              const Icon(
                                Icons.location_pin,
                                size: 35,
                                color: Color(0xFFFA6E00),
                              ),
                              Text(
                                notifier.addressModel?.type ?? "",
                                style: const TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 18,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w500,
                                  height: 0.05,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 35.w,
                                child: Text(
                                  notifier.addressModel?.location ??
                                      'Please Select Location',
                                  maxLines: _isAddressExpnaded ? 6 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF2E0536),
                                      fontSize: 14,
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              TouchableOpacity(
                                onTap: () {
                                  getAddressDetails();
                                  /* setState(() {
                            _isAddressExpnaded = !_isAddressExpnaded;
                          });*/
                                },
                                child: const Icon(
                                  /*_isAddressExpnaded
                              ? Icons.keyboard_arrow_up
                              :*/
                                  Icons.keyboard_arrow_down,
                                  size: 35,
                                  color: Color(0xFFFA6E00),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  getAddressDetails();
                                },
                                child: const Text(
                                  "Please Select Location",
                                  style: TextStyle(
                                    color: Color(0xFF1E1E1E),
                                    fontSize: 18,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w500,
                                    height: 0.05,
                                  ),
                                ),
                              ),
                              TouchableOpacity(
                                onTap: () {
                                  getAddressDetails();
                                  /* setState(() {
                            _isAddressExpnaded = !_isAddressExpnaded;
                          });*/
                                },
                                child: const Icon(
                                  /*_isAddressExpnaded
                              ? Icons.keyboard_arrow_up
                              :*/
                                  Icons.keyboard_arrow_down,
                                  size: 35,
                                  color: Color(0xFFFA6E00),
                                ),
                              ),
                            ],
                          );
                  }),
                  Space(2.h),
                ],
              ),
            ),
          ),
          Space(3.5.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: GlobalVariables().ContainerDecoration(
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                      shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
                      boxColor: Colors.white,
                      cornerRadius: 15),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ordering for somebody?',
                        style: TextStyle(
                          color: Color(0xFF2E0536),
                          fontSize: 14,
                          fontFamily: 'Product Sans Medium',
                          fontWeight: FontWeight.w500,
                          height: 0.13,
                        ),
                      ),
                      Text(
                        'Add details',
                        style: TextStyle(
                          color: Color(0xFFFA6E00),
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          height: 0.08,
                        ),
                      )
                    ],
                  ),
                ),
                const Space(32),
                Consumer<ViewCartProvider>(
                    builder: (context, notifiyer, child) {
                  return Container(
                      padding: EdgeInsets.only(
                          top: 2.5.h, left: 4.w, right: 4.w, bottom: 1.h),
                      decoration: GlobalVariables().ContainerDecoration(
                          offset: const Offset(0, 4),
                          blurRadius: 15,
                          shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
                          boxColor: Colors.white,
                          cornerRadius: 25),
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notifiyer.productList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 1.5.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin:
                                                const EdgeInsets.only(top: 2),
                                            height: 15,
                                            width: 15,
                                            decoration: ShapeDecoration(
                                              shadows: const [
                                                BoxShadow(
                                                  offset: Offset(0, 10),
                                                  color: Color.fromRGBO(
                                                      56, 56, 56, 0.15),
                                                  blurRadius: 15,
                                                ),
                                              ],
                                              gradient: const LinearGradient(
                                                begin: Alignment.bottomLeft,
                                                end: Alignment.topRight,
                                                colors: [
                                                  Color.fromRGBO(
                                                      26, 155, 15, 1),
                                                  Color.fromRGBO(36, 255, 0, 1)
                                                ],
                                              ),
                                              shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius(
                                                cornerRadius: 4,
                                                cornerSmoothing: 1,
                                              )),
                                            )),
                                        const Space(9, isHorizontal: true),
                                        Expanded(
                                          child: Text(
                                            notifiyer.productList[index].name ??
                                                "",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              color: Color(0xFF4C4C4C),
                                              fontSize: 14,
                                              fontFamily: 'Product Sans Medium',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  /*Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 15,
                      width: 15,
                      decoration: ShapeDecoration(
                        shadows: const [
                          BoxShadow(
                            offset: Offset(0, 10),
                            color: Color.fromRGBO(56, 56, 56, 0.15),
                            blurRadius: 15,
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Color.fromRGBO(26, 155, 15, 1),
                            Color.fromRGBO(36, 255, 0, 1)
                          ],
                        ),
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                          cornerRadius: 4,
                          cornerSmoothing: 1,
                        )),
                      )),
                  const Space(9, isHorizontal: true),
                  SizedBox(
                    width: 28.w,
                    child: Text(
                      widget.productDetails.name ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4C4C4C),
                        fontSize: 14,
                        fontFamily: 'Product Sans Medium',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              */ /*const Row(
                children: [
                  Space(24, isHorizontal: true),
                  Text(
                    'Customize ',
                    style: TextStyle(
                      color: Color(0xFF4C4C4C),
                      fontSize: 12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_sharp,
                    size: 27,
                    color: Color(0xFFFA6E00),
                  ),
                ],
              )*/ /*
            ],
          ),*/
                                  //  Space(1, isHorizontal: true),
                                  // Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_sharp,
                                      size: 35,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        if (notifiyer
                                                .productList[index].quantity! >
                                            1) {
                                          notifiyer.productList[index]
                                              .quantity = notifiyer
                                                  .productList[index]
                                                  .quantity! -
                                              1;
                                          updateTotalPrice(
                                              notifiyer.productList[index]);
                                          totalAmount -= double.tryParse(
                                                  notifiyer.productList[index]
                                                          .totalPrice ??
                                                      "")!
                                              .toDouble();
                                          print(totalAmount);
                                          /*for (var p in widget.productList) {
                                          subTotal -= double.tryParse(p.totalPrice ?? "")!.toDouble();
                                        }
                                       */
                                          //  calculateTotalAmount(widget.productDetails);
                                        }
                                      });
                                    },
                                    // weight: 1000,
                                    color: Color(0xFFFA6E00),
                                  ),
                                  Container(
                                    height: 33,
                                    width: 33,
                                    decoration: GlobalVariables()
                                        .ContainerDecoration(
                                            offset: const Offset(3, 6),
                                            blurRadius: 20,
                                            shadowColor: const Color.fromRGBO(
                                                158, 116, 158, 0.5),
                                            boxColor: const Color(0xFFFA6E00),
                                            cornerRadius: 8),
                                    child: Center(
                                      child: Text(
                                        '${notifiyer.productList[index].quantity}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Product Sans',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.keyboard_arrow_up_sharp,
                                      size: 35,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        if (notifiyer
                                                .productList[index].quantity! <
                                            10) {
                                          notifiyer.productList[index]
                                              .quantity = notifiyer
                                                  .productList[index]
                                                  .quantity! +
                                              1;

                                          updateTotalPrice(
                                              notifiyer.productList[index]);
                                          totalAmount += double.tryParse(
                                                  notifiyer.productList[index]
                                                          .totalPrice ??
                                                      "")!
                                              .toDouble();

                                          /*for (var p in widget.productList) {
                                          subTotal += double.tryParse(p.totalPrice ?? "")!.toDouble();
                                        }*/
                                          print(totalAmount);
                                          // calculateTotalAmount(widget.productDetails);
                                        }
                                      });
                                    },
                                    // weight: 1000,
                                    color: Color(0xFFFA6E00),
                                  ),
                                  //const Space(1, isHorizontal: true),
                                  Text(
                                    'Rs ${notifiyer.productList[index].totalPrice}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFFA6E00),
                                      fontSize: 14,
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.w600,
                                      height: 0.08,
                                    ),
                                  )
                                ],
                              ),
                            );
                          })

                      /*Column(
                    children: [
                      for (int index = 0; index < 3; index++) const MenuItemInCart(),
                    ],
                  ),*/
                      );
                }),
                Space(3.h),
                TextWidgetCart(text: 'Offers & Benefits'),
                Space(1.h),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: GlobalVariables().ContainerDecoration(
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                      shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
                      boxColor: Colors.white,
                      cornerRadius: 15),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Apply Coupon',
                        style: TextStyle(
                          color: Color(0xFF2E0536),
                          fontSize: 14,
                          fontFamily: 'Product Sans Medium',
                          fontWeight: FontWeight.w500,
                          height: 0.13,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Color(0xFFFA6E00),
                      ),
                    ],
                  ),
                ),
                const Space(33),
                TextWidgetCart(text: 'Delivery Instructions'),
                const Space(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DeliveryInstructionWidgetCart(
                      text: 'Take-Away',
                    ),
                    DeliveryInstructionWidgetCart(
                      text: 'Leave at the door',
                    ),
                    DeliveryInstructionWidgetCart(
                      text: 'Avoid Calling',
                    ),
                    DeliveryInstructionWidgetCart(
                      text: 'Leave at security',
                    ),
                  ],
                ),
                Space(4.h),
                PriceWidget(
                  totalAmount: totalAmount,
                ),
                Space(4.h),
                TextWidgetCart(
                    text:
                        'Review your order & address details to avoid cancellations'),
                Space(1.5.h),
                const policyWidgetCart(),
              ],
            ),
          ),
          Space(2.h),
          GestureDetector(
            onTap: () {
              // Handle tap on the area around the BackdropFilter
              print('Tapped outside of the modal bottom sheet');
              // You can add any logic here, such as dismissing the modal bottom sheet
              // For example:
              // Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.transparent, // Transparent color
            ),
          )
        ]),
      ),
      bottomNavigationBar: _showContainer
          ? AnimatedContainer(
              duration: const Duration(
                  milliseconds: 300), // Adjust the duration as needed
              height: 100,
              child: Container(
                padding: const EdgeInsets.only(right: 18, left: 29),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                width: double.infinity,
                height: 75,
                decoration: GlobalVariables().ContainerDecoration(
                    offset: const Offset(3, 6),
                    blurRadius: 20,
                    shadowColor: const Color.fromRGBO(179, 108, 179, 0.5),
                    boxColor: const Color.fromRGBO(123, 53, 141, 1),
                    cornerRadius: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rs $totalAmount',
                          style: const TextStyle(
                            color: Color(0xFFF7F7F7),
                            fontSize: 16,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'View Detailed Bill',
                          style: TextStyle(
                            color: Color(0xFFF7F7F7),
                            fontSize: 12,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                    TouchableOpacity(
                      onTap: () {
                        context
                            .read<ViewCartProvider>()
                            .productList
                            .forEach((element) {
                          String productId = element.id ?? "";
                          String priceEach = element.totalPrice ?? "";
                          int quantity = element.quantity ?? 0;

                          Map<String, dynamic> newItem = {
                            'product_id': productId,
                            'price_each': priceEach,
                            'quantity': quantity,
                          };

                          convertedList.add(newItem);
                        });
                        createProductOrder();
                        //openCheckout();
                        //  var provider =Provider.of<ViewCartProvider>(context, listen: false);
                      },
                      child: Container(
                        height: 41,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: ShapeDecoration(
                          color: const Color.fromRGBO(84, 166, 193, 1),
                          shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 1,
                          )),
                        ),
                        child: const Center(
                          child: Text(
                            'Proceed to payment',
                            style: TextStyle(
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
              ),
            )
          : null,
    );
  }
}

class DeliveryInstructionWidgetCart extends StatelessWidget {
  String text;

  DeliveryInstructionWidgetCart({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      width: 70,
      height: 90,
      decoration: GlobalVariables().ContainerDecoration(
          offset: const Offset(2, 5),
          blurRadius: 20,
          shadowColor: const Color.fromRGBO(158, 116, 158, 0.25),
          boxColor: Colors.white,
          cornerRadius: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        // crossAxisAlignment: cro,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4C4C4C),
              fontSize: 12,
              fontFamily: 'Product Sans Medium',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PriceWidget extends StatefulWidget {
  PriceWidget({super.key, required this.totalAmount});

  double totalAmount;

  @override
  State<PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: GlobalVariables().ContainerDecoration(
          offset: const Offset(0, 4),
          blurRadius: 15,
          shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
          boxColor: Colors.white,
          cornerRadius: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Item Total",
                style: TextStyle(
                  color: Color(0xFF2E0536),
                  fontSize: 16,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Rs ${widget.totalAmount}",
                style: const TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Space(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Fee 2.7 kms",
                style: TextStyle(
                  color: Color(0xFF2E0536),
                  fontSize: 12,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF2E0536),
                ),
              ),
              Text(
                "Rs 0",
                style: TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Space(2),
          Text(
            "Save Rs 10 on delivery fee by ordering above Rs 159",
            style: TextStyle(
              color: Color(0xFFD382E3),
              fontSize: 10,
              fontFamily: 'Product Sans Medium',
              fontWeight: FontWeight.w400,
            ),
          ),
          Space(5.5),
          Divider(
            color: Color(0xFFBB5104),
            thickness: 0.5,
          ),
          Space(14.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Tip",
                style: TextStyle(
                  color: Color(0xFF2E0536),
                  fontSize: 16,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Add tip",
                style: TextStyle(
                  color: Color(0xFFD382E3),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Space(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Govt Taxes & Other Charges",
                style: TextStyle(
                  color: Color(0xFF2E0536),
                  fontSize: 12,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF2E0536),
                ),
              ),
              Text(
                "Rs 0",
                style: TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Space(20),
          Divider(
            color: Color(0xFFBB5104),
            thickness: 0.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Rs 430",
                style: TextStyle(
                  color: Color(0xFFFA6E00),
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class policyWidgetCart extends StatelessWidget {
  const policyWidgetCart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: GlobalVariables().ContainerDecoration(
            offset: const Offset(0, 4),
            blurRadius: 15,
            shadowColor: const Color.fromRGBO(188, 115, 188, 0.2),
            boxColor: Colors.white,
            cornerRadius: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              //If you cancel within 60 seconds of placing your
              children: [
                Text(
                  'Note:',
                  style: TextStyle(
                    color: Color(0xFFFA6E00),
                    fontSize: 14,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' If you cancel within 60 seconds of placing your',
                  style: TextStyle(
                    color: Color(0xFF383838),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Text(
              'order, a 100% refund will be issued. NO refund for cancellations made after 60 seconds.',
              style: TextStyle(
                color: Color(0xFF383838),
                fontSize: 12,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            const Space(10),
            const Text(
              'Avoid cancellation as it leads to food wastage.',
              style: TextStyle(
                color: Color(0xFFB549CA),
                fontSize: 12,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
            const Space(18),
            const Text(
              'READ CANCELLATION POLICY',
              style: TextStyle(
                color: Color(0xFFFA6E00),
                fontSize: 12,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              width: 170,
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Color(0xFFFA6E00),
                  ),
                ),
              ),
            ),
            const Space(20)
          ],
        ));
  }
}

class MenuItemInCart extends StatefulWidget {
  MenuItemInCart({
    super.key,
    required this.productDetails,
  });

  late ProductDetails productDetails;

  @override
  State<MenuItemInCart> createState() => _MenuItemInCartState();
}

class _MenuItemInCartState extends State<MenuItemInCart> {
  late final int? totalAmount;

  void calculateTotalAmount(ProductDetails product) {
    setState(() {
      final int price = int.tryParse(product.totalPrice ?? "0.0") ?? 0;
      final int totalPrice = (price + (price ?? 0)).toInt();
      // totalAmount = (product.totalPrice ?? "")+ (product.totalPrice ?? "");
      print("totalAmount:: $totalPrice");
    });
  }

  void updateTotalPrice(ProductDetails product) {
    final double price = double.tryParse(product.price ?? "0.0") ?? 0.0;

    // Calculate the total price
    final int totalPrice = (price * (product.quantity ?? 0)).toInt();

    // Assign the calculated total price to the product
    product.totalPrice = totalPrice.toString();

    // Print for debugging
    print("Total price: $totalPrice");

    // If this function is called inside a StatefulWidget, call setState to trigger a UI update
    setState(() {
      // Perform any necessary UI updates here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 15,
                    width: 15,
                    decoration: ShapeDecoration(
                      shadows: const [
                        BoxShadow(
                          offset: Offset(0, 10),
                          color: Color.fromRGBO(56, 56, 56, 0.15),
                          blurRadius: 15,
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color.fromRGBO(26, 155, 15, 1),
                          Color.fromRGBO(36, 255, 0, 1)
                        ],
                      ),
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                        cornerRadius: 4,
                        cornerSmoothing: 1,
                      )),
                    )),
                const Space(9, isHorizontal: true),
                Expanded(
                  child: Text(
                    widget.productDetails.name ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF4C4C4C),
                      fontSize: 14,
                      fontFamily: 'Product Sans Medium',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 15,
                      width: 15,
                      decoration: ShapeDecoration(
                        shadows: const [
                          BoxShadow(
                            offset: Offset(0, 10),
                            color: Color.fromRGBO(56, 56, 56, 0.15),
                            blurRadius: 15,
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Color.fromRGBO(26, 155, 15, 1),
                            Color.fromRGBO(36, 255, 0, 1)
                          ],
                        ),
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                          cornerRadius: 4,
                          cornerSmoothing: 1,
                        )),
                      )),
                  const Space(9, isHorizontal: true),
                  SizedBox(
                    width: 28.w,
                    child: Text(
                      widget.productDetails.name ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4C4C4C),
                        fontSize: 14,
                        fontFamily: 'Product Sans Medium',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              */ /*const Row(
                children: [
                  Space(24, isHorizontal: true),
                  Text(
                    'Customize ',
                    style: TextStyle(
                      color: Color(0xFF4C4C4C),
                      fontSize: 12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_sharp,
                    size: 27,
                    color: Color(0xFFFA6E00),
                  ),
                ],
              )*/ /*
            ],
          ),*/
          //  Space(1, isHorizontal: true),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down_sharp,
              size: 35,
            ),

            onPressed: () {
              setState(() {
                if (widget.productDetails.quantity! > 1) {
                  widget.productDetails.quantity =
                      widget.productDetails.quantity! - 1;
                  updateTotalPrice(widget.productDetails);
                  calculateTotalAmount(widget.productDetails);
                }
              });
            },
            // weight: 1000,
            color: Color(0xFFFA6E00),
          ),
          Container(
            height: 33,
            width: 33,
            decoration: GlobalVariables().ContainerDecoration(
                offset: const Offset(3, 6),
                blurRadius: 20,
                shadowColor: const Color.fromRGBO(158, 116, 158, 0.5),
                boxColor: const Color(0xFFFA6E00),
                cornerRadius: 8),
            child: Center(
              child: Text(
                '${widget.productDetails.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_up_sharp,
              size: 35,
            ),

            onPressed: () {
              setState(() {
                if (widget.productDetails.quantity! < 10) {
                  widget.productDetails.quantity =
                      widget.productDetails.quantity! + 1;
                  updateTotalPrice(widget.productDetails);
                  calculateTotalAmount(widget.productDetails);
                }
              });
            },
            // weight: 1000,
            color: Color(0xFFFA6E00),
          ),
          //const Space(1, isHorizontal: true),
          Text(
            'Rs ${widget.productDetails.totalPrice}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFA6E00),
              fontSize: 14,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
              height: 0.08,
            ),
          )
        ],
      ),
    );
  }
}

// class DotDotLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2.0;

//     final double dotSpacing = 8.0; // Spacing between dots
//     final double dotSize = 4.0; // Diameter of each dot

//     double currentX = dotSpacing / 2;

//     while (currentX < size.width) {
//       canvas.drawCircle(Offset(currentX, size.height / 2), dotSize, paint);
//       currentX += dotSpacing;
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

class TextWidgetCart extends StatelessWidget {
  TextWidgetCart({
    super.key,
    required this.text,
  });

  String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF2E0536),
        fontSize: 18,
        fontFamily: 'Jost',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
