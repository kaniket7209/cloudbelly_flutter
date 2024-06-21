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

  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.images,
    required this.macros,
    required this.price,
    required this.type,
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
    );
  }
}