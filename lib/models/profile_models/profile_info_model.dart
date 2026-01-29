import 'dart:convert';

import 'package:intl/intl.dart';

ProfileInfoModel profileInfoModelFromJson(String str) =>
    ProfileInfoModel.fromJson(json.decode(str));

String profileInfoModelToJson(ProfileInfoModel data) =>
    json.encode(data.toJson());

class ProfileInfoModel {
  final UserDetails? userDetails;
  final ProfileImage? profileImage;

  ProfileInfoModel({
    this.userDetails,
    this.profileImage,
  });

  factory ProfileInfoModel.fromJson(Map json) => ProfileInfoModel(
        userDetails: json["user_details"] == null
            ? null
            : UserDetails.fromJson(json["user_details"]),
        profileImage: json["profile_image"] == null
            ? null
            : ProfileImage.fromJson(json["profile_image"]),
      );

  Map<String, dynamic> toJson() => {
        "user_details": userDetails?.toJson(),
        "profile_image": profileImage?.toJson(),
      };
}

class UserDetails {
  final String? id;
  final dynamic firstName;
  final dynamic lastName;
  final String? username;
  final String? type;
  final String? email;
  final dynamic phone;
  final dynamic image;
  final DateTime? dateOfBirth;
  final String? emailVerifyToken;
  final String? emailVerified;
  final dynamic emailVerifiedAt;
  final dynamic passwordChangedAt;
  final String? verifiedStatus;
  final dynamic termsCondition;
  final String? status;
  final dynamic firebaseToken;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserDetails({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.type,
    this.email,
    this.phone,
    this.image,
    this.dateOfBirth,
    this.emailVerifyToken,
    this.emailVerified,
    this.emailVerifiedAt,
    this.passwordChangedAt,
    this.verifiedStatus,
    this.termsCondition,
    this.status,
    this.firebaseToken,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        id: json["id"]?.toString(),
        firstName: json["first_name"],
        lastName: json["last_name"],
        username: json["username"],
        type: json["type"]?.toString(),
        email: json["email"],
        phone: json["phone"],
        image: json["image"],
        dateOfBirth:
            DateFormat("yyyy-MM-dd").tryParse(json["date_of_birth"].toString()),
        emailVerifyToken: json["email_verify_token"],
        emailVerified: json["email_verified"]?.toString(),
        emailVerifiedAt: json["email_verified_at"],
        passwordChangedAt: json["password_changed_at"],
        verifiedStatus: json["verified_status"]?.toString(),
        termsCondition: json["terms_condition"],
        status: json["status"]?.toString(),
        firebaseToken: json["firebase_token"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "pId": id?.toString() ?? "",
        "first_name": firstName?.toString() ?? "",
        "last_name": lastName?.toString() ?? "",
        "username": username?.toString() ?? "",
        "type": type?.toString() ?? "",
        "email": email?.toString() ?? "",
        "phone": phone?.toString() ?? "",
        "image": image?.toString() ?? "",
        "date_of_birth": dateOfBirth?.toString() ?? "",
        "email_verified": emailVerified?.toString() ?? "",
        "verified_status": verifiedStatus?.toString() ?? "",
        "status": status?.toString() ?? "",
        "firebase_token": firebaseToken?.toString() ?? "",
        "created_at": createdAt?.toIso8601String().toString() ?? "",
      };
}

class ProfileImage {
  final dynamic imageId;
  final String? path;
  final String? imgUrl;
  final dynamic imgAlt;

  ProfileImage({
    this.imageId,
    this.path,
    this.imgUrl,
    this.imgAlt,
  });

  factory ProfileImage.fromJson(json) {
    if (json is! Map) {
      return ProfileImage();
    }
    return ProfileImage(
      imageId: json["image_id"],
      path: json["path"],
      imgUrl: json["img_url"],
      imgAlt: json["img_alt"],
    );
  }

  Map<String, dynamic> toJson() => {
        "image_id": imageId,
        "path": path,
        "img_url": imgUrl,
        "img_alt": imgAlt,
      };
}
