class UserDetail {
  final String userID;
  final String userName;
  final String hNo;
  final String lat;
  final String long;
  final String addressType;
  final String location;
  final String image;
  final String detailedAddress;

  UserDetail(
      {required this.userID,
      required this.userName,
      required this.hNo,
      required this.lat,
      required this.long,
      required this.addressType,
      required this.location,
      required this.image,
      required this.detailedAddress});

  // Constructor from JSON map
  factory UserDetail.fromJson(Map<String, dynamic> json) {
    var address = json['address'] ?? {};
    return UserDetail(
        userID: json['_id'],
        userName: json['email'],
        hNo: address['hno'] ?? 'No address found',
        lat: address['latitude']?.toString() ?? "26.744729",
        long: address['longitude']?.toString() ?? "88.4114101",
        addressType: address['type'] ?? "Not known",
        location: address['location'] ?? "User address details not updated",
        image: json['cover_image'] ??
            'https://media.istockphoto.com/id/175433477/photo/red-cabbage-leaves.jpg?s=612x612&w=0&k=20&c=CVC-6nTaKtQ0Gw5l8Nk5aGb8oA47Ce6eba2qSYYauq0=',
        detailedAddress: (address['landmark'] ?? '') +
            ', ' +
            (address['location'] ?? '') +
            ', ' +
            (address['location'] ?? '') +
            ', ' +
            (address['pincode']?.toString() ?? '') +
            ', India');
  }

  // Method to convert instance to JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userName': userName,
      'hNo': hNo,
      'lat': lat,
      'long': long,
      'addressType': addressType,
      'location': location,
      'image': image,
    };
  }

  // Method to convert list of UserDetail to JSON-serializable list
  static List<Map<String, dynamic>> toJsonList(List<UserDetail> userList) {
    return userList.map((userDetail) => userDetail.toJson()).toList();
  }

  static List<UserDetail> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserDetail.fromJson(json)).toList();
  }
}

class UserCartInfo {
  String itemName;
  int quantity;
  String shelfLife;
  String unitType;
  String imageUrl;

  UserCartInfo({
    required this.itemName,
    required this.quantity,
    required this.shelfLife,
    required this.unitType,
    required this.imageUrl,
  });

  factory UserCartInfo.fromJson(Map<String, dynamic> json) {
    return UserCartInfo(
      itemName: json['item_name'],
      quantity: json['qty'],
      shelfLife: json['shelf_life'],
      unitType: json['unit_type'],
      imageUrl: json['image_url'],
    );
  }

  static List<UserCartInfo> fromJsonToList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserCartInfo.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'qty': quantity,
      'shelf_life': shelfLife,
      'unit_type': unitType,
      'image_url': imageUrl,
    };
  }
}

class UserOrderDeliveryDetail {
  String id;
  String businessName;
  String addressDetails;
  List<UserCartInfo> cartInfoList;

  UserOrderDeliveryDetail({
    required this.id,
    required this.businessName,
    required this.addressDetails,
    required this.cartInfoList,
  });

  factory UserOrderDeliveryDetail.fromJson(Map<String, dynamic> json) {
    return UserOrderDeliveryDetail(
      id: json['_id'],
      businessName: json['address']['hno'],
      addressDetails: json['address']['landmark'] + json['address']['pincode'],
      cartInfoList: UserCartInfo.fromJsonToList(json['cart_info'][0]['items']),
    );
  }

  static List<UserOrderDeliveryDetail> fromJsonToList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserOrderDeliveryDetail.fromJson(json)).toList();
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'business_name': businessName,
      'address_details': addressDetails,
      'cart_info': List<dynamic>.from(cartInfoList.map((x) => x.toJson())),
    };
  }
}
