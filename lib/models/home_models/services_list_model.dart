import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/service/service_details_model.dart';

import '../address_models/states_model.dart';
import '../category_model.dart';

ServiceListModel homeFeaturedServicesModelFromJson(String str) =>
    ServiceListModel.fromJson(json.decode(str));

String homeFeaturedServicesModelToJson(ServiceListModel data) =>
    json.encode(data.toJson());

class ServiceListModel {
  final List<ServiceModel> allServices;
  final Pagination? pagination;

  ServiceListModel({
    required this.allServices,
    this.pagination,
  });

  factory ServiceListModel.fromJson(Map json) => ServiceListModel(
        allServices: json["all_services"] == null
            ? []
            : List<ServiceModel>.from(
                json["all_services"]!.map((x) => ServiceModel.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "all_services": allServices == null
            ? []
            : List<dynamic>.from(allServices.map((x) => x.toJson())),
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

  ServiceModel(
      {this.id,
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
      this.serviceCar});

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json["id"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        admin:
            json["admin"] == null ? null : AdminModel.fromJson(json["admin"]),
        subCategory: json["sub_category"],
        childCategory: json["child_category"],
        title: json["title"],
        type: json["type"]?.toString(),
        slug: json["slug"],
        duration: json["duration"],
        unit: json["unit"],
        price: json["price"].toString().tryToParse,
        discountPrice: json["discount_price"].toString().tryToParse,
        avgRating: json["average_rating"].toString().tryToParse,
        view: json["view"].toString().tryToParse,
        soldCount: json["sold_count"].toString().tryToParse,
        totalReviews: json["total_reviews"].toString().tryToParse,
        averageRating: json["average_rating"].toString().tryToParse,
        isFeatured: json["is_featured"],
        image: json["image"],
        serviceCar: json["service_car"] == null
            ? null
            : ServiceCar.fromJson(json["service_car"]),
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
        "view": view.toString(),
        "sold_count": soldCount.toString(),
        "total_reviews": totalReviews.toString(),
        "average_rating": averageRating.toString(),
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
        "service_car": serviceCar?.toJson()
      };
}
