// lib/models/dish.dart
class Dish {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> images;
  final Map<String, dynamic> macros;
  final String price;
  final String type;
  final String user_id;
  final String store_name;
  final String distance_km;

  Dish({
    required this.id,
    required this.name,
    required this.store_name,
    required this.category,
    required this.description,
    required this.images,
    required this.macros,
    required this.price,
    required this.type,
    required this.user_id,
    required this.distance_km,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      macros: json['macros'] ?? {},
      price: json['price'] ?? '',
      type: json['type'] ?? '',
      user_id: json['user_id'] ?? '',
      store_name: json['store_name'] ?? '',
      distance_km: json['distance_km'].toString(),
    );
  }
}