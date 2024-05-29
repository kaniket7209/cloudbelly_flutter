import 'dart:convert';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/models/supplier_bulk_order.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/user_detail.dart';

Future<List<SupplierBulkOrder>> getBulkOrderData(String userId) async {
  var apiUrl = 'https://app.cloudbelly.in/cart/get';
  Map<String, dynamic> requestBody = {
    'user_id': userId,
  };
  // Convert the request body to JSON
  String requestBodyJson = jsonEncode(requestBody);
  // try {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Accept': '*/*',
      'Content-Type': 'application/json',
    },
    body: requestBodyJson,
  );
  print('Response is ' + response.statusCode.toString());
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    print(jsonData.toString());
    return SupplierBulkOrder.fromJsonList(jsonData['data']);
  } else {
    throw Exception('Failed to fetch data');
  }
  // } catch (error) {
  //   // throw Exception('Error: $error');
  // }
  return [];
}

Future<List<UserDetail>> getUsersDetailsByUserIDs(List<String> userIds) async {
  var apiUrl = 'https://app.cloudbelly.in/get-user-info';
  print(apiUrl.toString());
  print(userIds.toString());
  Map<String, dynamic> requestBody = {
    'user_ids': userIds,
  };
  // Convert the request body to JSON
  String requestBodyJson = jsonEncode(requestBody);

  // try {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Accept': '*/*',
      'Content-Type': 'application/json',
    },
    body: requestBodyJson,
  );
  print('Response is ' + response.statusCode.toString());
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    print(jsonData.toString());
    return UserDetail.fromJsonList(jsonData);
  } else {
    throw Exception('Failed to fetch data');
  }
  // } catch (error) {
  throw Exception('Error: ');
  // }
}

Future<int> placeSupplierBid(Map<String, dynamic> bidData) async {
  var apiUrl = 'https://app.cloudbelly.in/get-user-info';

  // Convert the request body to JSON
  String requestBodyJson = jsonEncode(bidData);

  // try {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Accept': '*/*',
      'Content-Type': 'application/json',
    },
    body: requestBodyJson,
  );
  print('Response is ' + response.statusCode.toString());
  if (response.statusCode == 200) {
    return 200;
  } else {
    return 400;
    // throw Exception('Failed to fetch data');
  }
}
