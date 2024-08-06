import 'dart:convert';

import 'package:cloudbelly_app/models/model.dart';
import 'package:flutter/material.dart';

class ViewCartProvider with ChangeNotifier {
  AddressModel? addressModel = AddressModel();
  List<ProductDetails> productList = [];
  List<Map<String, dynamic>> convertedList = [];
  String SellterId = "";

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
}

class CartProvider with ChangeNotifier {
  double _totalAmount = 0.0;

  double get totalAmount => _totalAmount;

  void updateTotalAmount(double amount) {
    _totalAmount = amount;
    notifyListeners();
  }
}