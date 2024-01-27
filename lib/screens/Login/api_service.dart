import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApi {
  static final AuthApi _instance = AuthApi._internal();

  // Your global variables go here

  factory AuthApi() {
    return _instance;
  }

  String user_id = '';
  String user_email = '';

  String get_user_id() {
    return user_id;
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
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
          'Content-Type': 'application/json',
          // Add CORS headers
          // 'Access-Control-Allow-Origin': 'http://localhost:53012',
          // 'Access-Control-Allow-Headers': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print(response.body);
      print(response.statusCode);

      user_id = jsonDecode((response.body))['user_id'];
      user_email = jsonDecode((response.body))['email'];
      print(user_id);
      return jsonDecode((response.body))['message'];
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
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
  AuthApi._internal();
}
