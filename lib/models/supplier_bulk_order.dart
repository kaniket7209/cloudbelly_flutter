class SupplierBulkOrder {
  final String nameId;
  final int quantity;
  late int price;
  final String unitType;
  final String imageUrl;
  List<String> userIDs;

  SupplierBulkOrder({
    required this.nameId,
    required this.quantity,
    required this.unitType,
    required this.userIDs,
    required this.imageUrl,

  });

  factory SupplierBulkOrder.fromJson(Map<String, dynamic> json) {
    return SupplierBulkOrder(
      nameId: json['_id'] as String,
      quantity: json['total_qty'] as int,
      unitType: json['unit_type'] as String,
      userIDs: List<String>.from(json['user_ids'] as List<dynamic>),
      imageUrl: json['image_url']
    );
  }

  static List<SupplierBulkOrder> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SupplierBulkOrder.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': nameId,
      'total_qty': quantity,
      'unit_type': unitType,
      'user_ids': userIDs,
    };
  }
}
