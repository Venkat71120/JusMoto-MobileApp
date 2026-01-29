import 'dart:convert';

import 'package:car_service/models/address_models/states_model.dart';

BrandListModel brandListModelFromJson(String str) =>
    BrandListModel.fromJson(json.decode(str));

String brandListModelToJson(BrandListModel data) => json.encode(data.toJson());

class BrandListModel {
  final List<BrandModel>? allBrands;
  final Pagination? pagination;

  BrandListModel({
    this.allBrands,
    this.pagination,
  });

  factory BrandListModel.fromJson(Map json) => BrandListModel(
      allBrands: json["all_brands"] == null
          ? []
          : List<BrandModel>.from(
              json["all_brands"]!.map((x) => BrandModel.fromJson(x))),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]));

  Map<String, dynamic> toJson() => {
        "all_brands": allBrands == null
            ? []
            : List<dynamic>.from(allBrands!.map((x) => x.toJson())),
      };
}

class BrandModel {
  final dynamic id;
  final String? name;
  final String? image;

  BrandModel({
    this.id,
    this.name,
    this.image,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
