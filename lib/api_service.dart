import 'dart:convert';
import 'dart:io';

import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Auth {
  static final Auth _instance = Auth._internal();

  // Your global variables go here

  factory Auth() {
    return _instance;
  }

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

  String get_user_id() {
    return user_id;
  }

  final headers = {
    'Accept': '*/*',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    'Content-Type': 'application/json',
  };
  Auth._internal();
}

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
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    print(jsonDecode((response.body)));
    return jsonDecode((response.body))['message'];
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<String> login(email, pass) async {
  final String url = 'https://app.cloudbelly.in/login';

  final Map<String, dynamic> requestBody = {
    "email": email,
    "password": pass,
  };
  // Login successful

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    print('user data:');
    print(jsonDecode((response.body)));
    Auth().user_id = jsonDecode((response.body))['user_id'];
    Auth().user_email = jsonDecode((response.body))['email'];
    Auth().store_name = jsonDecode((response.body))['store_name'] ?? '';
    Auth().logo_url = jsonDecode((response.body))['profile_photo'] ?? '';
    Auth().pan_number = jsonDecode((response.body))['pan_number'] ?? '';
    Auth().bank_name = jsonDecode((response.body))['bank_name'] ?? '';
    Auth().pincode = jsonDecode((response.body))['pincode'] ?? '';
    Auth().rating = jsonDecode((response.body))['rating'] ?? '-';
    Auth().followers = jsonDecode((response.body))['followers'] ?? [];
    Auth().followings = jsonDecode((response.body))['followings'] ?? [];
    Auth().cover_image = jsonDecode((response.body))['cover_image'] ?? '';
    Auth().store_name = Auth().store_name == ''
        ? Auth().user_email.split('@')[0]
        : Auth().store_name;
    Auth().logo_url = Auth().logo_url == '' ? '' : Auth().logo_url;
    return jsonDecode((response.body))['message'];
  } catch (error) {
    // Handle exceptions
    return "-1";
  }
}

Future sendUserTypeRequest() async {
  final String url = 'https://app.cloudbelly.in/user-type';

  // Your request data
  Map<String, dynamic> requestData = {
    "user_type": "vendor",
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestData),
    );

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

Future<String> storeSetup1(user_name, pincode, profile_photo, location_details,
    latitude, longitude, store_name, max_order_capacity) async {
  final String url = 'https://app.cloudbelly.in/update-user';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
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
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    print(response.body);
    return jsonDecode((response.body))['message'];
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<String> updateCoverImage(String cover_image) async {
  final String url = 'https://app.cloudbelly.in/update-user';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
    'cover_image': cover_image,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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

Future<String> updateStoreName(String name) async {
  final String url = 'https://app.cloudbelly.in/update-user';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
    'store_name': name,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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

Future<String> updateMenuItem(String product_id, String price, String name,
    bool VEG, String category) async {
  final String url = 'https://app.cloudbelly.in/product/update';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
    'product_id': product_id,
    'price': price,
    'category': category,
    'name': name,
    'VEG': VEG,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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
    'user_id': Auth().user_id,
    'profile_photo': profile_photo,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    print(response.body);
    return response.statusCode.toString();
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<String> storeSetup2(
    pan_number, aadhar_number, fssai_licence_document) async {
  final String url = 'https://app.cloudbelly.in/update-user';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
    'pan_number': pan_number,
    "aadhar_number": aadhar_number,
    "fssai_licence_document": fssai_licence_document,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    return jsonDecode((response.body))['message'];
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<String> storeSetup3(bank_name, account_number, ifsc_code, upi_id) async {
  final String url = 'https://app.cloudbelly.in/update-user';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
    'bank_name': bank_name,
    "account_number": account_number,
    "ifsc_code": ifsc_code,
    "upi_id": upi_id,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    return jsonDecode((response.body))['message'];
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<String> pickImageAndUpoad(BuildContext context,
    {String src = 'Gallery'}) async {
  final picker = ImagePicker();
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
    if (status != 200) throw Exception('http.send error: statusCode= $status');

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
      quality: 85, // Adjust quality parameter as needed
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
    if (status != 200) throw Exception('http.send error: statusCode= $status');

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
    'user_id': Auth().user_id,
    'products': data //email id here
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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

Future<dynamic> getSheetUrl() async {
  final String url = 'https://app.cloudbelly.in/inventory/get-sheet';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
    'user_email': Auth().user_email, //email id here
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    return jsonDecode((response.body));
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<dynamic> SyncInventory() async {
  final String url = 'https://app.cloudbelly.in/inventory/sync';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
    'user_email': Auth().user_email, //email id here
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    // print(response.body);
    return jsonDecode((response.body));
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<String> createPost(
    List<String> list, List<String> tags, String caption) async {
  final String url = 'https://app.cloudbelly.in/metadata/feed';

  final Map<String, dynamic> requestBody = list.length == 1
      ? {
          'user_id': Auth().user_id,
          'tags': tags,
          "file_url": list[0],
          "caption": caption,
          "multiple_files": [],
        }
      : {
          'user_id': Auth().user_id,
          'tags': tags,
          'file_url': list[0],
          "multiple_files": list,
          "caption": caption,
        };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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
      // req.heade/rs = Auth().headers;
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
    'user_id': Auth().user_id,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    return jsonDecode((response.body));
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<dynamic> getMenu() async {
  final String url = 'https://app.cloudbelly.in/product/get';

  final Map<String, dynamic> requestBody = {
    'user_id': Auth().user_id,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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
    list = await pickMultipleImagesAndUpoad();
  } else {
    String temp = await pickImageAndUpoad(src: 'Camera', context);
    if (temp != '') list.add(temp);
  }
  if (list.length != 0) {
    if (list.contains('file size very large')) {
      TOastNotification().showErrorToast(context, 'File size very Large');
    } else {
      final Map<String, dynamic> requestBody = {
        'user_id': Auth().user_id,
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
          'user_id': Auth().user_id,
          'product_id': product_id,
          'price': price,
        }
      : requestBody = {
          'user_id': Auth().user_id,
          'product_id': product_id,
          'description': description,
        };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    return jsonDecode((response.body));
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<dynamic> getInventoryData() async {
  final String url = 'https://app.cloudbelly.in/inventory/data';

  // bool _isOK = false;
  Map<String, dynamic> requestBody = {
    "user_id": Auth().user_id,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
      body: jsonEncode(requestBody),
    );
    return jsonDecode((response.body));
  } catch (error) {
    // Handle exceptions
    return '-1';
  }
}

Future<String> commentPost(String id, String comment) async {
  final String url = 'https://app.cloudbelly.in/update-posts';

  // bool _isOK = false;
  Map<String, dynamic> requestBody = {
    "user_id": Auth().user_id,
    'post_id': id,
    'comment': comment,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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

Future<String> likePost(String id) async {
  final String url = 'https://app.cloudbelly.in/update-posts';

  // bool _isOK = false;
  Map<String, dynamic> requestBody = {
    "user_id": Auth().user_id,
    'post_id': id,
    'like_user_id': Auth().user_id,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: Auth().headers,
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
