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
  double _productTotal = 0.0; // Variable to store the total product cost
  double _deliveryFee = 0.0;  // Variable to store the current delivery fee
  double _totalAmount = 0.0;  // Variable to store the overall total

  double get productTotal => _productTotal;
  double get deliveryFee => _deliveryFee;
  double get totalAmount => _totalAmount;

  // Method to update the total amount for products only
  void updateProductTotal(double productTotal) {
    _productTotal = productTotal;
    calculateTotalAmount();  // Recalculate the total amount after updating
  }

  // Method to update the delivery fee only
  void updateDeliveryFee(double newDeliveryFee) {
    _deliveryFee = newDeliveryFee;
    calculateTotalAmount();  // Recalculate the total amount after updating
  }

  // Private method to calculate the total amount
  void calculateTotalAmount() {
    _totalAmount = _productTotal + _deliveryFee;
    notifyListeners();
  }
}