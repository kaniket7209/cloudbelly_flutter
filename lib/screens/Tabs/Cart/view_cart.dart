import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'dart:ui';
import 'package:cloudbelly_app/NotificationScree.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/apply_coupon_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/post_screen.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
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
import 'package:cloudbelly_app/screens/Tabs/order_page.dart';

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
  final String paymentMode;
  final Map<String, dynamic> prepData;

  PaymentOptions({
    required this.userId,
    required this.orderFromUserId,
    required this.orderId,
    required this.amount,
    required this.sellerUpi,
    required this.prepData,
    required this.paymentMode,
  });

  @override
  _PaymentOptionsState createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  Uint8List? qrCode;
  XFile? paymentScreenshot;
  bool isPaymentConfirmed = false;
  bool isCod = false;
  @override
  void initState() {
    super.initState();
    fetchQrCode();
  }

  Future<void> fetchQrCode() async {
    print("Fetching QR code... ");
    const String url = 'https://app.cloudbelly.in/order/upi';
    final payload = {
      'user_id': widget.userId,
      'order_from_user_id': widget.orderFromUserId,
      'order_id': widget.orderId
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
      final s3BucketLink = responseData[
          'file_url']; // Adjust according to your API response structure

      print("Payment screenshot uploaded: $s3BucketLink");

      // Call the verify payment API
      await verifyPayment(s3BucketLink);

      setState(() {
        isPaymentConfirmed = true;
      });

      TOastNotification()
          .showSuccesToast(context, 'Payment confirmed successfully.');
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
      "amount": widget.prepData['amount'],
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
    if (isPaymentConfirmed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thank you,\nYour order has\nbeen placed.',
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
          ),
          Space(2.h),
        ],
      );
    } else if (widget.paymentMode == 'cod') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thank you,\nYour order has\nbeen placed.',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Please pay to kitchen when you receive the order',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
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
          ),
          Space(2.h),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Positioned.directional(
                textDirection: TextDirection.ltr,
                child: Container(
                  child: IconButton(
                    icon: Image.asset('assets/images/back_double_arrow.png'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Center(
                child: Container(
                  child: const Text(
                    'Scan to pay',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans',
                    ),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              initState();
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
          Space(1.h),
        ],
      );
    }
  }

  Widget buildContent(BuildContext context) {
    if (isPaymentConfirmed || widget.paymentMode == 'cod') {
      return Column(
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
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(
                        initialTabIndex: 0,
                        redirect: true // Index of the " Order Tracking" tab
                        ),
                  ),
                );
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
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
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: GestureDetector(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              onPressed: () => pickPaymentScreenshot(),
              child: const Text(
                'Upload payment screenshot',
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
  }

  List<Widget> buildActions(BuildContext context) {
    return (!isPaymentConfirmed && widget.paymentMode != 'cod')
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
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  child: const Text(
                    '**Third party payment is not allowed',
                    style: TextStyle(
                      fontSize: 10,
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
  print("${json.encode(prepData)} prepdddd");
  String preferred_payment_method = prepData['preferred_payment_method'];

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
        title: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    child: IconButton(
                      icon: Image.asset('assets/images/back_double_arrow.png'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Payment',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Product Sans",
                          color: Colors.white),
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
              SizedBox(height: 20),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preferred_payment_method == 'Both Online and COD' ||
                preferred_payment_method == 'COD Only')
              Container(
                width: screenWidth * 0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                      cornerRadius: 15,
                      cornerSmoothing: 1,
                    )),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    submitCustomerOrder(
                        context, orderId, "cod", orderFromUserId, prepData);
                    openPaymentOptions(context, orderId, sellerUpi,
                        orderFromUserId, prepData, 'cod');
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
            if (preferred_payment_method == 'Both Online and COD' ||
                preferred_payment_method == 'Online Only')
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
                    openPaymentOptions(context, orderId, sellerUpi,
                        orderFromUserId, prepData, 'online');
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
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Future<void> submitCustomerOrder(
    // for cod
    BuildContext context,
    String orderId,
    String payment_method,
    String orderFromUserId,
    Map<String, dynamic> prepData) async {
  var userData = UserPreferences.getUser();
  final url = Uri.parse('https://app.cloudbelly.in/order/submit');
  final body = json.encode({
    "user_id": userData?['user_id'] ?? "",
    "order_from_user_id": orderFromUserId,
    "order_id": orderId,
    "payment_method": payment_method
  });

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    // setState(() {
    //   isCod = true;
    // });

    TOastNotification().showSuccesToast(
        context, 'Order no ${prepData['order_no']} submitted successfully ');
    print('Order  submitted successfully');
  } else {
    print('Failed to submit order');
  }
}

void openPaymentOptions(BuildContext context, String orderId, String sellerUpi,
    String orderFromUserId, Map<String, dynamic> prepData, String paymentMode) {
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
        paymentMode: paymentMode,
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
  double deliveryFee = 0.0;
  bool _isAddressExpnaded = false;
  ScrollController _scrollController = ScrollController();
  bool _showContainer = false;
  bool _scrollingDown = false;
  DeliveryAddressModel? addressList;
  double totalAmount = 0.0;
  Map<String, dynamic> response = {};
  String? orderId;
  List<Map<String, dynamic>> convertedList = [];
  // final Razorpay _razorpay = Razorpay();
  // bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    setState(() {
      calculateTotalAmount();
    });
  }

  void updateDeliveryFee(double fee) {
    setState(() {
      deliveryFee = fee;
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
    // Get the ViewCartProvider instance
    final viewCartProvider = context.read<ViewCartProvider>();

    // Calculate the total product price
    double total = viewCartProvider.productList.fold(0.0, (sum, item) {
      int quantity = item.quantity ?? 0;
      double price = double.tryParse(item.price ?? '0') ?? 0.0;
      return sum + (quantity * price);
    });

    // Get the delivery fee from ViewCartProvider (default to 0 if not available)
    double? deliveryFee = viewCartProvider.deliveryFee ?? 0.0;

    // Update the CartProvider's totalAmount to include the delivery fee
    print("$total  totpriceee");
    context
        .read<CartProvider>()
        .updateProductTotal(total);
  }

  void getAddressDetails() async {
    AppWideLoadingBanner().loadingBanner(context);
    
    addressList = await Provider.of<Auth>(context, listen: false)
        .getAddressList()
        .then((value) {
      
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
    print(
        "addmodel ${context.read<ViewCartProvider>().addressModel?.location}");
    if (context.read<ViewCartProvider>().addressModel?.location == null) {
      TOastNotification().showErrorToast(context, "Please Select Address");
    } else {
      AppWideLoadingBanner().loadingBanner(context);
      var id = Provider.of<ViewCartProvider>(context, listen: false).SellterId;
      print("sellerid $id");
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

  // void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
  //   print("successResponse:: ${response.data.toString()}");
  //   submitOrder();
  // }

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

                Consumer2<CartProvider, ViewCartProvider>(
                  builder: (context, cartProvider, viewCartProvider, child) {
                    double totalAmount = cartProvider.totalAmount;

                    return CouponWidget(
                        totalAmount: totalAmount + deliveryFee + 3);
                  },
                ),
                const Space(20),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Bill Details",
                    style: TextStyle(
                      color: Color(0xff2E0536),
                      fontSize: 18,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                PriceWidget(
                  totalAmount:
                      totalAmount, // Pass the total amount of the cart items
                  sellerId:
                      id, // Pass the sellerId for delivery fee calculation
                  onDeliveryFeeCalculated:
                      updateDeliveryFee, // Callback to update delivery fee in parent
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
                        // Text(
                        //   'Rs ${totalAmount + totalAmount * 0.05 + 30 + 15}',

                        //   style: const TextStyle(
                        //     color: Color(0xFFF7F7F7),
                        //     fontSize: 16,
                        //     fontFamily: 'Jost',
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            double totalAmount =
                               cartProvider.productTotal + deliveryFee + 3;

                            return Text(
                              'Rs ${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFF7F7F7),
                                fontSize: 16,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const Text(
                          'View Detailed Bill ',
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
                        convertedList.clear();
                        context
                            .read<ViewCartProvider>()
                            .productList
                            .forEach((element) {
                          String productId = element.id ?? "";
                          String priceEach = element.price ?? "";
                          int quantity = element.quantity ?? 0;

                          Map<String, dynamic> newItem = {
                            'product_id': productId,
                            'price_each': priceEach,
                            'quantity': quantity,
                          };

                          convertedList.add(newItem);
                        });
                        // print("convertedList  $convertedList");
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

class CouponWidget extends StatefulWidget {
  final double totalAmount;
  const CouponWidget({super.key, required this.totalAmount});
  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  @override
  Widget build(BuildContext context) {
    print("coupwidget  ${widget.totalAmount}");
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Offers & Benefits",
              style: TextStyle(
                color: Color(0xff2E0536),
                fontSize: 18,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          GestureDetector(
            onTap: () {
              // Use Consumer to access the CartProvider and ViewCartProvider
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ApplyCouponScreen(totalAmount: widget.totalAmount)));
            },
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius:
                        20, // Adjust radius for a more squircle effect
                    cornerSmoothing: 1,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0xffBC73BC).withOpacity(0.2), // Shadow color
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Apply Coupon",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xff2E0536),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xffFA6E00),
                      size: 20,
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
}

class PriceWidget extends StatefulWidget {
  final double totalAmount;
  final String sellerId;
  final Function(double) onDeliveryFeeCalculated; // Callback to parent

  PriceWidget({
    required this.totalAmount,
    required this.sellerId,
    required this.onDeliveryFeeCalculated, // Add this parameter
  });

  @override
  State<PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  double? deliveryDistance;
  double? deliveryFee;
  String? errorMessage;
  late ViewCartProvider _viewCartProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchDeliveryFee();
      calculateTotalAmount();
    });
  }

  void calculateTotalAmount() async {
    // Get the ViewCartProvider instance
    final viewCartProvider = context.read<ViewCartProvider>();

    // Calculate the total product price
    double total = viewCartProvider.productList.fold(0.0, (sum, item) {
      int quantity = item.quantity ?? 0;
      double price = double.tryParse(item.price ?? '0') ?? 0.0;
      return sum + (quantity * price);
    });

    // Get the delivery fee from ViewCartProvider (default to 0 if not available)
    double? deliveryFee = viewCartProvider.deliveryFee ?? 0.0;

    // Update the CartProvider's totalAmount to include the delivery fee
    context
        .read<CartProvider>()
        .updateProductTotal(total);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewCartProvider = Provider.of<ViewCartProvider>(context);
    _viewCartProvider.addListener(fetchDeliveryFee);
  }

  @override
  void dispose() {
    _viewCartProvider.removeListener(fetchDeliveryFee);
    super.dispose();
  }

  Future<void> fetchDeliveryFee() async {
    final addressModel = _viewCartProvider.addressModel;

    if (addressModel == null ||
        addressModel.latitude == null ||
        addressModel.longitude == null) {
      print("No address selected");
      setState(() {
        errorMessage = "No address selected";
      });
      return;
    }

    final String latitude = addressModel.latitude ?? '';
    final String longitude = addressModel.longitude ?? '';

    if (latitude.isEmpty || longitude.isEmpty) {
      print("Invalid latitude or longitude values");
      setState(() {
        errorMessage = "Invalid latitude or longitude values";
      });
      return;
    }

    final double? customerLat = double.tryParse(latitude);
    final double? customerLon = double.tryParse(longitude);

    if (customerLat == null || customerLon == null) {
      print("Invalid latitude or longitude values");
      setState(() {
        errorMessage = "Invalid latitude or longitude values";
      });
      return;
    }

    final String url = 'https://app.cloudbelly.in/get_distance';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'latitude': customerLat,
          'longitude': customerLon,
          'seller_user_id': widget.sellerId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Data delivery: $data");

        setState(() {
          deliveryDistance = (data['distance'] as num).toDouble();
          deliveryFee = (data['price'] as num).toDouble();
          widget.onDeliveryFeeCalculated(deliveryFee!); //
          // Calculate the new total amount
          double totalAmount = widget.totalAmount + (deliveryFee ?? 30) + 3;
          // Update the CartProvider with the new total amount
          // Provider.of<CartProvider>(context, listen: false)
          //     .updateTotalAmount(totalAmount, deliveryFee);
          Provider.of<CartProvider>(context, listen: false).updateDeliveryFee(totalAmount);
        });
      } else {
        print("Failed to load delivery fee: ${response.body}");
        setState(() {
          errorMessage = "Failed to load delivery fee";
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        errorMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: const Color.fromRGBO(188, 115, 188, 0.2),
          ),
        ],
      ),
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
              Flexible(
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    
                    double taxAmount = cartProvider.productTotal;

                    return Text(
                      'Rs ${taxAmount.toStringAsFixed(2)}', // Display the calculated tax
                      style: const TextStyle(
                        color: Color(0xFF383838),
                        fontSize: 14,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Distance ",
                style: TextStyle(
                  color: Color(0xFF2E0536),
                  fontSize: 12,
                  fontFamily: 'Product Sans Medium',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF2E0536),
                ),
              ),
              deliveryDistance == null
                  ? errorMessage != null
                      ? Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Color(0xff0A4C61),
                            strokeWidth: 2,
                          ),
                        )
                  : Text(
                      "${deliveryDistance?.toStringAsFixed(1)} kms ",
                      style: const TextStyle(
                        color: Color(0xFF383838),
                        fontSize: 14,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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
                  Flexible(
                    child: deliveryFee == null
                        ? errorMessage != null
                            ? Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Color(0xff0A4C61),
                                  strokeWidth: 2,
                                ),
                              )
                        : Text(
                            "Rs ${deliveryFee?.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFF383838),
                              fontSize: 14,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Platform Fee ",
                    style: TextStyle(
                      color: Color(0xFF2E0536),
                      fontSize: 12,
                      fontFamily: 'Product Sans Medium',
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF2E0536),
                    ),
                  ),
                  const Text(
                    "Rs 3",
                    style: TextStyle(
                      color: Color(0xFF383838),
                      fontSize: 14,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(
                color: Color(0xFFBB5104),
                thickness: 0.5,
              ),
              const SizedBox(height: 2.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Packaging Charge ",
                    style: TextStyle(
                      color: Color(0xFF2E0536),
                      fontSize: 12,
                      fontFamily: 'Product Sans Medium',
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF2E0536),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Rs 15",
                        style: TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 14,
                          fontFamily: 'Jost',
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "  0",
                        style: TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 14,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "5% Govt Taxes & Other Charges",
                    style: TextStyle(
                      color: Color(0xFF2E0536),
                      fontSize: 12,
                      fontFamily: 'Product Sans Medium',
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF2E0536),
                    ),
                  ),
                  Flexible(
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        // Calculate the 5% tax based on the totalAmount from the CartProvider
                        double taxAmount = cartProvider.productTotal * 0.05;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Rs ${taxAmount.toStringAsFixed(2)}', // Display the calculated tax
                              style: const TextStyle(
                                color: Color(0xFF383838),
                                fontSize: 14,
                                fontFamily: 'Jost',
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '  0', // Display the calculated tax
                              style: const TextStyle(
                                color: Color(0xFF383838),
                                fontSize: 14,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                  // Text(
                  //   "Rs ${(widget.totalAmount + (deliveryFee ?? 30) + 3).toStringAsFixed(2)}",
                  //   style: const TextStyle(
                  //     color: Color(0xFFFA6E00),
                  //     fontSize: 16,
                  //     fontFamily: 'Jost',
                  //     fontWeight: FontWeight.w800,
                  //   ),
                  // ),
                  Flexible(
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        // Calculate the 5% tax based on the totalAmount from the CartProvider
                        double amt =
                            cartProvider.productTotal + 3 + (deliveryFee ?? 30);

                        return Text(
                          'Rs ${amt.toStringAsFixed(2)}', // Display the calculated tax
                          style: const TextStyle(
                            color: Color(0xFF383838),
                            fontSize: 14,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            icon: const Icon(Icons.keyboard_arrow_up_sharp, size: 35),
            onPressed: () {
              setState(() {
                if (widget.productDetails.quantity! < 10) {
                  widget.productDetails.quantity =
                      widget.productDetails.quantity! + 1;
                  updateTotalPrice(widget.productDetails);
                  widget.onQuantityChanged();
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
