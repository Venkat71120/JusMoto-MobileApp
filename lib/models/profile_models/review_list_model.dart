import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

import '../address_models/states_model.dart';

ReviewListModel dashboardInfoModelFromJson(String str) =>
    ReviewListModel.fromJson(json.decode(str));

String dashboardInfoModelToJson(ReviewListModel data) =>
    json.encode(data.toJson());

class ReviewListModel {
  final List<ReviewModel> clientAllReviews;
  final Pagination? pagination;

  ReviewListModel({required this.clientAllReviews, this.pagination});

  factory ReviewListModel.fromJson(Map json) => ReviewListModel(
    clientAllReviews:
        json["client_all_reviews"] == null
            ? []
            : List<ReviewModel>.from(
              json["client_all_reviews"]!.map((x) => ReviewModel.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "client_all_reviews":
        clientAllReviews == null
            ? []
            : List<dynamic>.from(clientAllReviews.map((x) => x.toJson())),
  };
}

class ReviewModel {
  final dynamic id;
  final dynamic userId;
  final num rating;
  final String? type;
  final String? message;
  final String? status;
  final DateTime? createdAt;
  final ReviewerModel? reviewer;

  ReviewModel({
    this.id,
    this.userId,
    this.rating = 0,
    this.type,
    this.message,
    this.status,
    this.createdAt,
    this.reviewer,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json["id"],
    userId: json["user_id"],
    rating: json["rating"].toString().tryToParse,
    type: json["type"]?.toString(),
    message: json["message"]?.toString(),
    status: json["status"]?.toString(),
    createdAt: DateTime.tryParse(json["created_at"].toString()),
    reviewer:
        (json["provider_reviews"] ?? json["reviewer"]) == null
            ? null
            : ReviewerModel.fromJson(
              (json["provider_reviews"] ?? json["reviewer"]),
            ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "rating": rating,
    "type": type,
    "message": message,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "provider_reviews": reviewer?.toJson(),
  };
}

class ReviewerModel {
  final dynamic id;
  final String? firstName;
  final String? name;
  final String? email;
  final String? image;
  final dynamic reviewCount;
  final String? averageRating;
  final DateTime? createdAt;
  final DateTime? clientLastSeen;
  final dynamic clientTotalJobs;

  ReviewerModel({
    this.id,
    this.firstName,
    this.name,
    this.email,
    this.image,
    this.reviewCount,
    this.averageRating,
    this.createdAt,
    this.clientLastSeen,
    this.clientTotalJobs,
  });

  factory ReviewerModel.fromJson(Map<String, dynamic> json) => ReviewerModel(
    id: json["id"],
    firstName: json["first_name"]?.toString(),
    name: json["full_name"]?.toString(),
    image: json["image"]?.toString(),
    email: json["email"]?.toString(),
    reviewCount: json["review_count"],
    averageRating: json["average_rating"]?.toString(),
    createdAt: DateTime.tryParse(json["created_at"].toString()),
    clientLastSeen: DateTime.tryParse(json["client_last_seen"].toString()),
    clientTotalJobs: json["client_total_jobs"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "image": image,
    "review_count": reviewCount,
    "average_rating": averageRating,
    "created_at": createdAt?.toIso8601String(),
    "client_last_seen": clientLastSeen?.toIso8601String(),
    "client_total_jobs": clientTotalJobs,
  };
}
