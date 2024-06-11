import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'dart:typed_data';
import 'dart:ui';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
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
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

String createUpiPaymentUrl(
    String upiId, String name, String amount, String transactionId) {
  return 'upi://pay?pa=$upiId&pn=$name&tn=OrderId:$transactionId&am=$amount&cu=INR';
}

void initiateUpiPayment(
    String upiId, String name, String amount, String transactionId) async {
  final upiUrl = Uri.parse(
      'upi://pay?pa=$upiId&pn=$name&tn=OrderId:$transactionId&am=$amount&cu=INR');

  if (await canLaunch(upiUrl.toString())) {
    await launch(upiUrl.toString());
  } else {
    print('Could not launch $upiUrl');
  }
}

AddressModel? addressModel = AddressModel();

class PaymentOptions extends StatefulWidget {
  final String userId;
  final String orderFromUserId;
  final String orderId;
  final double amount;
  final String sellerUpi;
  final Map<String, dynamic> prepData;

  PaymentOptions({
    required this.userId,
    required this.orderFromUserId,
    required this.orderId,
    required this.amount,
    required this.sellerUpi,
    required this.prepData,
  });

  @override
  _PaymentOptionsState createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  Uint8List? qrCode;
  XFile? paymentScreenshot;
  bool isPaymentConfirmed = false;

  @override
  void initState() {
    super.initState();
    fetchQrCode();
  }

  Future<void> fetchQrCode() async {
    print("Fetching QR code...");
    const String url = 'https://app.cloudbelly.in/order/upi';
    final payload = {
      'user_id': widget.userId,
      'order_from_user_id': widget.orderFromUserId,
      'order_id': widget.orderId,
      'amount': widget.amount.toString()
    };

    try {
      print("Sending request to $url with payload: $payload");
      final response = await http.post(Uri.parse(url),
          body: jsonEncode(payload),
          headers: {'Content-Type': 'application/json'});
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          qrCode = response.bodyBytes;
        });
        print("QR code fetched successfully");
      } else {
        print('Failed to load QR code: ${response.reasonPhrase}');
        TOastNotification().showErrorToast(
            context, 'Failed to load QR code: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching QR code: $e');
    }
  }

  Future<void> uploadPaymentScreenshot() async {
    if (paymentScreenshot == null) {
      return;
    }

    final file = File(paymentScreenshot!.path);
    final url = Uri.parse('https://app.cloudbelly.in/upload');

    final request = http.MultipartRequest('POST', url)
      ..headers['Accept'] = '*/*'
      ..headers['User-Agent'] = 'Thunder Client (https://www.thunderclient.com)'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);
      final s3BucketLink = responseData['file_url']; // Adjust according to your API response structure

      print("Payment screenshot uploaded: $s3BucketLink");

      // Call the verify payment API
      await verifyPayment(s3BucketLink);

      setState(() {
        isPaymentConfirmed = true;
      });

      TOastNotification().showSuccesToast(context, 'Payment confirmed successfully.');
    } else {
      print('Failed to upload payment screenshot');
    }
  }

  Future<void> verifyPayment(String transactionImageUrl) async {
    final url = Uri.parse('https://app.cloudbelly.in/order/verify_payment');
    final body = json.encode({
     'user_id': widget.userId,
      'order_from_user_id': widget.orderFromUserId,
      'order_id': widget.orderId,
      "amount": widget.amount.toString(),
      "transaction_image": transactionImageUrl,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('Payment verified successfully');
    } else {
      print('Failed to verify payment');
    }
  }

  Future<void> pickPaymentScreenshot() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      paymentScreenshot = image;
    });
    print("Payment screenshot selected: ${image?.name}");
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      // backgroundColor: const Color(0xFF2E0536),
      backgroundColor: Color(0xFF2E0536),
      
      
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 35,
          cornerSmoothing: 1,
        ),
      ),
      title: buildTitle(context),
      content: buildContent(context),
      actions: buildActions(context),
    );
  }

  Widget buildTitle(BuildContext context) {
    return isPaymentConfirmed
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thank you,\nYour order has\n been placed.',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Your payment is yet to be verified',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              Space(2.h),
              GestureDetector(
                onTap: () async {
                  final phoneNumber = widget.prepData['phone'];
                  final url = 'tel:$phoneNumber';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch phone call')),
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFFA6E00),
                  child: Image.asset('assets/images/Phone.png'),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: IconButton(
                      icon: Image.asset('assets/images/back_double_arrow.png'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 30),
                    child: const Text(
                      'Scan to pay',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Center(
                  child: Container(
                    width: 130,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFA6E00),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 12,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              Space(1.h)
            ],
          );
  }

  Widget buildContent(BuildContext context) {
    return isPaymentConfirmed
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add your Lottie animation asset here
              Lottie.asset('assets/Animation - 1718049075869.json',
                  width: 200, height: 150),
              // const SizedBox(height: 20),
              Space(2.h),
              Container(
                width: 55.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(84, 166, 193, 1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Add track order functionality here
                  },
                  
                  child: const Text(
                    'Track order',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Space(2.h),
              Container(
                width: 55.w,
               
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(84, 166, 193, 1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Add continue shopping functionality here
                  },
                  child: const Text(
                    'Continue shopping',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name - ${widget.prepData['store_name']}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4), // Add space between lines
                        Text(
                          'Order No - ${widget.prepData['order_no']}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0),
                    child: GestureDetector(
                      onTap: () async {
                        final phoneNumber = widget.prepData['phone'];
                        final url = 'tel:$phoneNumber';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Could not launch phone call')),
                          );
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFFA6E00),
                        child: Image.asset('assets/images/Phone.png'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (qrCode != null)
                Image.memory(
                  qrCode!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.sellerUpi,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.sellerUpi));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('UPI ID copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(250, 110, 0, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  onPressed: () => pickPaymentScreenshot(),
                  child: const Text(
                    'Upload screenshot',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (paymentScreenshot != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Screenshot selected: ${paymentScreenshot!.name}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
            ],
          );
  }

  List<Widget> buildActions(BuildContext context) {
    return !isPaymentConfirmed
        ? [
            SizedBox(
             
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(84, 166, 193, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                onPressed: () => uploadPaymentScreenshot(),
                child: const Text(
                  'Transferred, notify the seller',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  child: const Text(
                    '**Third party payment is not allowed',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Space(1.h)
          ]
        : [];
  }
}

// show payment method section
void showPaymentMethodSelection(BuildContext context, String orderFromUserId,
    orderId, String sellerUpi, Map<String, dynamic> prepData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final double screenWidth = MediaQuery.of(context).size.width;
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(46, 5, 54, 1),
        shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
          cornerRadius: 35,
          cornerSmoothing: 1,
        )),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                    icon: Image.asset('assets/images/back_double_arrow.png'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // const SizedBox(width: 20),

                const Text(
                  'Payment',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Product Sans",
                      color: Colors.white),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: Container(
                  width: 100,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    )),
                  ),
                ),
              ),
            ),
            Space(2.h),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenWidth * 0.5,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  )),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Add cash on delivery functionality here
                },
                child: const Text(
                  'Cash on delivery',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: screenWidth * 0.5,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(250, 110, 0, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  )),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  openPaymentOptions(
                      context, orderId, sellerUpi, orderFromUserId, prepData);
                },
                child: const Text(
                  'Pay directly to kitchen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Space(4.h)
          ],
        ),
      );
    },
  );
}

void openPaymentOptions(BuildContext context, String orderId, String sellerUpi,
    String orderFromUserId, Map<String, dynamic> prepData) {
  print("Opening payment options with context: $context");
  var userData = UserPreferences.getUser();
  print("User data for payment: ${jsonEncode(userData)}");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PaymentOptions(
        userId: userData?['user_id'] ?? "",
        orderFromUserId: orderFromUserId,
        orderId: orderId,
        amount: 100.0, // Replace with actual amount if needed
        sellerUpi: sellerUpi,
        prepData: prepData,
      );
    },
  );
}

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
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    setState(() {
      calculateTotalAmount();
    });
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
      if (_scrollController.offset <= 100) {
        setState(() {
          _showContainer = false;
        });
      }
    }
  }

  void calculateTotalAmount() {
    totalAmount =
        context.read<ViewCartProvider>().productList.fold(0.0, (sum, item) {
      // Ensure price and quantity are not null and parse correctly
      int quantity = item.quantity ?? 0;
      double price = double.tryParse(item.price ?? '0') ?? 0.0;

      double totalPrice = quantity * price;

      return sum + totalPrice;
    });

    print(totalAmount);
    setState(() {});
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
    print("addmodel ${context.read<ViewCartProvider>().addressModel}");
    if (context.read<ViewCartProvider>().addressModel == null) {

      TOastNotification().showErrorToast(context, "Please Select Address");
    } else {
      AppWideLoadingBanner().loadingBanner(context);
      var id = Provider.of<ViewCartProvider>(context, listen: false).SellterId;
      var response = await Provider.of<Auth>(context, listen: false)
          .createProductOrder(
              convertedList, context.read<ViewCartProvider>().addressModel, id);

      print("create order response $response");
      if (response['message'] == 'Order processed successfully') {
        var orderId = response['order_id'];
        var sellerUpi = response['data']['seller_upi'];
        var prepData = response['data'];
        print("sellerUpi  $sellerUpi");
        Navigator.pop(context);

        // Show payment method selection
        showPaymentMethodSelection(context, id, orderId, sellerUpi, prepData);
      } else {
        TOastNotification().showErrorToast(context, response['error']);
      }
      setState(() {});
    }
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_live_ILgsfZCZoFIKMb',
      'amount': getprice(),
      'name': 'Cloudbelly ',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
      TOastNotification().showErrorToast(context, "Error opening Razorpay: $e");
    }
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    print("successResponse:: ${response.data.toString()}");
    submitOrder();
  }

  getprice() {
    var sum = 30.0;
    Provider.of<ViewCartProvider>(context, listen: false)
        .productList
        .forEach((element) {
      String? totalPrice = element.price;
      sum += double.parse(totalPrice ?? '0.0');
    });
    sum = sum * 100;

    print("getprice res $sum");
    return sum.toInt();
  }

  // void openCheckout(orderId) async {
  //   print("In side open");
  //   var id = Provider.of<ViewCartProvider>(context, listen: false).SellterId;
  //   final temp =
  //       await Provider.of<Auth>(context, listen: false).getUserInfo([id]);
  //   print("temp is");
  //   print(temp);
  //   if (temp.length == 0 || temp[0]['bank_name'] == null) {
  //     return;
  //   }
  //   var options = {
  //     'key': 'rzp_live_Aq1zY9rLf3Fw1H',
  //     'amount': getprice(),
  //     'name': temp[0]['bank_name'],
  //     'description': 'Fine T-Shirt',
  //     'retry': {'enabled': true, 'max_count': 1},
  //     'send_sms_hash': true,
  //     'order_id': orderId,
  //     'prefill': {'email': temp[0]['email'], "contact": "7003988299"},
  //   };
  //   print("options");
  //   print(options);

  //   // dynamic response = await Provider.of<Auth>(context, listen: false)
  //   //     .submitOrder(orderId, "Cash", id);
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
  //   _razorpay.open(options);
  // }

  // void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
  //   print("successResponse:: ${response.data.toString()}");

  //   submitOrder();
  // }

  void submitOrder() async {
    print("hdjnvd");
    AppWideLoadingBanner().loadingBanner(context);
    var id = Provider.of<ViewCartProvider>(context, listen: false).SellterId;

    dynamic response = await Provider.of<Auth>(context, listen: false)
        .submitOrder(orderId, "Cash", id);
    Navigator.pop(context);
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
      calculateTotalAmount();
    });
  }

  @override
  Widget build(BuildContext context) {
    var id = Provider.of<ViewCartProvider>(context, listen: false).SellterId;
    // final temp = Provider.of<Auth>(context, listen: false).getUserInfo([id]);

    // print('storetemp  ${temp[0]['store_name']}');

    print("id  $id");
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
                          'Cart',
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
                  // Space(0.5.h),
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
                                },
                                child: const Icon(
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
                                },
                                child: const Icon(
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
          // Space(3.5.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Space(20),
                Consumer<ViewCartProvider>(
                    builder: (context, notifiyer, child) {
                  return Container(
                      padding: EdgeInsets.only(
                          top: 0.h, left: 4.w, right: 4.w, bottom: 2.7.h),
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
                            return MenuItemInCart(
                              productDetails: notifiyer.productList[index],
                              onQuantityChanged: calculateTotalAmount,
                            );
                          }));
                }),
                // Space(1.h),
                const Space(33),
                const Space(16),
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
        ]),
      ),
      bottomNavigationBar: _showContainer
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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
                          'Rs ${totalAmount + totalAmount * 0.05 + 30 + 15}',
                          style: const TextStyle(
                            color: Color(0xFFF7F7F7),
                            fontSize: 16,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
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
                        print(convertedList);
                        createProductOrder();
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
                    // // UPI Payment Button
                    // TouchableOpacity(
                    //   onTap: () {
                    //     String upiId = '6206630515@paytm'; // Replace with actual UPI ID
                    //     String name = 'Aniket Kumar Singh'; // Replace with actual vendor name
                    //     String amount = totalAmount.toString(); // Use the calculated total amount
                    //     String transactionId = 'transaction_id_123'; // Generate or use actual transaction ID
                    //     initiateUpiPayment(upiId, name, amount, transactionId);
                    //   },
                    //   child: Container(
                    //     height: 41,
                    //     padding: const EdgeInsets.symmetric(horizontal: 18),
                    //     decoration: ShapeDecoration(
                    //       color: const Color.fromRGBO(84, 166, 193, 1),
                    //       shape: SmoothRectangleBorder(
                    //           borderRadius: SmoothBorderRadius(
                    //         cornerRadius: 12,
                    //         cornerSmoothing: 1,
                    //       )),
                    //     ),
                    //     child: const Center(
                    //       child: Text(
                    //         'Pay with UPI',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 14,
                    //           fontFamily: 'Product Sans',
                    //           fontWeight: FontWeight.w700,
                    //           height: 0,
                    //           letterSpacing: 0.14,
                    //         ),
                    //       ),
                    //     ),
                    //   ),

                    // ),
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
              const Text(
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
          const Space(6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Fee ",
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
                "Rs 30",
                style: TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Packing Charge ",
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
                "Rs 15",
                style: TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Space(10),
          const Text(
            "Save Rs 10 on delivery fee by ordering above Rs 159",
            style: TextStyle(
              color: Color(0xFFD382E3),
              fontSize: 10,
              fontFamily: 'Product Sans Medium',
              fontWeight: FontWeight.w400,
            ),
          ),
          const Space(5.5),
          const Divider(
            color: Color(0xFFBB5104),
            thickness: 0.5,
          ),
          const Space(14.5),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       "Delivery Tip",
          //       style: TextStyle(
          //         color: Color(0xFF2E0536),
          //         fontSize: 16,
          //         fontFamily: 'Product Sans Medium',
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     Text(
          //       "Add tip",
          //       style: TextStyle(
          //         color: Color(0xFFD382E3),
          //         fontSize: 14,
          //         fontFamily: 'Jost',
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ],
          // ),

          // Space(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                " 5% Govt Taxes & Other Charges",
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
                'Rs ${(widget.totalAmount * 0.05).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Space(20),
          const Divider(
            color: Color(0xFFBB5104),
            thickness: 0.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Rs ${widget.totalAmount + widget.totalAmount * 0.05 + 30 + 15}",
                style: const TextStyle(
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            Text(
              'order, a 100% refund will be issued. NO refund for cancellations made after 60 seconds.',
              style: TextStyle(
                color: Color(0xFF383838),
                fontSize: 12,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            Space(10),
            Text(
              'Avoid cancellation as it leads to food wastage.',
              style: TextStyle(
                color: Color(0xFFB549CA),
                fontSize: 12,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
            ),
            // const Space(18),
            // const Text(
            //   'READ CANCELLATION POLICY',
            //   style: TextStyle(
            //     color: Color(0xFFFA6E00),
            //     fontSize: 12,
            //     fontFamily: 'Jost',
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            // Container(
            //   width: 170,
            //   decoration: const ShapeDecoration(
            //     shape: RoundedRectangleBorder(
            //       side: BorderSide(
            //         width: 1,
            //         strokeAlign: BorderSide.strokeAlignOutside,
            //         color: Color(0xFFFA6E00),
            //       ),
            //     ),
            //   ),
            // ),
            // const Space(20)
          ],
        ));
  }
}

class MenuItemInCart extends StatefulWidget {
  const MenuItemInCart({
    super.key,
    required this.productDetails,
    required this.onQuantityChanged,
  });

  final ProductDetails productDetails;
  final Function onQuantityChanged;

  @override
  State<MenuItemInCart> createState() => _MenuItemInCartState();
}

class _MenuItemInCartState extends State<MenuItemInCart> {
  void updateTotalPrice(ProductDetails product) {
    final double price = double.tryParse(product.price ?? "0.0") ?? 0.0;

    // Calculate the total price
    final double totalPrice = price * (product.quantity ?? 0);

    // Assign the calculated total price to the product
    product.totalPrice = totalPrice.toString();
    print("totalPrice is ${product.totalPrice}");
    setState(() {
      widget.productDetails.totalPrice = product.totalPrice;
      widget.onQuantityChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_sharp,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                if (widget.productDetails.quantity! > 1) {
                  widget.productDetails.quantity =
                      widget.productDetails.quantity! - 1;
                  updateTotalPrice(widget.productDetails);
                }
              });
            },
            color: const Color(0xFFFA6E00),
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
            icon: const Icon(
              Icons.keyboard_arrow_up_sharp,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                if (widget.productDetails.quantity! < 10) {
                  widget.productDetails.quantity =
                      widget.productDetails.quantity! + 1;
                  updateTotalPrice(widget.productDetails);
                }
              });
            },
            color: const Color(0xFFFA6E00),
          ),
          Text(
            // 'Rs ${widget.productDetails.price}/item',
            'Rs ${widget.productDetails.totalPrice}', // commenting because now unable to do default check issue
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
