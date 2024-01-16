import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

Future<int> signUp(email, pass, phone, type) async {
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
      headers: {
        'Accept': '*/*',
        'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    print(response.statusCode);
    return response.statusCode;
  } catch (error) {
    // Handle exceptions
    print('Error: $error');
    return -1;
  }
}

Future<int> login(email, pass) async {
  final String url = 'https://app.cloudbelly.in/login';

  final Map<String, dynamic> requestBody = {
    "email": email,
    "password": pass,
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
    print(response.statusCode);
    return response.statusCode;
  } catch (error) {
    // Handle exceptions
    print('Error: $error');
    return -1;
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
      headers: {
        'Accept': '*/*',
        'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      // Request was successful, handle the response here
      print('Success: ${response.body}');
      return jsonDecode(response.body);
    } else {
      // Request failed, handle the error
      print('Error: ${response.statusCode} - ${response.body}');
      return response.body;
    }
  } catch (error) {
    // Handle exceptions
    print('Error: $error');
    return "";
  }
}

void showToast(String message) {
  // Fluttertoast.showToast(
  //   msg: message,
  //   toastLength: Toast.LENGTH_SHORT,
  //   gravity: ToastGravity.BOTTOM,
  //   timeInSecForIosWeb: 1,
  //   backgroundColor: Colors.black,
  //   textColor: Colors.white,
  // );
}
