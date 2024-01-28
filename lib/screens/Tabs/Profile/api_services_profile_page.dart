import 'dart:convert';

import 'package:cloudbelly_app/screens/Login/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Home/api_service.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:multiple_images_picker/multiple_images_picker.dart';

class ProfileApi {
  Future<String> createPost(
      List<String> list, List<String> tags, String caption) async {
    final String url = 'https://app.cloudbelly.in/metadata/feed';

    final Map<String, dynamic> requestBody = list.length == 1
        ? {
            'user_id': AuthApi().user_id,
            'tags': tags,
            "file_url": list[0],
            "caption": caption,
            "multiple_files": [],
          }
        : {
            'user_id': AuthApi().user_id,
            'tags': tags,
            'file_url': list[0],
            "multiple_files": list,
            "caption": caption,
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
      print(response.body);
      print(response.statusCode);
      return jsonDecode((response.body))['message'];
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
      return '-1';
    }
  }

  Future<List<String>> pickMultipleImagesAndUpoad() async {
    List<String> selectedImages = [];
    // Check and request permission if not granted
    // var status = await Permission.photos.request();
    List<XFile>? images = await ImagePicker().pickMultiImage();
    selectedImages = images.map((image) => image.path).toList();
    print(selectedImages);
    List<String> UrlList = [];

    for (int i = 0; i < selectedImages.length; i++) {
      try {
        final url = Uri.parse('https://app.cloudbelly.in/upload');

        final req = http.MultipartRequest('POST', url)
          ..files.add(
              await http.MultipartFile.fromPath('file', selectedImages[i]));

        req.headers['Accept'] = '*/*';
        req.headers['User-Agent'] =
            'Thunder Client (https://www.thunderclient.com)';

        final stream = await req.send();
        final response = await http.Response.fromStream(stream);
        final status = response.statusCode;
        if (status != 200)
          throw Exception('http.send error: statusCode= $status');

        print(response.body);

        print(jsonDecode((response.body))['file_url']);
        UrlList.add(jsonDecode((response.body))['file_url']);
        // return jsonDecode((response.body))['file_url'];
      } catch (error) {
        print(error);
        if (error.toString().contains('413')) {
          UrlList.add("file size very large");
        }
        UrlList.add("");
      }
    }
    print(UrlList);
    return UrlList;
  }

  Future<dynamic> getFeed() async {
    final String url = 'https://app.cloudbelly.in/metadata/get-posts';

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
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
      print(response.body);
      print(response.statusCode);
      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
      return '-1';
    }
  }

  Future<dynamic> getMenu() async {
    final String url = 'https://app.cloudbelly.in/product/get';

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
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
      print(response.body);
      print(response.statusCode);
      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
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
      String temp = await HomeApi().pickImageAndUpoad(src: 'Camera');
      if (temp != '') list.add(temp);
    }
    print(list);
    if (list.length != 0) {
      print(list.length.toString());
      if (list.contains('file size very large')) {
        TOastNotification().showErrorToast(context, 'File size very Large');
      } else {
        final Map<String, dynamic> requestBody = {
          'user_id': AuthApi().user_id,
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
          print(response.body);
          print(response.statusCode);
          TOastNotification().showSuccesToast(context, 'Image updated ');
          return jsonDecode((response.body));
        } catch (error) {
          // Handle exceptions
          print('Error: $error');
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
            'user_id': AuthApi().user_id,
            'product_id': product_id,
            'price': price,
          }
        : requestBody = {
            'user_id': AuthApi().user_id,
            'product_id': product_id,
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
      print(response.body);
      print(response.statusCode);
      return jsonDecode((response.body));
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
      return '-1';
    }
  }
}
