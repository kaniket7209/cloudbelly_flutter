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
    return UserDetail(
        userID: json['_id'],
        userName: json['email'],
        hNo: json['address']['hno'],
        lat: json['address']['latitude'],
        long: json['address']['longitude'],
        addressType: json['address']['type'],
        location: json['address']['location'],
        image: json['cover_image'] ??
            'https://media.istockphoto.com/id/175433477/photo/red-cabbage-leaves.jpg?s=612x612&w=0&k=20&c=CVC-6nTaKtQ0Gw5l8Nk5aGb8oA47Ce6eba2qSYYauq0=',
        detailedAddress: json['address']['landmark'] +
            ', ' +
            json['address']['location'] +
            ', ' +
            json['address']['location'] +
            ', ' +
            json['address']['pincode'].toString() +
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
