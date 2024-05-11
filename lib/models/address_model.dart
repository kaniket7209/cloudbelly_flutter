part of 'model.dart';

@JsonSerializable()
class DeliveryAddressModel {
  @JsonKey(name: "delivery_addresses")
  final List<AddressModel>? deliveryAddresses;

  DeliveryAddressModel({this.deliveryAddresses});

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryAddressModelToJson(this);
}

@JsonSerializable()
class AddressModel {
  final String? hno;
  final String? id;
  final String? landmark;
  final String? latitude;
  final String? location;
  final String? longitude;
  final String? pincode;
  final String? type;

  AddressModel(
      {this.hno,
      this.id,
      this.landmark,
      this.latitude,
      this.location,
      this.longitude,
      this.pincode,
      this.type});

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
