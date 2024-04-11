part of 'model.dart';

@JsonSerializable()
class ProductDetails {
  @JsonKey(name: "VEG")
  final bool veg;
  @JsonKey(name: "_id")
  final String? id;
  final String? description;
  final List<String>? images;
  final String? name;
  String? price;
  final Macros? macros;
  bool isAddToCart;
  int? quantity;
  String? totalPrice;

  ProductDetails({
    this.name,
    this.id,
    this.description,
    this.images,
    this.price,
    this.veg = false,
    this.macros,
    this.isAddToCart = false,
    this.quantity,
    this.totalPrice,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) => _$ProductDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailsToJson(this);
}

@JsonSerializable()
class Macros {
  final String? calories;
  final String? carbohydrates;
  final String? fats;
  final String? proteins;

  Macros({this.calories,this.carbohydrates,this.fats,this.proteins});

  factory Macros.fromJson(Map<String, dynamic> json) => _$MacrosFromJson(json);

  Map<String, dynamic> toJson() => _$MacrosToJson(this);
}