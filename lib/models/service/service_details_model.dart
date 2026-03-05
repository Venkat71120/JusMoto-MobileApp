import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/car_models/car_model_list_model.dart';
import 'package:car_service/models/profile_models/review_list_model.dart';

import '../address_models/address_model.dart';
import '../category_model.dart';
import '../home_models/services_list_model.dart';
import 'admin_staff_list_model.dart';

ServiceDetailsModel serviceDetailsModelFromJson(String str) =>
    ServiceDetailsModel.fromJson(json.decode(str));

String serviceDetailsModelToJson(ServiceDetailsModel data) =>
    json.encode(data.toJson());

class ServiceDetailsModel {
  ServiceDetails? allServices;
  final List<ServiceModel>? relatedServices;

  ServiceDetailsModel({this.allServices, this.relatedServices});

  factory ServiceDetailsModel.fromJson(json) {
    if (json == null) return ServiceDetailsModel();
    final serviceData = json["data"] ?? json["service_details"] ?? json;
    final related =
        json["relevant_service_lists"] ??
        json["related_services"] ??
        serviceData["related_services"] ??
        serviceData["relevant_service_lists"];
    return ServiceDetailsModel(
      allServices:
          serviceData == null ? null : ServiceDetails.fromJson(serviceData),
      relatedServices:
          related == null
              ? []
              : List<ServiceModel>.from(
                related.map((x) => ServiceModel.fromJson(x)),
              ),
    );
  }

  Map<String, dynamic> toJson() => {"service_details": allServices?.toJson()};
}

class ServiceDetails {
  final dynamic id;
  final dynamic categoryId;
  final Category? category;
  final dynamic subCategoryId;
  final dynamic childCategoryId;
  final String? title;
  final String? type;
  final String? slug;
  final String? unit;
  final num price;
  final num? discountPrice;
  final String? description;
  final String? videoId;
  final dynamic isFeatured;
  final String? image;
  num view;
  num soldCount;
  num totalReviews;
  num averageRating;
  final num avgRating;
  final List<String>? galleryImages;
  final List<AdditionalInfo>? offers;
  final List<AdditionalInfo>? faqs;
  final AdminModel? admin;
  final List<ReviewModel>? reviews;
  final List<ServiceAdditional>? serviceAdditional;
  final List<AfterBookingStep>? afterBookingSteps;
  final ServiceCar? serviceCar;

  ServiceDetails({
    this.id,
    this.categoryId,
    this.category,
    this.subCategoryId,
    this.childCategoryId,
    this.title,
    this.type,
    this.slug,
    this.unit,
    required this.price,
    this.discountPrice,
    this.description,
    this.videoId,
    this.isFeatured,
    this.image,
    this.avgRating = 0,
    required this.view,
    required this.soldCount,
    required this.totalReviews,
    required this.averageRating,
    this.galleryImages,
    this.offers,
    this.faqs,
    this.serviceAdditional,
    this.admin,
    this.reviews,
    this.serviceCar,
    this.afterBookingSteps,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse strings or numbers into a num
    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      return num.tryParse(value.toString()) ?? 0;
    }

    return ServiceDetails(
      id: json["id"],
      categoryId: json["category_id"],
      category:
          json["category"] == null ? null : Category.fromJson(json["category"]),
      subCategoryId: json["sub_category_id"],
      childCategoryId: json["child_category_id"],
      title: json["title"]?.toString(),
      type: json["type"]?.toString(),
      slug: json["slug"]?.toString(),
      unit: json["unit"]?.toString(),
      // Use the helper for price fields
      price: parseNum(json["price"]),
      discountPrice:
          json["discount_price"] == null
              ? null
              : parseNum(json["discount_price"]),
      description: json["description"]?.toString(),
      videoId: json["video_url"]?.toString(),
      avgRating: parseNum(json["average_rating"]),
      view: parseNum(json["view"]),
      soldCount: parseNum(json["sold_count"]),
      totalReviews: parseNum(json["total_reviews"]),
      averageRating: parseNum(json["average_rating"]),
      isFeatured: json["is_featured"],
      image: json["image"]?.toString(),
      // ... rest of your mappings stay the same
      serviceCar:
          json["service_car"] == null
              ? null
              : ServiceCar.fromJson(json["service_car"]),
      galleryImages:
          json["gallery_images"] == null
              ? []
              : List<String>.from(json["gallery_images"]!.map((x) => x)),
      serviceAdditional:
          json["service_additionals"] == null
              ? []
              : List<ServiceAdditional>.from(
                json["service_additionals"]!.map(
                  (x) => ServiceAdditional.fromJson(x),
                ),
              ),
      offers:
          json["includes"] == null
              ? []
              : List<AdditionalInfo>.from(
                json["includes"]!.map((x) => AdditionalInfo.fromJson(x)),
              ),
      faqs:
          json["faqs"] == null
              ? []
              : List<AdditionalInfo>.from(
                json["faqs"]!.map((x) => AdditionalInfo.fromJson(x)),
              ),
      reviews:
          (json["reviews"] ?? json["reviews_all"] ?? json["review"]) == null
              ? []
              : List<ReviewModel>.from(
                (json["reviews"] ?? json["reviews_all"] ?? json["review"])!.map(
                  (x) => ReviewModel.fromJson(x),
                ),
              ),
      admin: json["admin"] == null ? null : AdminModel.fromJson(json["admin"]),
      afterBookingSteps:
          json["after_booking_steps"] == null
              ? []
              : List<AfterBookingStep>.from(
                json["after_booking_steps"]!.map(
                  (x) => AfterBookingStep.fromJson(x),
                ),
              ),
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "child_category_id": childCategoryId,
    "title": title,
    "slug": slug,
    "unit": unit,
    "price": price,
    "discount_price": discountPrice,
    "description": description,
    "is_featured": isFeatured,
    "image": image,
    "gallery_images":
        galleryImages == null
            ? []
            : List<dynamic>.from(galleryImages!.map((x) => x)),
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

class Addon {
  dynamic id;
  dynamic serviceId;
  String? title;
  num price;
  num quantity;
  dynamic image;
  String? description;

  Addon({
    this.id,
    this.serviceId,
    this.title,
    required this.price,
    required this.quantity,
    this.image,
    this.description,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
    id: json["id"],
    serviceId: json["service_id"],
    title: json["title"]?.toString(),
    price: json["price"].toString().tryToParse,
    quantity: json["quantity"].toString().tryToParse,
    image: json["image"]?.toString(),
    description: json["description"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "addon_service_title": title ?? "",
    "addon_service_price": price.toString(),
    "addon_service_description": description.toString(),
    "image": image,
    "addon_service_image": image,
  };
}

class AdditionalInfo {
  dynamic id;
  dynamic serviceId;
  String? title;
  String? description;

  AdditionalInfo({this.id, this.serviceId, this.title, this.description});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
    id: json["id"],
    serviceId: json["service_id"],
    title: (json["title"] ?? json["question"])?.toString(),
    description: (json["description"] ?? json["answer"])?.toString(),
  );

  dynamic toFaq() => {
    "id": id,
    "service_id": serviceId,
    "faq_service_title": title,
    "faq_service_description": description,
  };
  dynamic toInclude() => {
    "id": id,
    "service_id": serviceId,
    "include_service_title": title,
    "include_service_description": description,
  };
  dynamic toExclude() => {
    "id": id,
    "service_id": serviceId,
    "exclude_service_title": title,
    "exclude_service_description": description,
  };
}

class AfterBookingStep {
  final int? id;
  final int? stepNo;
  final String? steps;

  AfterBookingStep({this.id, this.stepNo, this.steps});

  factory AfterBookingStep.fromJson(Map<String, dynamic> json) =>
      AfterBookingStep(
        id: json["id"],
        stepNo: json["step_no"],
        steps: json["steps"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "step_no": stepNo,
    "steps": steps,
  };
}

class AdminModel {
  final dynamic id;
  final String? name;
  final String? email;
  final dynamic image;
  final List<Staff> staffs;
  final Address? serviceArea;

  AdminModel({
    this.id,
    this.name,
    this.email,
    this.image,
    required this.staffs,
    this.serviceArea,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
    id: json["id"],
    name: json["name"]?.toString(),
    email: json["email"]?.toString(),
    image: json["image"],
    staffs:
        (json["staffs"]?["all_staffs"]) == null
            ? []
            : List<Staff>.from(
              json["staffs"]!["all_staffs"]!.map((x) => Staff.fromJson(x)),
            ),
    serviceArea:
        json["service_location"] == null
            ? null
            : Address.fromJson(json["service_location"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "image": image,
  };
}

class ServiceAdditional {
  final int? id;
  final int? serviceId;
  final String? title;
  final String? image;
  final String? type;

  ServiceAdditional({
    this.id,
    this.serviceId,
    this.title,
    this.image,
    this.type,
  });

  factory ServiceAdditional.fromJson(Map<String, dynamic> json) =>
      ServiceAdditional(
        id: json["id"],
        serviceId: json["service_id"],
        title: json["title"]?.toString(),
        image: json["image"]?.toString(),
        type: json["type"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "service_id": serviceId,
    "title": title,
    "image": image,
    "type": type,
  };
}

class ServiceCar {
  final dynamic id;
  final String? name;
  final String? image;
  final num price;
  final num? discountPrice;
  final VariantTypes? variant;

  ServiceCar({
    this.id,
    this.name,
    this.image,
    this.price = 0,
    this.discountPrice,
    this.variant,
  });

  factory ServiceCar.fromJson(Map<String, dynamic> json) => ServiceCar(
    id: json["id"],
    name: json["name"]?.toString(),
    image: json["image"]?.toString(),
    price: json["price"].toString().tryToParse,
    discountPrice: num.tryParse(json["discount_price"].toString()),
    variant:
        json["variant"] == null ? null : VariantTypes.fromJson(json["variant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "price": price,
    "discount_price": discountPrice,
    "variant": variant?.toJson(),
  };
}
