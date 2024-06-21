// lib/models/restaurant.dart
class Restaurant {
  final String id;
  final String name;
  final String userId;
  final bool veg;
  final String category;
  final String description;
  final List<String> images;
  final Map<String, dynamic> macros;
  final String price;
  final String type;
  final String storeName;
  final String profilePhoto;
  final String phone;

  Restaurant({
    required this.id,
    required this.name,
    required this.userId,
    required this.veg,
    required this.category,
    required this.description,
    required this.images,
    required this.macros,
    required this.price,
    required this.type,
    required this.storeName,
    required this.profilePhoto,
    required this.phone,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      userId: json['user_id'] ?? '',
      veg: json['VEG'] ?? false,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      macros: json['macros'] ?? {},
      price: json['price'] ?? '',
      type: json['type'] ?? '',
      storeName: json['store_name'] ?? '',
      profilePhoto: json['profile_photo'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}