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
    SellterId = id;
  }

  void getProductList(List<ProductDetails> tempList) {
    productList = tempList;
    // SellterId=sellerId;
    notifyListeners();
  }
}
