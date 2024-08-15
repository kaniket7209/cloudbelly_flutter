import 'dart:convert';

import 'package:cloudbelly_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewCartProvider with ChangeNotifier {
  AddressModel? addressModel = AddressModel();
  List<ProductDetails> productList = [];
  List<Map<String, dynamic>> convertedList = [];
  String SellterId = "";
  double? _deliveryFee;  // New field for the delivery fee

  double? get deliveryFee => _deliveryFee;  // Getter for the delivery fee

  void getAddress(AddressModel? _addressModel) {
    addressModel = _addressModel;
    print(jsonEncode(addressModel));
    notifyListeners();
  }

  void setSellterId(id) {
    if (id != null) {
      SellterId = id;
    } else {
      print("Received null for sellerId");
    }
  }

  void getProductList(List<ProductDetails> tempList) {
    productList = tempList;
    notifyListeners();
  }

  // Method to calculate delivery fee based on the address and seller
  Future<void> calculateDeliveryFee() async {
    if (addressModel == null || addressModel!.latitude == null || addressModel!.longitude == null) {
      print("No address selected");
      return;
    }

    final String latitude = addressModel!.latitude!;
    final String longitude = addressModel!.longitude!;

    // Example API call to get delivery fee (this assumes the API returns distance and fee)
    final response = await http.post(
      Uri.parse('https://app.cloudbelly.in/get_distance'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'seller_user_id': SellterId
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _deliveryFee = (data['price'] as num).toDouble();
      notifyListeners();
    } else {
      print("Failed to load delivery fee");
    }
  }
}

class CartProvider with ChangeNotifier {
  double _totalAmount = 0.0;

  double get totalAmount => _totalAmount;

  void updateTotalAmount(double productTotal, double? deliveryFee) {
    // Calculate total amount with the delivery fee
    _totalAmount = productTotal + (deliveryFee ?? 0.0);
    notifyListeners();
  }
}