import 'dart:convert';

import 'package:cloudbelly_app/screens/Login/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomeApi {
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

    print(AuthApi().user_id);

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
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

  Future<String> storeSetup2(
      pan_number, aadhar_number, fssai_licence_document) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    print(AuthApi().user_id);

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
      'pan_number': pan_number,
      "aadhar_number": aadhar_number,
      "fssai_licence_document": fssai_licence_document,
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

  Future<String> storeSetup3(
      bank_name, account_number, ifsc_code, upi_id) async {
    final String url = 'https://app.cloudbelly.in/update-user';

    print(AuthApi().user_id);

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
      'bank_name': bank_name,
      "account_number": account_number,
      "ifsc_code": ifsc_code,
      "upi_id": upi_id,
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

  Future<String> pickImageAndUpoad() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
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
      if (status != 200)
        throw Exception('http.send error: statusCode= $status');

      print(response.body);

      print(jsonDecode((response.body))['file_url']);
      return jsonDecode((response.body))['file_url'];
    } catch (error) {
      print(error);
      if (error.toString().contains('413')) return "file size very large";
      return "";
    }
  }

  Future<dynamic> getSheetUrl() async {
    final String url = 'https://app.cloudbelly.in/inventory/get-sheet';

    print(AuthApi().user_id);

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
      'user_email': AuthApi().user_email, //email id here
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

  Future<dynamic> SyncInventory() async {
    final String url = 'https://app.cloudbelly.in/inventory/sync';

    print(AuthApi().user_id);

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
      'user_email': AuthApi().user_email, //email id here
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
