import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

class Auth {
  static final Auth _instance = Auth._internal();

  // Your global variables go here

  factory Auth() {
    return _instance;
  }

  String user_id = '';
  String user_email = '';

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

    Auth().user_id = jsonDecode((response.body))['user_id'];
    Auth().user_email = jsonDecode((response.body))['email'];
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
    return jsonDecode((response.body))['message'];
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

Future<File> compressImage(String imagePath) async {
  // Get the original image file
  // File imageFile = File(imagePath);

  // Compress the image
  Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
    imagePath,
    quality: 85, // Adjust the quality as needed
  );

  // Create a new file for the compressed image
  File compressedImage = File(imagePath.split('.').first + '_compressed.jpg');

  // Write the compressed bytes to the new file
  await compressedImage.writeAsBytes(compressedBytes!);

  return compressedImage;
}

Future<String> pickImageAndUpoad(
  BuildContext context, {
  String src = 'Gallery',
}) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(
    source: src == 'Gallery' ? ImageSource.gallery : ImageSource.camera,
  );
  String imagePath = '';
  if (pickedImage != null) {
    imagePath = pickedImage.path;
    debugPrint('imaged added');
    debugPrint(imagePath);
  }
  try {
    final url = Uri.parse('https://app.cloudbelly.in/upload');

    final req = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    req.headers['Accept'] = '*/*';
    req.headers['User-Agent'] =
        'Thunder Client (https://www.thunderclient.com)';

    final stream = await req.send();
    final response = await http.Response.fromStream(stream);
    final status = response.statusCode;
    if (status != 200) throw Exception('http.send error: statusCode= $status');

    return jsonDecode((response.body))['file_url'];
  } catch (error) {
    if (error.toString().contains('413')) {
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('File Size large'),
      //       content: Text('If you want we can Compress this file'),
      //       actions: <Widget>[
      //         TextButton(
      //           onPressed: () async {
      //             var result = await FlutterImageCompress.compressWithFile(
      //               imagePath,
      //               minWidth: 2300,
      //               minHeight: 1500,
      //               quality: 94,
      //               rotate: 90,
      //             );
      //             File file = File(filePath);
      //             await file.writeAsBytes(uint8List);
      //             print(result!.length);
      //           },
      //           child: Text('Compress'),
      //         ),
      //         Space(isHorizontal: true, 100),
      //         TextButton(
      //           onPressed: () {
      //             // Close the dialog
      //             Navigator.of(context).pop();
      //           },
      //           child: Text('Close'),
      //         ),
      //       ],
      //     );
      //   },
      // );
      return "file size very large";
    }
    return "";
  }
}

Future<dynamic> ScanMenu(String src) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(
    source: src == 'Camera' ? ImageSource.camera : ImageSource.gallery,
  );
  String imagePath = '';
  if (pickedImage != null) {
    imagePath = pickedImage.path;
    debugPrint('imaged added');
    debugPrint(imagePath);
  }
  try {
    final url = Uri.parse('https://app.cloudbelly.in/upload-menu');

    final req = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    req.headers['Accept'] = '*/*';
    req.headers['User-Agent'] =
        'Thunder Client (https://www.thunderclient.com)';

    final stream = await req.send();
    final response = await http.Response.fromStream(stream);
    final status = response.statusCode;
    if (status != 200) throw Exception('http.send error: statusCode= $status');

    // print(response.body);

    return jsonDecode((response.body));
  } catch (error) {
    if (error.toString().contains('413')) return "file size very large";
    return "";
  }
}

Future<dynamic> AddProductsForMenu(List<dynamic> data) async {
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
    return jsonDecode((response.body));
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
  List<String> selectedImages = [];
  // Check and request permission if not granted
  // var status = await Permission.photos.request();
  List<XFile>? images = await ImagePicker().pickMultiImage();
  selectedImages = images.map((image) => image.path).toList();
  List<String> UrlList = [];

  for (int i = 0; i < selectedImages.length; i++) {
    try {
      final url = Uri.parse('https://app.cloudbelly.in/upload');

      final req = http.MultipartRequest('POST', url)
        ..files
            .add(await http.MultipartFile.fromPath('file', selectedImages[i]));

      req.headers['Accept'] = '*/*';
      req.headers['User-Agent'] =
          'Thunder Client (https://www.thunderclient.com)';

      final stream = await req.send();
      final response = await http.Response.fromStream(stream);
      final status = response.statusCode;
      if (status != 200)
        throw Exception('http.send error: statusCode= $status');

      UrlList.add(jsonDecode((response.body))['file_url']);
      // return jsonDecode((response.body))['file_url'];
    } catch (error) {
      if (error.toString().contains('413')) {
        UrlList.add("file size very large");
      }
      UrlList.add("");
    }
  }
  return UrlList;
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
        return jsonDecode((response.body));
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
