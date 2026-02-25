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

  /// Handles both the NEW backend shape:
  ///   { "success": true, "data": { "id": 18, "first_name": ... } }
  /// and the OLD shape (for cached data read from SharedPreferences):
  ///   { "user_details": { ... }, "profile_image": { ... } }
  factory ProfileInfoModel.fromJson(Map json) {
    // ── NEW backend shape ─────────────────────────────────────────────────
    // The service already strips the outer wrapper and passes responseData['data'],
    // so json here is the flat user object: { id, first_name, last_name, image, ... }
    if (json.containsKey('id') || json.containsKey('email')) {
      return ProfileInfoModel(
        userDetails: UserDetails.fromJson(Map<String, dynamic>.from(json)),
        // New backend returns image directly on the user object as a URL string,
        // not as a nested profile_image object.
        profileImage: json['image'] != null
            ? ProfileImage(imgUrl: json['image'].toString())
            : null,
      );
    }

    // ── OLD / cached shape ────────────────────────────────────────────────
    return ProfileInfoModel(
      userDetails: json["user_details"] == null
          ? null
          : UserDetails.fromJson(
              Map<String, dynamic>.from(json["user_details"])),
      profileImage: json["profile_image"] == null
          ? null
          : ProfileImage.fromJson(json["profile_image"]),
    );
  }

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

  // ── Extra fields present in new backend but not old ──────────────────────
  final String? fullName;
  final dynamic wallet;
  final List<dynamic> selectedCars;

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
    this.fullName,
    this.wallet,
    this.selectedCars = const [],
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        id: json["id"]?.toString(),
        firstName: json["first_name"],
        lastName: json["last_name"],
        // NEW backend uses full_name; fall back to first+last for old shape
        fullName: json["full_name"]?.toString() ??
            [json["first_name"], json["last_name"]]
                .where((e) => e != null && e.toString().isNotEmpty)
                .join(" "),
        username: json["username"]?.toString(),
        type: json["type"]?.toString(),
        email: json["email"]?.toString(),
        phone: json["phone"],
        image: json["image"],
        dateOfBirth: DateFormat("yyyy-MM-dd")
            .tryParse(json["date_of_birth"]?.toString() ?? ""),
        emailVerifyToken: json["email_verify_token"]?.toString(),
        emailVerified: json["email_verified"]?.toString(),
        emailVerifiedAt: json["email_verified_at"],
        passwordChangedAt: json["password_changed_at"],
        verifiedStatus: json["verified_status"]?.toString(),
        termsCondition: json["terms_condition"],
        status: json["status"]?.toString(),
        firebaseToken: json["firebase_token"],
        deletedAt: json["deleted_at"],
        wallet: json["wallet"],
        selectedCars: json["selectedCars"] is List
            ? List<dynamic>.from(json["selectedCars"])
            : [],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id?.toString() ?? "",
        "first_name": firstName?.toString() ?? "",
        "last_name": lastName?.toString() ?? "",
        "full_name": fullName?.toString() ?? "",
        "username": username?.toString() ?? "",
        "type": type?.toString() ?? "",
        "email": email?.toString() ?? "",
        "phone": phone?.toString() ?? "",
        "image": image?.toString() ?? "",
        "date_of_birth": DateFormat("yyyy-MM-dd")
                .format(dateOfBirth ?? DateTime(0))
                .contains("0000")
            ? ""
            : DateFormat("yyyy-MM-dd").format(dateOfBirth ?? DateTime(0)),
        "email_verified": emailVerified?.toString() ?? "",
        "verified_status": verifiedStatus?.toString() ?? "",
        "status": status?.toString() ?? "",
        "firebase_token": firebaseToken?.toString() ?? "",
        "created_at": createdAt?.toIso8601String() ?? "",
        "wallet": wallet,
        "selectedCars": selectedCars,
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
      // Could be a plain URL string from the new backend
      return ProfileImage(imgUrl: json?.toString());
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