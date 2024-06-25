// lib/models/restaurant.dart
class Restaurant {
  final String id;
  final String storeName;
  final int orderCounter;
  final String profilePhoto;
  final String phone;
  final String location;
  final String latitude;
  final String longitude;
  final String distance_km;
  

  Restaurant({
    required this.id,
    required this.storeName,
    required this.orderCounter,
    required this.profilePhoto,
    required this.phone,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.distance_km,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] ?? '',
      storeName: json['store_name'] ?? '',
      orderCounter: json['order_counter'] ?? 0,
      profilePhoto: json['profile_photo'] ?? '',
      phone: json['phone'] ?? '',
      location: json['address']?['location'] ?? '',
      latitude: json['address']?['latitude'] ?? '',
      longitude: json['address']?['longitude'] ?? '',
      distance_km: json['distance_km'].toString(),
    );
  }
}