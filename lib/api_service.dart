// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

// import 'dart:html';

import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/model.dart';

class Auth with ChangeNotifier {
  // static final Auth _instance = Auth._internal();

  // Your global variables go here

  // factory Auth() {
  //   return _instance;
  // }

  /* String user_id = '';
  String user_email = '';
  String store_name = '';

  String pan_number = '';
  String bank_name = '';
  String pincode = '';
  String cover_image = '';
  String rating = '-';
  List<dynamic> followers = [];
  List<dynamic> followings = [];
  String userType = '';*/
  List<dynamic> menuList = [];
  bool showBanner = false;
  var Tpice;
  Map<String, dynamic>? userData = UserPreferences.getUser();
  String logo_url = '';
  String baseUrl = "https://app.cloudbelly.in/";
  String? fcmToken = '';
  List<ProductDetails> itemAdd = [];
  List notificationDetails = [];
  List<Map<String, dynamic>> orderDetails = [];
  List<Map<String, dynamic>> customerOrderDetails = [];
  List<Map<String, dynamic>> paymentDetails = [];
  // Assume your API response provides this status categorization
  List<Map<String, dynamic>> get incomingOrders =>
      orderDetails.where((order) => order['status'] == 'Submitted').toList();
  List<Map<String, dynamic>> get acceptedOrders =>
      orderDetails.where((order) => order['status'] == 'Accepted').toList();
  List<Map<String, dynamic>> get completedOrders =>
      orderDetails.where((order) => order['status'] == 'delivered').toList();
  List<Map<String, dynamic>> get ongoingOrders => orderDetails
      .where((order) =>
          order['status'] == 'Accepted' ||
          order['status'] == 'Prepared' ||
          order['status'] == 'Packed' ||
          order['status'] == 'assigning_rider' ||
          order['status'] == 'assigned' ||
          order['status'] == 'self_delivery' ||
          order['status'] == 'Out for delivery')
      .toList();
  List<Map<String, dynamic>> get trackCustomerOrders => customerOrderDetails
      .where((order) =>
              order['status'] == 'Submitted' ||
              order['status'] == 'Accepted' ||
              order['status'] == 'Prepared' ||
              order['status'] == 'Packed' ||
              order['status'] == 'assigning_rider' ||
              order['status'] == 'Out for delivery'
          //  ||
          // order['status'] == 'Delivered'
          )
      .toList();
       List<Map<String, dynamic>> get deliveryStatus => orderDetails
      .where((order) =>
              order['delivery_status'] == 'assigning' 
            
         
          )
      .toList();

  List<Map<String, dynamic>> get paymentVerifications => paymentDetails;

  // get user_logo_url {
  //   notifyListeners();
  //   return logo_url;
  // }

/*  String get_user_id() {
    return user_id;
  }*/

  final headers = {
    'Accept': '*/*',
    'Content-Type': 'application/json',
    'Accept-Encoding': 'gzip, deflate, br'
  };

  Future<void> acceptOrder(
      String orderId, String userId, String orderFrom) async {
    final response = await http.post(
      Uri.parse("https://app.cloudbelly.in/order/accept"),
      headers: headers,
      body: jsonEncode({
        "user_id": userId,
        "order_from_user_id": orderFrom,
        "order_id": orderId
      }),
    );
    if (response.statusCode == 200) {
      final orderIndex =
          orderDetails.indexWhere((order) => order['_id'] == orderId);
      if (orderIndex != -1) {
        orderDetails[orderIndex]['status'] = 'Accepted';
        notifyListeners();
      }
    } else {
      throw Exception('Failed to accept order');
    }
  }

  Future<void> statusChange(
      String orderId, String userId, String orderFrom, String status) async {
    final response = await http.post(
      Uri.parse("https://app.cloudbelly.in/order/status-change"),
      headers: headers,
      body: jsonEncode({
        "user_id": userId,
        "order_from_user_id": orderFrom,
        "order_id": orderId,
        "status-change": status
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final orderIndex =
          orderDetails.indexWhere((order) => order['_id'] == orderId);
      if (orderIndex != -1) {
        orderDetails[orderIndex]['status'] =
            status; // Update to the correct status
        notifyListeners();
      }
    } else {
      throw Exception('Failed to change order status');
    }
  }

  Future<void> rejectOrder(
      String orderId, String userId, String orderFrom) async {
    final response = await http.post(
      Uri.parse("https://app.cloudbelly.in/order/reject"),
      headers: headers,
      body: jsonEncode({
        "user_id": userId,
        "order_from_user_id": orderFrom,
        "order_id": orderId
      }),
    );
    if (response.statusCode == 200) {
      final orderIndex =
          orderDetails.indexWhere((order) => order['_id'] == orderId);
      if (orderIndex != -1) {
        orderDetails[orderIndex]['status'] = 'Rejected';
        notifyListeners();
      }
    } else {
      throw Exception('Failed to accept order');
    }
  }

  Future<dynamic> assignDeliveryPartnerUengage(
      String orderId, String userId, String orderFrom) async {
    final response = await http.post(
      Uri.parse("https://app.cloudbelly.in/order/assign_delivery"),
      headers: headers,
      body: jsonEncode({
        "user_id": userId,
        "order_from_user_id": orderFrom,
        "order_id": orderId
      }),
    );
    if (response.statusCode == 200) {
      print("responseAssign ${json.encode(response.body)}");
      // final orderIndex =
      //     orderDetails.indexWhere((order) => order['_id'] == orderId);
      // if (orderIndex != -1) {
      //   orderDetails[orderIndex]['status'] = 'searching_rider';
      //   notifyListeners();
      // }
      return response.body;
    } else {
      throw Exception('Failed to search  rider for this order');
    }
  }
 Future<dynamic> getTaskStatus(
       taskId) async {
    final response = await http.post(
      Uri.parse("https://app.cloudbelly.in/task_status"),
      headers: headers,
      body: jsonEncode({
        "task_id": taskId,
        
      }),
    );
    if (response.statusCode == 200) {
      print("resTask ${json.encode(response.body)}");
      return response.body;
     
    } else {
      throw Exception('Task not found');
    }
  }
  
  Future<dynamic> cancelDeliveryTask(
       taskId,orderFrom,userId,orderId) async {
    final response = await http.post(
      Uri.parse("https://app.cloudbelly.in/order/cancel_task"),
      headers: headers,
      body: jsonEncode({
        "task_id": taskId,
         "user_id": userId,
        "order_from_user_id": orderFrom,
        "order_id": orderId

        
      }),
    );
    if (response.statusCode == 200) {
      print("cancekTask ${json.encode(response.body)}");
      return response.body;
     
    } else {
      throw Exception('Task not found');
    }
  }
  
  Future<void> markOrderAsDelivered(
      String orderId, String userId, String orderFrom) async {
    final response = await http.post(
      Uri.parse("https://app.cloudbelly.in/order/delivered"),
      headers: headers,
      body: jsonEncode({
        "user_id": userId,
        "order_from_user_id": orderFrom,
        "order_id": orderId
      }),
    );
    if (response.statusCode == 200) {
      final orderIndex =
          orderDetails.indexWhere((order) => order['_id'] == orderId);
      if (orderIndex != -1) {
        orderDetails[orderIndex]['status'] = 'delivered';
        notifyListeners();
      }
    } else {
      throw Exception('Failed to mark order as delivered');
    }
  }

  // Auth._internal();
  void getToken(String? token) async {
    fcmToken = token;
    await updateFcmToken(fcmToken);
    notifyListeners();
  }

  Future<String> updateFcmToken(fcm_token) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'fcm_token': fcm_token
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      print("updated fcm token  ${jsonEncode(response.body)}");
      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future createNewCoupons(selectedCouponType, discountValue, minCartValue,
      selectedApplicableFor, couponCode) async {
    final String url = 'https://app.cloudbelly.in/coupons/create';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "coupon_type": selectedCouponType,
      "discount_value": discountValue,
      "min_cart_value": minCartValue,
      "applicable_for": selectedApplicableFor,
      "coupon_code": couponCode
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("created coupons  ${jsonEncode(response.body)}");
      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return {"code": 200, "msg": "Unexpected errors"};
    }
  }

  Future getCouponsByUserId() async {
    final String url = 'https://app.cloudbelly.in/coupons/get';

    final Map<String, dynamic> requestBody = {'user_id': userData?['user_id']};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("payload coupons  ${jsonEncode(requestBody)}");
      print("fetched coupons  ${jsonEncode(response.body)}");
      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return {"code": 200, "msg": "Unexpected errors"};
    }
  }

  Future getCustomersCoupons(user_id) async {
    final String url = 'https://app.cloudbelly.in/coupons/get';

    final Map<String, dynamic> requestBody = {'user_id': user_id};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("fetched coupons  ${jsonEncode(response.body)}");
      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return {"code": 200, "msg": "Unexpected errors"};
    }
  }

  Future getDistance(sellerUserId, latitude, longitude) async {
    final String url = 'https://app.cloudbelly.in/get_distance';

    final Map<String, dynamic> requestBody = {
      'seller_user_id': sellerUserId,
      'latitude': latitude,
      "longitude": longitude
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("fetched   ${jsonEncode(response.body)}");
      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return {"code": 500, "msg": "Unexpected errors"};
    }
  }

  Future updateCoupon(String couponId, Map<String, dynamic> updData) async {
    final String url = 'https://app.cloudbelly.in/coupons/update';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'coupon_id': couponId,
      ...updData, // Merging additional update data into the request body
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      print("Updated coupon: ${jsonEncode(responseData)}");
      return responseData;
    } catch (error) {
      // Handle exceptions
      print("Error updating coupon: $error");
      return {"code": 400, "msg": "Unexpected error occurred"};
    }
  }

  Future deleteCoupon(couponId) async {
    final String url = 'https://app.cloudbelly.in/coupons/delete';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'coupon_id': couponId
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("created coupons  ${jsonEncode(response.body)}");
      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return {"code": 200, "msg": "Unexpected errors"};
    }
  }

  bannerTogger(ProductDetails item) {
    showBanner = !showBanner;
    print("item.toString() ${item.toString()}");
    item.quantity = 1;
    item.totalPrice = item.price;
    itemAdd.add(item);
    print("showing banner");
    getprice();
    notifyListeners();
  }

  getprice() {
    var sum = 0.0;
    itemAdd.forEach((element) {
      var quantity = element.quantity ?? 0;
      String priceString = element.price ?? '0';
      double price = (double.parse(priceString) * quantity);
      sum = sum + price;
    });
    Tpice = sum;
    // print("sum is");
    // print(sum);
    notifyListeners();
    // return sum;
  }

  Future<void> getNotificationList() async {
    try {
      final response = await http.post(
        Uri.parse("https://app.cloudbelly.in/get-notification"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": userData?['user_id'] ?? ""}),
      );
      final orders = await http.post(
        Uri.parse("https://app.cloudbelly.in/order/get"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"order_from_user_id": userData?['user_id'] ?? ""}),
      );
      orderDetails = List<Map<String, dynamic>>.from(jsonDecode(orders.body));
      final customerOrders = await http.post(
        Uri.parse("https://app.cloudbelly.in/order/get"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": userData?['user_id'] ?? ""}),
      );
      customerOrderDetails =
          List<Map<String, dynamic>>.from(jsonDecode(customerOrders.body));
      print("customerOrderDetails ${customerOrderDetails.length}");
      final payments = await http.post(
        Uri.parse("https://app.cloudbelly.in/payments/get"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "payment_to_user_id": userData?['user_id'] ?? "",
          "\$or": [
            {
              "payment_status": {"\$exists": false}
            },
            {
              "payment_status": {"\$ne": "verified"}
            }
          ]
        }),
      );

      paymentDetails =
          List<Map<String, dynamic>>.from(jsonDecode(payments.body));
      if (response.statusCode == 200) {
        var notif = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        notificationDetails = notif
            .where((element) => element['msg']['type'] == 'social')
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  removeItem(item) {
    int idx = itemAdd.indexWhere((element) => element.id == item.id);
    itemAdd[idx].quantity = (itemAdd[idx].quantity ?? 0) - 1;
    if ((itemAdd[idx].quantity ?? 0) <= 0) {
      itemAdd.removeAt(idx);
    }
    getprice();

    notifyListeners();
  }

  void clearAllItems() {
    itemAdd.clear();
    getprice();
    notifyListeners();
  }

  addItem(ProductDetails item) {
    int idx = itemAdd.indexWhere((element) => element.id == item.id);
    itemAdd[idx].quantity = (itemAdd[idx].quantity ?? 0) + 1;
    var quantity = itemAdd[idx].quantity ?? 0; // Default to 0 if null

// Use a default value of '0' if itemAdd[idx].price is null
    String priceString = itemAdd[idx].price ?? '0';
    double price =
        double.tryParse(priceString) ?? 0.0; // Default to 0.0 if parsing fails
    itemAdd[idx].totalPrice = price.toString();
    print(item.toJson());

    // var p =  ProductDetails(itemAdd[idx]);
    print(json.encode(itemAdd));
    print(item.totalPrice);
    getprice();

    notifyListeners();
  }

  Future<void> getUserData() async {
    userData = UserPreferences.getUser();
    print("userData :: $userData");
    notifyListeners();
  }

  Future<void> setData(Map<String, dynamic>? userProfileData) async {
    print("userDtat:: don");

    Map<String, dynamic>? userData = {
      'user_id': userProfileData?['user_id'],
      'email': userProfileData?['email'],
      'store_name': userProfileData?['store_name'] ??
          userProfileData?['email'].split('@')[0],
      'profile_photo': userProfileData?['profile_photo'] ?? '',
      'store_availability': userProfileData?['store_availability'] ?? '',
      'pan_number': userProfileData?['pan_number'] ?? '',
      'aadhar_number': userProfileData?['aadhar_number'] ?? '',
      'start_time': userProfileData?['working_hours']['start_time'] ?? '',
      'end_time': userProfileData?['working_hours']['end_time'] ?? '',
      'bank_name': userProfileData?['bank_name'] ?? '',
      'pincode': userProfileData?['pincode'] ?? '',
      'rating': userProfileData?['rating'] ?? 'NA',
      'followers': userProfileData?['followers'] ?? [],
      'followings': userProfileData?['followings'] ?? [],
      'cover_image': userProfileData?['cover_image'] ?? '',
      'account_number': userProfileData?['account_number'] ?? '',
      'ifsc_code': userProfileData?['ifsc_code'] ?? '',
      'phone': userProfileData?['phone'] ?? '',
      'upi_id': userProfileData?['upi_id'] ?? '',
      'user_type': userProfileData?['user_type'] ?? '',
    };
    print("userDtat:: $userData");
    await UserPreferences.setUser(userData);
    userData = UserPreferences.getUser();
    print("userDtat:: $userData");
    notifyListeners();
  }

  Future<String> signUp(context, email, pass, phone, type) async {
    const String url = 'https://app.cloudbelly.in/signup';
    final prefs = await SharedPreferences.getInstance();

    _getCurrentLocation(context);
    final Map<String, dynamic> requestBody = {
      "email": email,
      "password": pass,
      "phone": phone,
      "user_type": type,
      "fcm_token": prefs.getString('fcmToken'),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("json response:: ${jsonDecode((response.body))}");
      final DataMap = jsonDecode(response.body);
      Map<String, dynamic> userProfileData = {
        'user_id': DataMap['user_id'],
        'user_name': DataMap['user_name'],
        'email': DataMap['email'],
        'store_name': DataMap['store_name'] ?? DataMap['email'].split('@')[0],
        'profile_photo': DataMap['profile_photo'] ?? '',
        'store_availability': DataMap['store_availability'] ?? false,
        'pan_number': DataMap['pan_number'] ?? '',
        'aadhar_number': DataMap['aadhar_number'] ?? '',
        if (DataMap['location'] != null)
          'location': {
            'details': DataMap['location']['details'] ?? '',
            'latitude': DataMap['location']['latitude'] ?? '',
            'longitude': DataMap['location']['longitude'] ?? '',
          },
        if (DataMap['current_location'] != null)
          'current_location': {
            'area': DataMap['current_location']['area'] ?? '',
            'latitude': DataMap['current_location']['latitude'] ?? '',
            'longitude': DataMap['current_location']['longitude'] ?? '',
          },
        if (DataMap['address'] != null)
          'address': {
            "location": DataMap['address']['location'],
            "latitude": DataMap['address']['latitude'],
            "longitude": DataMap['address']['longitude'],
            "hno": DataMap['address']['hno'],
            "pincode": DataMap['address']['pincode'],
            "landmark": DataMap['address']['landmark'],
            "type": DataMap['address']['type'],
          },
        if (DataMap['working_hours'] != null)
          'working_hours': {
            'start_time': DataMap['working_hours']['start_time'] ?? '',
            'end_time': DataMap['working_hours']['end_time'] ?? '',
          },
        'delivery_addresses': DataMap['delivery_addresses'] ?? [],
        'bank_name': DataMap['bank_name'] ?? '',
        'pincode': DataMap['pincode'] ?? '',
        'rating': DataMap['rating'] ?? '-',
        'followers': DataMap['followers'] ?? [],
        'followings': DataMap['followings'] ?? [],
        'cover_image': DataMap['cover_image'] ?? '',
        'account_number': DataMap['account_number'] ?? '',
        'ifsc_code': DataMap['ifsc_code'] ?? '',
        'phone': DataMap['phone'] ?? '',
        'upi_id': DataMap['upi_id'] ?? '',
        'user_type': DataMap['user_type'] ?? 'Vendor',
      };
      await UserPreferences.setUser(userProfileData);
      userData = UserPreferences.getUser();
      notifyListeners();
      return jsonDecode((response.body))['message'];
    } catch (error) {
      // Handle exceptions
      notifyListeners();
      return '-1';
    }
  }

  Future<void> _getCurrentLocation(context) async {
    var _currentPosition;
    var address;
    var area;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition?.latitude ?? 22.88689073443092,
          _currentPosition?.longitude ?? 79.5086424934095);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        address =
            '${placemark.street}, ${placemark.subLocality},${placemark.subAdministrativeArea}, ${placemark.locality}, ${placemark.administrativeArea},${placemark.country}, ${placemark.postalCode}';
        area = '${placemark.administrativeArea}';
      } else {
        address = 'Address not found';
      }

      await Provider.of<Auth>(context, listen: false).updateCustomerLocation(
          _currentPosition?.latitude, _currentPosition?.longitude, area);
      print("locLogmain.dart $_currentPosition  $area");
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> login(context, email, pass) async {
    print("fcmToken:: $fcmToken");
    final prefs = await SharedPreferences.getInstance();

    print('nknbnkjbn');
    _getCurrentLocation(context);
    final String url = 'https://app.cloudbelly.in/login';

    final Map<String, dynamic> requestBody = {
      "email": email,
      "password": pass,
      "fcm_token": prefs.getString('fcmToken'),
    };
    // Login successful
    print("resquestbody:: $requestBody");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      final DataMap = jsonDecode(response.body);
      log("dta:: $DataMap");
      Map<String, dynamic> userProfileData = {
        'user_id': DataMap['user_id'],
        'user_name': DataMap['user_name'],
        'email': DataMap['email'],
        'store_name': DataMap['store_name'] ?? DataMap['email'].split('@')[0],
        'profile_photo': DataMap['profile_photo'] ?? '',
        'store_availability': DataMap['store_availability'] ?? false,
        'pan_number': DataMap['pan_number'] ?? '',
        'aadhar_number': DataMap['aadhar_number'] ?? '',
        if (DataMap['address'] != null)
          'address': {
            "location": DataMap['address']['location'],
            "latitude": DataMap['address']['latitude'],
            "longitude": DataMap['address']['longitude'],
            "hno": DataMap['address']['hno'],
            "pincode": DataMap['address']['pincode'],
            "landmark": DataMap['address']['landmark'],
            "type": DataMap['address']['type'],
          },
        if (DataMap['location'] != null)
          'location': {
            'details': DataMap['location']['details'] ?? '',
            'latitude': DataMap['location']['latitude'] ?? '',
            'longitude': DataMap['location']['longitude'] ?? '',
          },
        if (DataMap['current_location'] != null)
          'current_location': {
            'area': DataMap['current_location']['area'] ?? '',
            'latitude': DataMap['current_location']['latitude'] ?? '',
            'longitude': DataMap['current_location']['longitude'] ?? '',
          },
        if (DataMap['working_hours'] != null)
          'working_hours': {
            'start_time': DataMap['working_hours']['start_time'] ?? '',
            'end_time': DataMap['working_hours']['end_time'] ?? '',
          },
        'delivery_addresses': DataMap['delivery_addresses'] ?? [],
        'bank_name': DataMap['bank_name'] ?? '',
        'pincode': DataMap['pincode'] ?? '',
        'rating': DataMap['rating'] ?? '-',
        'followers': DataMap['followers'] ?? [],
        'followings': DataMap['followings'] ?? [],
        'cover_image': DataMap['cover_image'] ?? '',
        'account_number': DataMap['account_number'] ?? '',
        'ifsc_code': DataMap['ifsc_code'] ?? '',
        'phone': DataMap['phone'] ?? '',
        'upi_id': DataMap['upi_id'] ?? '',
        'user_type': DataMap['user_type'] ?? 'Vendor',
      };

      await UserPreferences.setUser(userProfileData);
      userData = UserPreferences.getUser();
      print('user data:$userData');
      notifyListeners();

      return DataMap['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return "-1";
    }
  }

  Future<Map<String, dynamic>> commonLogin(
      BuildContext context, String mobileNo, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    _getCurrentLocation(context); // Make sure _getCurrentLocation is defined
    final String url = 'https://app.cloudbelly.in/common-login';

    final Map<String, dynamic> requestBody = {
      "phone": mobileNo,
      "fcm_token": prefs.getString('fcmToken'),
      "user_type": userType,
    };

    print("requestBody:: $requestBody");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final DataMap = responseBody['data'];
        print("data:: $DataMap");

        Map<String, dynamic> userProfileData = {
          'user_id': DataMap['user_id'],
          'user_name': DataMap['user_name'],
          'email': DataMap['email'],
          'store_name': DataMap['store_name'] ??
              DataMap['email'].split('@')[0] ??
              "Unknown",
          'profile_photo': DataMap['profile_photo'] ?? '',
          'store_availability': DataMap['store_availability'] ?? false,
          'pan_number': DataMap['pan_number'] ?? '',
          'aadhar_number': DataMap['aadhar_number'] ?? '',
          if (DataMap['address'] != null)
            'address': {
              "location": DataMap['address']['location'],
              "latitude": DataMap['address']['latitude'],
              "longitude": DataMap['address']['longitude'],
              "hno": DataMap['address']['hno'],
              "pincode": DataMap['address']['pincode'],
              "landmark": DataMap['address']['landmark'],
              "type": DataMap['address']['type'],
            },
          if (DataMap['location'] != null)
            'location': {
              'details': DataMap['location']['details'] ?? '',
              'latitude': DataMap['location']['latitude'] ?? '',
              'longitude': DataMap['location']['longitude'] ?? '',
            },
          if (DataMap['current_location'] != null)
            'current_location': {
              'area': DataMap['current_location']['area'] ?? '',
              'latitude': DataMap['current_location']['latitude'] ?? '',
              'longitude': DataMap['current_location']['longitude'] ?? '',
            },
          if (DataMap['working_hours'] != null)
            'working_hours': {
              'start_time': DataMap['working_hours']['start_time'] ?? '',
              'end_time': DataMap['working_hours']['end_time'] ?? '',
            },
          'delivery_addresses': DataMap['delivery_addresses'] ?? [],
          'bank_name': DataMap['bank_name'] ?? '',
          'pincode': DataMap['pincode'] ?? '',
          'rating': DataMap['rating'] ?? '-',
          'followers': DataMap['followers'] ?? [],
          'followings': DataMap['followings'] ?? [],
          'cover_image': DataMap['cover_image'] ?? '',
          'account_number': DataMap['account_number'] ?? '',
          'ifsc_code': DataMap['ifsc_code'] ?? '',
          'phone': DataMap['phone'] ?? '',
          'upi_id': DataMap['upi_id'] ?? '',
          'user_type': DataMap['user_type'] ?? 'Vendor',
        };

        await prefs.setString('userData', jsonEncode(userProfileData));
        await UserPreferences.setUser(userProfileData);
        userData = UserPreferences.getUser();
        print('user data:$userData');

        notifyListeners();
        return responseBody;
      } else {
        print(
            "Login/Registration failed with status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        notifyListeners();
        return {"code": response.statusCode};
      }
    } catch (error, stackTrace) {
      print("Error during login/registration: $error");
      print("Stack trace: $stackTrace");
      notifyListeners();
      return {"code": 500, "error": error.toString()};
    }
  }

  Future<String> googleLogin(email, userType) async {
    print("fcmToken:: $fcmToken");
    final prefs = await SharedPreferences.getInstance();
    print('nknbnkjbn');
    final String url = '${baseUrl}google-login';

    final Map<String, dynamic> requestBody = {
      "email": email,
      "user_type": userType,
      "fcm_token": prefs.getString('fcmToken'),
    };
    // Login successful
    print("resquestbody:: $requestBody");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("response:: ${response.body}");
      final DataMap = jsonDecode(response.body);
      Map<String, dynamic> userProfileData = {
        'user_id': DataMap['user_id'],
        'email': DataMap['email'],
        'user_name': DataMap['user_name'],
        'store_name': DataMap['store_name'] ?? DataMap['email'].split('@')[0],
        'profile_photo': DataMap['profile_photo'] ?? '',
        'store_availability': DataMap['store_availability'] ?? false,
        'pan_number': DataMap['pan_number'] ?? '',
        'aadhar_number': DataMap['aadhar_number'] ?? '',
        if (DataMap['location'] != null)
          'location': {
            'details': DataMap['location']['details'] ?? '',
            'latitude': DataMap['location']['latitude'] ?? '',
            'longitude': DataMap['location']['longitude'] ?? '',
          },
        if (DataMap['address'] != null)
          'address': {
            "location": DataMap['address']['location'],
            "latitude": DataMap['address']['latitude'],
            "longitude": DataMap['address']['longitude'],
            "hno": DataMap['address']['hno'],
            "pincode": DataMap['address']['pincode'],
            "landmark": DataMap['address']['landmark'],
            "type": DataMap['address']['type'],
          },
        if (DataMap['working_hours'] != null)
          'working_hours': {
            'start_time': DataMap['working_hours']['start_time'] ?? '',
            'end_time': DataMap['working_hours']['end_time'] ?? '',
          },
        'delivery_addresses': DataMap['delivery_addresses'] ?? [],
        'bank_name': DataMap['bank_name'] ?? '',
        'pincode': DataMap['pincode'] ?? '',
        'rating': DataMap['rating'] ?? '-',
        'followers': DataMap['followers'] ?? [],
        'followings': DataMap['followings'] ?? [],
        'cover_image': DataMap['cover_image'] ?? '',
        'account_number': DataMap['account_number'] ?? '',
        'ifsc_code': DataMap['ifsc_code'] ?? '',
        'phone': DataMap['phone'] ?? '',
        'upi_id': DataMap['upi_id'] ?? '',
        'user_type': DataMap['user_type'] ?? 'Vendor',
      };
      await UserPreferences.setUser(userProfileData);
      userData = UserPreferences.getUser();
      print("userData:: ${userData}");

      notifyListeners();
      return DataMap['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return "-1";
    }
  }

  Future<bool> tryAutoLogin() async {
    // print('auto');
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    } else {
      return true;

      // return true;
    }
  }

  //logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userData');
    await prefs.remove('feedData');
    await prefs.remove('menuData');
    await prefs.remove('user');
    await prefs.remove('isLogin');
    GoogleSignIn().signOut();
  }

  Future sendUserTypeRequest() async {
    final String url = 'https://app.cloudbelly.in/user-type';

    // Your request data
    Map<String, dynamic> requestData = {
      // "user_type": "vendor",
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestData),
      );
      print('response: ${jsonDecode(response.body)}}');
      if (response.statusCode == 200) {
        // Request was successful, handle the response here
        return jsonDecode(response.body);
      } else {
        // Request failed, handle the error
        return response.body;
      }
    } catch (error) {
      // Handle exceptions
      return "";
    }
  }

  Future<String> storeSetup1(
      user_name,
      pincode,
      profile_photo,
      location_details,
      latitude,
      longitude,
      store_name,
      max_order_capacity) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'user_name': user_name,
      "store_name": store_name,
      "pincode": pincode,
      "profile_photo": profile_photo,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
        "details": location_details,
      },
      "max_order_capacity": max_order_capacity,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      print(response.body);
      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> updateCoverImage(String cover_image, context) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'cover_image': cover_image,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print(response.body);
      int code = response.statusCode;
      notifyListeners();

      return code.toString();
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> updateStoreName(String name) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'store_name': name,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      print(jsonDecode(response.body));
      // int code = response.statusCode;
      // return code.toString();
      return jsonDecode(response.body);
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> updateMenuItem(String product_id, String price, String name,
      String type, String category) async {
    final String url = 'https://app.cloudbelly.in/product/update';
    // print(VEG);

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'product_id': product_id,
      'price': price,
      'category': category,
      'name': name,
      'type': type,
    };
    print("reqBody ${json.encode(requestBody)}");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print(response.body);
      int code = response.statusCode;
      return code.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> updateProfilePhoto(String profile_photo) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'profile_photo': profile_photo,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();
      print(response.body);
      return response.statusCode.toString();
    } catch (error) {
      notifyListeners();
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> userImage(user_image) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "profile_photo": user_image
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> storeName(store_name) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "store_name": store_name
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> workingHours(working_hours) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "working_hours": working_hours
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> email(email) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "email": email
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> contactNumber(contact_number) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "phone": contact_number
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> storeAvailability(store_availability) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "store_availability": store_availability
    };
    print("payloaddd ${json.encode(requestBody)}");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> addressUpdate(Map<String, dynamic> addressModel) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "address": addressModel
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

// kyc verification
  Future<String> storeSetup2(
      pan_number, aadhar_number, fssai_licence_document) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'pan_number': pan_number,
      "aadhar_number": aadhar_number,
      "fssai": fssai_licence_document,
      "kyc_status": "unverified"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> updateCustomerLocation(
      double? latitude, double? longitude, String area) async {
    var requestBodySearch;
    final String url = 'https://app.cloudbelly.in/update-user';

    requestBodySearch = {
      "latitude": latitude,
      "longitude": longitude,
      "area": area
    };
    print("locLogapiservice.dart $requestBodySearch");
    userData = UserPreferences.getUser();

    userData?['current_location'] = {
      "latitude": latitude,
      "longitude": longitude,
      "area": area
    };

    await UserPreferences.setUser(userData!);

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      "current_location": {
        "latitude": latitude,
        "longitude": longitude,
        "area": area
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();
      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> storeSetup3(bank_name, account_number, ifsc_code, upi_id,
      preferred_payment_method) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'bank_name': bank_name,
      "account_number": account_number,
      "ifsc_code": ifsc_code,
      "upi_id": upi_id,
      "preferred_payment_method": preferred_payment_method
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();

      return jsonDecode((response.body))['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return '-1';
    }
  }

  Future<String> pickImageAndUpoad(BuildContext context,
      {String src = 'Gallery'}) async {
    final picker = ImagePicker();
    // VideoPlaybackQuality;
    final pickedImage = await picker.pickImage(
      source: src == 'Gallery' ? ImageSource.gallery : ImageSource.camera,
    );
    if (pickedImage == null) return "";

    debugPrint('Image path: ${pickedImage.path}');

    // Compress the image first
    var compressedImage = await compressImage(pickedImage.path);
    if (compressedImage == null) {
      debugPrint('Error compressing image');
      return "";
    }

    try {
      final url = Uri.parse('https://app.cloudbelly.in/upload');
      final req = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromBytes('file', compressedImage,
            filename: 'compressed_image.jpg'));

      req.headers['Accept'] = '*/*';
      req.headers['User-Agent'] =
          'Thunder Client (https://www.thunderclient.com)';

      final stream = await req.send();
      final response = await http.Response.fromStream(stream);
      final status = response.statusCode;
      if (status != 200)
        throw Exception('http.send error: statusCode= $status');

      return json.decode(response.body)['file_url'];
    } catch (error) {
      if (error.toString().contains('413')) {
        return "file size very large";
      }
      return "Error uploading image: $error";
    }
  }

  Future<List<int>?> compressImage(String imagePath) async {
    try {
      var result = await FlutterImageCompress.compressWithFile(
        imagePath,
        minWidth: 1080, // Adjust the size according to your needs
        minHeight: 1920,
        quality: 50, // Adjust quality parameter as needed
      );

      return result;
    } catch (e) {
      debugPrint('Error in compressing file: $e');
      return null;
    }
  }

  Future<dynamic> ScanMenu(String src) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      imageQuality: 50,
      source: src == 'Camera' ? ImageSource.camera : ImageSource.gallery,
    );
    String imagePath = '';
    if (pickedImage == null) {
      return 'No image picked';
    }
    if (pickedImage != null) {
      imagePath = pickedImage.path;
      debugPrint('imaged path:');
      debugPrint(imagePath);
    }
    var compressedImage = await compressImage(pickedImage.path);
    if (compressedImage == null) {
      debugPrint('Error compressing image');
      return "";
    }

    try {
      final url = Uri.parse('https://app.cloudbelly.in/upload-menu');

//  List<int> imageBytes = File(compressedImage as String).readAsBytesSync();
      // String base64Image = base64Encode(compressedImage);

      final req = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      req.headers['Accept'] = '*/*';
      req.headers['User-Agent'] =
          'Thunder Client (https://www.thunderclient.com)';

      final stream = await req.send();
      final response = await http.Response.fromStream(stream);
      final status = response.statusCode;
      if (status != 200)
        throw Exception('http.send error: statusCode= $status');

      print(response.body);

      return jsonDecode((response.body));
    } catch (error) {
      if (error.toString().contains('413')) return "file size very large";
      return "";
    }
  }

  Future<String> AddProductsForMenu(List<dynamic> data) async {
    final String url = 'https://app.cloudbelly.in/product/add';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'products': data //email id here
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print(response.statusCode);
      print(response.body);
      final responseBody = jsonDecode(response.body);
      final code = responseBody['code'];

      return code.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> updateDescriptionAndType() async {
    final String url =
        'https://app.cloudbelly.in/product/update-default-description';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? ""
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      // print(response.statusCode);
      print("response.body ${response.body}");
      final responseBody = jsonDecode(response.body);
      final code = responseBody['code'];

      return code.toString();

      // return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> createPost(List<String> list, List<String> tags,
      String caption, List<dynamic> selectedMenuList) async {
    final String url = 'https://app.cloudbelly.in/metadata/feed';
    List<String> idList = [];

    for (var item in selectedMenuList) {
      idList.add(item["_id"]);
    }
    final Map<String, dynamic> requestBody = list.length == 1
        ? {
            'user_id': userData?['user_id'] ?? "",
            'tags': tags,
            "file_url": list[0],
            "caption": caption,
            "multiple_files": [],
            'menu_items': idList,
          }
        : {
            'user_id': userData?['user_id'] ?? "",
            'tags': tags,
            'file_url': list[0],
            "multiple_files": list,
            "caption": caption,
            'menu_items': idList,
          };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return jsonDecode((response.body))['message'];
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<List<String>> pickMultipleImagesAndUpoad() async {
    // Check and request permission if not granted
    // var status = await Permission.photos.request();
    List<XFile>? images = await ImagePicker().pickMultiImage();

    List<String> urlList = [];

    for (var image in images) {
      String imagePath = image.path;
      List<int>? compressedImageBytes = await compressImage(imagePath);
      if (compressedImageBytes == null) {
        urlList.add("Error compressing image");
        continue;
      }

      try {
        final url = Uri.parse('https://app.cloudbelly.in/upload');
        final req = http.MultipartRequest('POST', url)
          ..files.add(http.MultipartFile.fromBytes(
            'file',
            compressedImageBytes,
            filename:
                'compressed_image.jpg', // You might want to generate a more descriptive name
          ));
        // req.heade/rs = headers;
        req.headers['Accept'] = '*/*';
        req.headers['User-Agent'] =
            'Thunder Client (https://www.thunderclient.com)';

        final stream = await req.send();
        final response = await http.Response.fromStream(stream);
        final status = response.statusCode;
        if (status != 200) throw Exception('HTTP error: statusCode= $status');

        urlList.add(json.decode(response.body)['file_url']);
      } catch (error) {
        if (error.toString().contains('413')) {
          urlList.add("File size very large");
        } else {
          urlList.add("Error uploading image: $error");
        }
      }
    }

    return urlList;
  }

  Future<dynamic> getFeed(String? userId) async {
    final String url = '${baseUrl}metadata/get-posts';

    final Map<String, dynamic> requestBody = {
      'user_id': userId,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // print(jsonDecode((response.body)));
      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> getGlobalFeed(int index) async {
    final String url = 'https://app.cloudbelly.in/get-posts';
    final data = {
      "page": index,
      "limit": 10,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      // print(jsonDecode((response.body)));
      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> getMenu(String? userId) async {
    final String url = '${baseUrl}product/get';

    final Map<String, dynamic> requestBody = {
      'user_id': userId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      log("menudata:: ${jsonDecode((response.body))}");
      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> follow(String id) async {
    final String url = 'https://app.cloudbelly.in/follow';

    final Map<String, dynamic> requestBody = {
      "current_user_id": userData?['user_id'],
      "profile_user_id": id,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      notifyListeners();
      return {
        'body': jsonDecode((response.body)),
        'code': response.statusCode,
      };
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> unfollow(String id) async {
    final String url = 'https://app.cloudbelly.in/unfollow';

    final Map<String, dynamic> requestBody = {
      "current_user_id": userData?['user_id'] ?? "",
      "profile_user_id": id,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print(response.body);
      notifyListeners();
      return {
        'body': jsonDecode((response.body)),
        'code': response.statusCode,
      };
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> updateProductImage(
      String product_id, BuildContext context, String src) async {
    final String url = 'https://app.cloudbelly.in/product/update';

    List<String> list = [];
    if (src == 'Gallery') {
      final img = await pickImageAndUpoad(context);
      list = img != '' ? [img] : [];
    } else {
      String temp = await pickImageAndUpoad(src: 'Camera', context);
      if (temp != '') list.add(temp);
    }
    // print('llll${list[0]}gshgd');
    if (list.length != 0) {
      if (list.contains('file size very large')) {
        TOastNotification().showErrorToast(context, 'File size very Large');
      } else {
        final Map<String, dynamic> requestBody = {
          'user_id': userData?['user_id'] ?? "",
          'product_id': product_id,
          'images': list,
        };

        try {
          await http.post(
            Uri.parse(url),
            headers: {
              'Accept': '*/*',
              'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          );
          TOastNotification().showSuccesToast(context, 'Image updated ');

          return list[0];
        } catch (error) {
          // Handle exceptions
          return '-1';
        }
      }
    }
  }

  Future<dynamic> updateProductImageusingAI(
      String product_id, String description, BuildContext context) async {
    final String url = 'https://app.cloudbelly.in/product/update-ai-image';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      '_id': product_id,
      'description': description,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      TOastNotification().showSuccesToast(context, 'Image updated ');
      final responseBody = jsonDecode(response.body);
      print("resim ${jsonDecode(response.body)}");
      return responseBody['url'];
    } catch (error) {
      // Handle exceptions
      return 'https://via.placeholder.com/150';
    }
  }

  Future<dynamic> updateProductDetails(
      String product_id, String price, String description) async {
    final String url = 'https://app.cloudbelly.in/product/update';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {};
    price != ''
        ? requestBody = {
            'user_id': userData?['user_id'] ?? "",
            'product_id': product_id,
            'price': price,
          }
        : requestBody = {
            'user_id': userData?['user_id'] ?? "",
            'product_id': product_id,
            'description': description,
          };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> updateProductStockStatus(
      String product_id, bool status, BuildContext context) async {
    final String url = 'https://app.cloudbelly.in/product/update';

    final Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'product_id': product_id,
      'stock_status': status,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      TOastNotification().showSuccesToast(context, 'Status updated ');
      final responseBody = jsonDecode(response.body);
      print("resim ${jsonDecode(response.body)}");
      return responseBody;
    } catch (error) {
      // Handle exceptions
      return -1;
    }
  }

  Future<String> commentPost(String id, String comment) async {
    final String url = 'https://app.cloudbelly.in/update-posts';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
      'post_id': id,
      'comment': comment,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print(response.body);
      print(response.statusCode);

      return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> deleteComment(String id, String comment) async {
    final String url = 'https://app.cloudbelly.in/delete-comment';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
      'post_id': id,
      'comment_text': comment,
      'comment_user_id': userData?['user_id'] ?? "",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print(response.body);
      print(response.statusCode);

      return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  //send otp
  Future<String> sendOtp(String mobile_no) async {
    final String url = 'https://app.cloudbelly.in/otp/send_otp';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {"mobile_no": mobile_no};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("otpSentResp:: ${response.body}");
      print(response.statusCode);

      return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String mobile_no, String otp) async {
    const String url = 'https://app.cloudbelly.in/otp/verify_otp';

    Map<String, dynamic> requestBody = {
      "mobile_no": mobile_no,
      "otp": otp,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("otpSentResp:: ${response.body}");
      return jsonDecode(response.body);
    } catch (error) {
      print("$error error");
      // Handle exceptions
      return {'code': 500, 'message': 'An error occurred'};
    }
  }

  Future<String> deleteProfile(String mobile_no) async {
    const String url = 'https://app.cloudbelly.in/delete-profile';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {"mobile_no": mobile_no};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("otpSentResp:: ${response.body}");
      print(response.statusCode);

      return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> likePost(String id, String userId) async {
    final String url = 'https://app.cloudbelly.in/update-posts';
    print("likeResp");
    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": userId,
      'post_id': id,
      'like_user_id': userData?['user_id'] ?? "",
    };

    print("requestBody:: ${requestBody}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("likeResponse:: ${response.body}");
      print(response.statusCode);
      notifyListeners();
      return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> deletePost(String id) async {
    final String url = 'https://app.cloudbelly.in/delete-posts';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
      'post_id': id,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print(response.body);
      print(response.statusCode);

      return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<String> postalCodeCheck(String code) async {
    final String url = 'https://api.postalpincode.in/pincode/$code';

    // bool _isOK = false;

    try {
      final response = await http.get(
        Uri.parse(url),
        // headers: headers,
      );
      // print(response.body);
      // print((response.body)['Status']);

      return jsonDecode((response.body))[0]['Status'];
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<List<dynamic>> getUserInfo(List<dynamic> list) async {
    final String url = 'https://app.cloudbelly.in/get-user-info';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_ids": list,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      // print(response.body);
      // print(response.statusCode);
      notifyListeners();
      return jsonDecode(response.body) as List<dynamic>;
    } catch (error) {
      // Handle exceptions
      return ['-1'];
    }
  }

  Future<List<ProductDetails>> getProductDetails(List<dynamic> list) async {
    print("list:: $list");
    final String url = '${baseUrl}get_products';
    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "item_ids": list,
      "user_id": userData?['user_id'] ?? "",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      // print(response.body);
      // print(response.statusCode);

      // Parse the response body
      List<dynamic> jsonResponse = jsonDecode(response.body);

      List<ProductDetails> productList =
          jsonResponse.map((json) => ProductDetails.fromJson(json)).toList();
      notifyListeners();
      return productList;
    } catch (error) {
      // Handle exceptions
      print("error:$error");
      notifyListeners();
      return <ProductDetails>[];
    }
  }

  Future<DeliveryAddressModel> getAddressList() async {
    final String url = '${baseUrl}get-delivery-addresses';
    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      // print(response.body);
      // print(response.statusCode);

      // Parse the response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      log("jsonData:: $responseData");
      notifyListeners();
      return DeliveryAddressModel.fromJson(responseData);
    } catch (error) {
      // Handle exceptions
      print("error:$error");
      notifyListeners();
      return DeliveryAddressModel();
    }
  }

  Future<dynamic> createProductOrder(List<dynamic> list,
      AddressModel? addressModel, String userId, double deliveryFee) async {
    print("list:: $list");
    final String url = '${baseUrl}order/create';
    print(userData?['user_id']);
    // bool _isOK = false;

    Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
      "items": list,
      "order_from_user_id": userId,
      "location": addressModel,
      "deliveryFee": deliveryFee
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("paysucreateorder  ${jsonEncode(requestBody)}");
      // print(response.statusCode);

      // Parse the response body
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      notifyListeners();
      return jsonResponse;
    } catch (error) {
      // Handle exceptions
      print("error:$error");
      notifyListeners();
      return null;
    }
  }

//for user info by Key
  Future<dynamic> getUserDataByKey(
      String userId, List<String> projectKey) async {
    final String url = '${baseUrl}get-user-details-by-key';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {};
    requestBody = {"user_id": userId, "keys": projectKey};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("userDetailsForKey:: ${response.body}");

      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return {};
    }
  }

// for getting upi
  Future<dynamic> getSellerQr(String? orderId, id, amount) async {
    final String url = '${baseUrl}order/upi';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {};
    requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'order_id': orderId,
      "order_from_user_id": id,
      'amount': amount,
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("jsonResponse:: ${response.body}");

      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> submitOrder(String? orderId, String? paymentMode, id) async {
    final String url = '${baseUrl}order/submit';
    final String url2 = '${baseUrl}order/paid';
    // bool _isOK = false;
    Map<String, dynamic> requestBody = {};
    requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'order_id': orderId,
      "order_from_user_id": id,
      'payment_mode': "upi",
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final response2 = await http.post(
        Uri.parse(url2),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("jsonResponse:: ${response.body}");
      print("jsonResponse:: ${response2.body}");

      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<List<UserModel>> getUserDetails(List<String> userIds) async {
    print("list:: $userIds");
    final String url = '${baseUrl}get-user-info';
    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_ids": userIds,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      // print(response.body);
      // print(response.statusCode);

      // Parse the response body
      List<dynamic> jsonResponse = jsonDecode(response.body);

      List<UserModel> userList =
          jsonResponse.map((json) => UserModel.fromJson(json)).toList();
      print("ucidi: ${userList[0]}  ${userList[0].followings?.length}");
      notifyListeners();
      return userList;
    } catch (error) {
      // Handle exceptions
      print("error:$error");
      notifyListeners();
      return <UserModel>[];
    }
  }

  Future<String> addAddress(
      /*AddressModel addressModel*/
      Map<String, dynamic> addressModel) async {
    final prefs = await SharedPreferences.getInstance();
    print('addressModel:: ${jsonEncode(addressModel)}');
    final String url = '${baseUrl}update-delivery-address';

    final Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
      "address": addressModel,
    };
    // Login successful
    print("resquestbody:: $requestBody");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("response:: ${response.body}");
      final DataMap = jsonDecode(response.body);
      return DataMap['message'];
    } catch (error) {
      notifyListeners();

      // Handle exceptions
      return "-1";
    }
  }

  Future<dynamic> getInventoryData() async {
    // id = '65e31e9f0bf98389f417cf71';
    final String url = 'https://app.cloudbelly.in/inventory/get-data';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': '*/*',
          'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8',
          'Connection': 'keep-alive',
          'Content-Type': 'application/json',
          'Origin': 'https://app.cloudbelly.in',
          'Referer': 'https://app.cloudbelly.in/inventory',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
        },
        body: jsonEncode(requestBody),
      );
      // print('response: ${response.body}');
      // print(response.statusCode);

      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> cartInventory(List<dynamic> data) async {
    // id = '65e31e9f0bf98389f417cf71';
    final String url = 'https://app.cloudbelly.in/cart/add';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'items': data
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': '*/*',
          'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8',
          'Connection': 'keep-alive',
          'Content-Type': 'application/json',
          'Origin': 'https://app.cloudbelly.in',
          'Referer': 'https://app.cloudbelly.in',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
        },
        body: jsonEncode(requestBody),
      );
      // print('response: ${response.body}');
      // print(response.statusCode);

      return jsonDecode(response.body);
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  Future<dynamic> saveInventoryData(List<dynamic> data) async {
    // id = '65e31e9f0bf98389f417cf71';
    final String url = 'https://app.cloudbelly.in/inventory/save-data';
    print(data);
    // bool _isOK = false;

    List<dynamic> _newList = [];
    for (int i = 0; i < data.length; i++) {
      _newList.add({
        "itemId": data[i]['itemId'],
        "itemName": data[i]['itemName'],
        "pricePerUnit": data[i]['pricePerUnit'],
        "purchaseDate": data[i]['purchaseDate'],
        "sellingDate": data[i]['sellingDate'],
        "sellingPrice": data[i]['sellingPrice'],
        // "shelf_life": "",
        "unitType": data[i]['unitType'],
        "volumeLeft": data[i]['volumeLeft'],
        "volumePurchased": data[i]['volumePurchased'],
        "volumeSold": data[i]['volumeSold'],
      });
    }
    print('new: $_newList');
    Map<String, dynamic> requestBody = {
      'user_id': userData?['user_id'] ?? "",
      'data': _newList
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': '*/*',
          'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8',
          'Connection': 'keep-alive',
          'Content-Type': 'application/json',
          'Origin': 'https://app.cloudbelly.in',
          'Referer': 'https://app.cloudbelly.in/inventory',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
        },
        body: jsonEncode(requestBody),
      );
      // pr/int(response.body);
      // print(response.statusCode);

      return {
        'body': jsonDecode(response.body),
        'code': response.statusCode,
      };
    } catch (error) {
      // Handle exceptions
      return {'Error': error};
    }
  }

  void setUserData(Map<String, dynamic> newUserData) {
    userData = newUserData;
    notifyListeners();
  }

  Future<void> deleteMenuItem(productId) async {
    print("$productId  delete product_id");
    final String url = '${baseUrl}product/delete';

    final Map<String, dynamic> requestBody = {
      "user_id": userData?['user_id'] ?? "",
      "product_id": productId,
    };
    // Login successful
    print("resquestbody:: $requestBody");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("response:: ${response.body}");
      final DataMap = jsonDecode(response.body);
      return DataMap['message'];
    } catch (error) {
      // Handle exceptions
    }
  }
}

class TransitionEffect with ChangeNotifier {
  //bool _isModalButtomSheetActive = false;
  //double _blurSigma = 0;

  // bool get isModalButtomSheetActive => _isModalButtomSheetActive;

  //double get blurSigma => _blurSigma;

  void setBlurSigma(blurSigma) {
    if (blurSigma < 4) {
      //   _blurSigma = 0;
    } else {
//_blurSigma = blurSigma;
    }
    notifyListeners();
  }
}
