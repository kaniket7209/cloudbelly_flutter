import 'dart:convert';

import 'package:cloudbelly_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewCartProvider with ChangeNotifier {
  AddressModel? addressModel = AddressModel();
  List<ProductDetails> productList = [];
  List<Map<String, dynamic>> convertedList = [];
  String SellterId = "";
  double? deliveryFee = 0.0; // Add deliveryFee field

  // Method to update delivery fee
  void setDeliveryFee(double fee) {
    deliveryFee = fee;
    notifyListeners(); // Notify listeners when delivery fee is updated
  }

  // Existing methods...

  void getAddress(AddressModel? _addressModel) {
    addressModel = _addressModel;
    notifyListeners();
  }

  void setSellterId(id) {
    if (id != null) {
      SellterId = id;
    }
  }

  void getProductList(List<ProductDetails> tempList) {
    productList = tempList;
    notifyListeners();
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