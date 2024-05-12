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
    this.price = 0,
  });

  factory SupplierBulkOrder.fromJson(Map<String, dynamic> json) {
    return SupplierBulkOrder(
        nameId: json['_id'] as String,
        quantity: json['total_qty'] as int,
        unitType: json['unit_type'] as String,
        userIDs: List<String>.from(json['user_ids'] as List<dynamic>),
        imageUrl: json['image_url'],
        price: 0);
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
      'price': price
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<SupplierBulkOrder> orders) {
    return orders.map((order) => order.toJson()).toList();
  }

  // Method to clone the instance
  SupplierBulkOrder clone() {
    return SupplierBulkOrder(
      nameId: this.nameId,
      quantity: this.quantity,
      unitType: this.unitType,
      userIDs:
          List<String>.from(this.userIDs), // Make sure to clone lists as well
      imageUrl: this.imageUrl,
      price: this.price,
    );
  }
}
