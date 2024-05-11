// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator

ProductDetails _$ProductDetailsFromJson(Map<String, dynamic> json) =>
    ProductDetails(
      name: json['name'] as String?,
      id: json['_id'] as String?,
      description: json['description'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      price: json['price'] as String?,
      veg: json['VEG'] as bool? ?? false,
      macros: json['macros'] == null
          ? null
          : Macros.fromJson(json['macros'] as Map<String, dynamic>),
      isAddToCart: json['isAddToCart'] as bool? ?? false,
      quantity: (json['quantity'] as num?)?.toInt(),
      totalPrice: json['totalPrice'] as String?,
    );

Map<String, dynamic> _$ProductDetailsToJson(ProductDetails instance) =>
    <String, dynamic>{
      'VEG': instance.veg,
      '_id': instance.id,
      'description': instance.description,
      'images': instance.images,
      'name': instance.name,
      'price': instance.price,
      'macros': instance.macros,
      'isAddToCart': instance.isAddToCart,
      'quantity': instance.quantity,
      'totalPrice': instance.totalPrice,
    };

Macros _$MacrosFromJson(Map<String, dynamic> json) => Macros(
      calories: json['calories'] as String?,
      carbohydrates: json['carbohydrates'] as String?,
      fats: json['fats'] as String?,
      proteins: json['proteins'] as String?,
    );

Map<String, dynamic> _$MacrosToJson(Macros instance) => <String, dynamic>{
      'calories': instance.calories,
      'carbohydrates': instance.carbohydrates,
      'fats': instance.fats,
      'proteins': instance.proteins,
    };

DeliveryAddressModel _$DeliveryAddressModelFromJson(
        Map<String, dynamic> json) =>
    DeliveryAddressModel(
      deliveryAddresses: (json['delivery_addresses'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeliveryAddressModelToJson(
        DeliveryAddressModel instance) =>
    <String, dynamic>{
      'delivery_addresses': instance.deliveryAddresses,
    };

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      hno: json['hno'] as String?,
      id: json['id'] as String?,
      landmark: json['landmark'] as String?,
      latitude: json['latitude'] as String?,
      location: json['location'] as String?,
      longitude: json['longitude'] as String?,
      pincode: json['pincode'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'hno': instance.hno,
      'id': instance.id,
      'landmark': instance.landmark,
      'latitude': instance.latitude,
      'location': instance.location,
      'longitude': instance.longitude,
      'pincode': instance.pincode,
      'type': instance.type,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['_id'] as String?,
      userId: json['user_id'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      storeName: json['store_name'] as String?,
      userName: json['user_name'] as String?,
      userType: json['user_type'] as String?,
      posts: (json['posts'] as List<dynamic>?)
          ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      followers: (json['followers'] as List<dynamic>?)
          ?.map((e) => Followers.fromJson(e as Map<String, dynamic>))
          .toList(),
      followings: (json['followings'] as List<dynamic>?)
          ?.map((e) => Followers.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      '_id': instance.id,
      'user_id': instance.userId,
      'email': instance.email,
      'phone': instance.phone,
      'profile_photo': instance.profilePhoto,
      'store_name': instance.storeName,
      'user_name': instance.userName,
      'user_type': instance.userType,
      'posts': instance.posts,
      'followers': instance.followers,
      'followings': instance.followings,
    };

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      caption: json['caption'] as String?,
      createdAt: json['created_at'] as String?,
      filePath: json['file_path'] as String?,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'caption': instance.caption,
      'created_at': instance.createdAt,
      'file_path': instance.filePath,
    };

Followers _$FollowersFromJson(Map<String, dynamic> json) => Followers(
      userId: json['user_id'] as String?,
      followedAt: json['followed_at'] as String?,
    );

Map<String, dynamic> _$FollowersToJson(Followers instance) => <String, dynamic>{
      'followed_at': instance.followedAt,
      'user_id': instance.userId,
    };
