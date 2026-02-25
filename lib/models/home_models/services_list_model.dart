import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/service/service_details_model.dart';

import '../address_models/states_model.dart';
import '../category_model.dart';

ServiceListModel homeFeaturedServicesModelFromJson(String str) =>
    ServiceListModel.fromJson(json.decode(str));

String homeFeaturedServicesModelToJson(ServiceListModel data) =>
    json.encode(data.toJson());

// ✅ Helper: safely parse any value (String, int, double, null) to num
num _parseNum(dynamic value, {num fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value;
  return double.tryParse(value.toString()) ?? fallback;
}

class ServiceListModel {
  final List<ServiceModel> allServices;
  final Pagination? pagination;

  ServiceListModel({
    required this.allServices,
    this.pagination,
  });

  factory ServiceListModel.fromJson(Map json) => ServiceListModel(
        // ✅ New API uses "data" key; fallback to "all_services" for cached local data
        allServices: (json["data"] ?? json["all_services"]) == null
            ? []
            : List<ServiceModel>.from(
                (json["data"] ?? json["all_services"])!
                    .map((x) => ServiceModel.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(allServices.map((x) => x.toJson())),
      };
}

class ServiceModel {
  final dynamic id;
  final Category? category;
  final dynamic subCategory;
  final dynamic childCategory;
  final String? title;
  final String? type;
  final String? slug;
  final String? duration;
  final String? unit;
  final num price;
  final num discountPrice;
  num view;
  num soldCount;
  num totalReviews;
  num averageRating;
  final num avgRating;
  final dynamic isFeatured;
  final dynamic image;
  final AdminModel? admin;
  final ServiceCar? serviceCar;
  num? maxQuantity;
  final bool? isPublished;
  final int? disableStaff;
  final List<String>? galleryImages;
  final String? description;

  ServiceModel({
    this.id,
    this.category,
    this.subCategory,
    this.childCategory,
    this.title,
    this.type,
    this.slug,
    this.duration,
    this.unit,
    this.price = 0,
    this.discountPrice = 0,
    this.avgRating = 0,
    required this.view,
    required this.soldCount,
    required this.totalReviews,
    required this.averageRating,
    this.isFeatured,
    this.image,
    this.admin,
    this.maxQuantity,
    this.serviceCar,
    this.isPublished,
    this.disableStaff,
    this.galleryImages,
    this.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json["id"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        admin: json["admin"] == null
            ? null
            : AdminModel.fromJson(json["admin"]),
        subCategory: json["sub_category"] ?? json["subCategory"],
        childCategory: json["child_category"],
        title: json["title"],
        type: json["type"]?.toString(),
        slug: json["slug"],
        duration: json["duration"],
        unit: json["unit"],
        description: json["description"],

        // ✅ FIXED: Use explicit double.tryParse instead of tryToParse extension
        // API returns price as String "500.00" — double.tryParse handles this reliably
        price: _parseNum(json["price"]),
        discountPrice: _parseNum(json["discount_price"]),
        avgRating: _parseNum(json["average_rating"]),

        view: _parseNum(json["view"]),
        soldCount: _parseNum(json["sold_count"]),

        // ✅ "total_reviews" renamed to "review_count" in new API
        totalReviews: _parseNum(json["review_count"] ?? json["total_reviews"]),
        averageRating: _parseNum(json["average_rating"]),

        isFeatured: json["is_featured"],
        image: json["image"],
        maxQuantity: json["max_qty"] != null
            ? _parseNum(json["max_qty"])
            : null,
        serviceCar: json["service_car"] == null
            ? null
            : ServiceCar.fromJson(json["service_car"]),
        isPublished: json["is_published"] == 1 || json["is_published"] == true,
        disableStaff: json["disable_staff"] is int
            ? json["disable_staff"]
            : int.tryParse(json["disable_staff"].toString()),
        galleryImages: json["gallery_images"] == null
            ? []
            : List<String>.from(json["gallery_images"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category?.toJson(),
        "sub_category": subCategory,
        "child_category": childCategory,
        "title": title,
        "slug": slug,
        "unit": unit,
        "price": price,
        "discount_price": discountPrice,
        "is_featured": isFeatured,
        "image": image,
        "view": view,
        "sold_count": soldCount,
        "total_reviews": totalReviews,
        "average_rating": averageRating,
        "type": type,
        "max_qty": maxQuantity,
        "is_published": isPublished,
        "disable_staff": disableStaff,
        "gallery_images": galleryImages ?? [],
        "description": description,
      };

  Map<String, dynamic> toMinimizedJson() => {
        "id": id,
        "title": title,
        "slug": slug,
        "unit": unit,
        "price": price,
        "discount_price": discountPrice,
        "is_featured": isFeatured,
        "image": image,
        "type": type,
        "service_car": serviceCar?.toJson(),
      };
}