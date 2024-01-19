import 'dart:convert';

import 'package:cloudbelly_app/screens/Login/api_service.dart';

import 'package:http/http.dart' as http;

class ProfileApi {
  Future<String> createPost(
      String file_url, List<String> tags, String caption) async {
    final String url = 'https://app.cloudbelly.in/metadata/feed';

    print(AuthApi().user_id);

    final Map<String, dynamic> requestBody = {
      'user_id': AuthApi().user_id,
      'tags': tags,
      "file_url": file_url,
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
}
