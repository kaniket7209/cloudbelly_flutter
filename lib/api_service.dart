// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

// import 'dart:html';

import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  // static final Auth _instance = Auth._internal();

  // Your global variables go here

  // factory Auth() {
  //   return _instance;
  // }

  String user_id = '';
  String user_email = '';
  String store_name = '';
  String logo_url = '';
  String pan_number = '';
  String bank_name = '';
  String pincode = '';
  String cover_image = '';
  String rating = '-';
  List<dynamic> followers = [];
  List<dynamic> followings = [];
  String userType = '';

  // get user_logo_url {
  //   notifyListeners();
  //   return logo_url;
  // }

  String get_user_id() {
    return user_id;
  }

  final headers = {
    'Accept': '*/*',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    'Content-Type': 'application/json',
  };
  // Auth._internal();

  Future<String> signUp(email, pass, phone, type) async {
    final String url = 'https://app.cloudbelly.in/signup';

    final Map<String, dynamic> requestBody = {
      "email": email,
      "password": pass,
      "phone": "1234567890",
      "user_type": type
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print(jsonDecode((response.body)));
      notifyListeners();
      return jsonDecode((response.body))['message'];
    } catch (error) {
      // Handle exceptions
      notifyListeners();
      return '-1';
    }
  }

  Future<String> login(email, pass) async {
    final prefs = await SharedPreferences.getInstance();
    final String url = 'https://app.cloudbelly.in/login';

    final Map<String, dynamic> requestBody = {
      "email": email,
      "password": pass,
    };
    // Login successful

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final DataMap = jsonDecode(response.body);
      print('user data:${DataMap}');
      user_id = DataMap['user_id'];
      user_email = DataMap['email'];
      store_name = DataMap['store_name'] ?? '';
      logo_url = DataMap['profile_photo'] ?? '';
      pan_number = DataMap['pan_number'] ?? '';
      bank_name = DataMap['bank_name'] ?? '';
      pincode = DataMap['pincode'] ?? '';
      rating = DataMap['rating'] ?? '-';
      followers = DataMap['followers'] ?? [];
      followings = DataMap['followings'] ?? [];
      cover_image = DataMap['cover_image'] ?? '';
      store_name = store_name == '' ? user_email.split('@')[0] : store_name;
      userType = DataMap['user_type'] ?? 'Vendor';
      notifyListeners();
      final userData = json.encode(
        {'email': email, 'password': pass},
      );
      prefs.setString('userData', userData);
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
      'user_id': user_id,
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
      'user_id': user_id,
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
      'user_id': user_id,
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
      bool VEG, String category) async {
    final String url = 'https://app.cloudbelly.in/product/update';
    // print(VEG);

    final Map<String, dynamic> requestBody = {
      'user_id': user_id,
      'product_id': product_id,
      'price': price,
      'category': category,
      'name': name,
      'VEG': VEG,
    };

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
      'user_id': user_id,
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

  Future<String> storeSetup2(
      pan_number, aadhar_number, fssai_licence_document) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': user_id,
      'pan_number': pan_number,
      "aadhar_number": aadhar_number,
      "fssai_licence_document": fssai_licence_document,
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

  Future<String> storeSetup3(
      bank_name, account_number, ifsc_code, upi_id) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    final Map<String, dynamic> requestBody = {
      'user_id': user_id,
      'bank_name': bank_name,
      "account_number": account_number,
      "ifsc_code": ifsc_code,
      "upi_id": upi_id,
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
      'user_id': user_id,
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

      return response.statusCode.toString();
    } catch (error) {
      // Handle exceptions
      return '-1';
    }
  }

  // Future<dynamic> getSheetUrl() async {
  //   final String url = 'https://app.cloudbelly.in/inventory/get-sheet';

  //   final Map<String, dynamic> requestBody = {
  //     'user_id': user_id,
  //     'user_email': user_email, //email id here
  //   };

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(requestBody),
  //     );
  //     print(jsonDecode((response.body)));

  //     return jsonDecode((response.body));
  //   } catch (error) {
  //     // Handle exceptions
  //     return '-1';
  //   }
  // }

  // Future<dynamic> SyncInventory() async {
  //   final String url = 'https://app.cloudbelly.in/inventory/sync';

  //   final Map<String, dynamic> requestBody = {
  //     'user_id': user_id,
  //     'user_email': user_email, //email id here
  //   };

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(requestBody),
  //     );
  //     print(response.body);

  //     return jsonDecode((response.body));
  //   } catch (error) {
  //     // Handle exceptions
  //     return '-1';
  //   }
  // }

  Future<String> createPost(List<String> list, List<String> tags,
      String caption, List<dynamic> selectedMenuList) async {
    final String url = 'https://app.cloudbelly.in/metadata/feed';
    List<String> idList = [];

    for (var item in selectedMenuList) {
      idList.add(item["_id"]);
    }
    final Map<String, dynamic> requestBody = list.length == 1
        ? {
            'user_id': user_id,
            'tags': tags,
            "file_url": list[0],
            "caption": caption,
            "multiple_files": [],
            'menu_items': idList,
          }
        : {
            'user_id': user_id,
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

  Future<dynamic> getFeed() async {
    final String url = 'https://app.cloudbelly.in/metadata/get-posts';

    final Map<String, dynamic> requestBody = {
      'user_id': user_id,
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

  Future<dynamic> getMenu() async {
    final String url = 'https://app.cloudbelly.in/product/get';

    final Map<String, dynamic> requestBody = {
      'user_id': user_id,
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
          'user_id': user_id,
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

  Future<dynamic> updateProductDetails(
      String product_id, String price, String description) async {
    final String url = 'https://app.cloudbelly.in/product/update';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {};
    price != ''
        ? requestBody = {
            'user_id': user_id,
            'product_id': product_id,
            'price': price,
          }
        : requestBody = {
            'user_id': user_id,
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

  // Future<dynamic> getInventoryData() async {
  //   final String url = 'https://app.cloudbelly.in/inventory/data';

  //   // bool _isOK = false;
  //   Map<String, dynamic> requestBody = {
  //     "user_id": user_id,
  //   };

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(requestBody),
  //     );

  //     return jsonDecode((response.body));
  //   } catch (error) {
  //     // Handle exceptions
  //     return '-1';
  //   }
  // }

  Future<String> commentPost(String id, String comment) async {
    final String url = 'https://app.cloudbelly.in/update-posts';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": user_id,
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
      "user_id": user_id,
      'post_id': id,
      'comment_text': comment,
      'comment_user_id': user_id,
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

  Future<String> likePost(String id, String userId) async {
    final String url = 'https://app.cloudbelly.in/update-posts';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": userId,
      'post_id': id,
      'like_user_id': user_id,
    };

    print(requestBody);

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

  Future<String> deletePost(String id) async {
    final String url = 'https://app.cloudbelly.in/delete-posts';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": user_id,
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

      return jsonDecode(response.body) as List<dynamic>;
    } catch (error) {
      // Handle exceptions
      return ['-1'];
    }
  }

  Future<dynamic> getInventoryData() async {
    print(user_id);
    // id = '65e31e9f0bf98389f417cf71';
    final String url = 'https://app.cloudbelly.in/inventory/get-data';

    // bool _isOK = false;
    Map<String, dynamic> requestBody = {
      "user_id": user_id,
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
      'user_id': user_id,
      'data': _newList
      // {
      //   "itemId": "1",
      //   "itemName": "Aloo",
      //   "pricePerUnit": "20",
      //   "unitType": "kg",
      //   "purchaseDate": "2024-03-02",
      //   "volumePurchased": "200",
      //   "volumeSold": "0",
      //   "volumeLeft": "200",
      //   "sellingPrice": "",
      //   "sellingDate": ""
      // }
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
}
