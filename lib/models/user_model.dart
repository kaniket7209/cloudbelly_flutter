part of 'model.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: "_id")
  final String? id;
  @JsonKey(name: "user_id")
  final String? userId;
  final String? email;
  final String? phone;
  @JsonKey(name: "profile_photo")
  final String? profilePhoto;
  @JsonKey(name: "store_name")
  final String? storeName;
  @JsonKey(name: "user_name")
  final String? userName;
  @JsonKey(name: "user_type")
  final String? userType;
  final List<Post>? posts;
  final List<Followers>? followers;
  final List<Followers>? followings;

  

  UserModel({
    this.id,
    this.userId,
    this.email,
    this.phone,
    this.profilePhoto,
    this.storeName,
    this.userName,
    this.userType,
    this.posts,
    this.followers,
    this.followings,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class Post {
  final String? caption;
  @JsonKey(name: "created_at")
  final String? createdAt;
  @JsonKey(name: "file_path")
  final String? filePath;

  Post({
    this.caption,
    this.createdAt,
    this.filePath,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class Followers{
  @JsonKey(name: "followed_at")
  final String?  followedAt;
  @JsonKey(name: "user_id")
  final String? userId;


  Followers({this.userId,this.followedAt});
  factory Followers.fromJson(Map<String, dynamic> json) => _$FollowersFromJson(json);

  Map<String, dynamic> toJson() => _$FollowersToJson(this);

}