import 'dart:convert';

import 'package:car_service/models/address_models/states_model.dart';

CarModelListModel brandListModelFromJson(String str) =>
    CarModelListModel.fromJson(json.decode(str));

String brandListModelToJson(CarModelListModel data) =>
    json.encode(data.toJson());

class CarModelListModel {
  final List<CarModel>? allCarModels;
  final Pagination? pagination;

  CarModelListModel({
    this.allCarModels,
    this.pagination,
  });

  factory CarModelListModel.fromJson(Map json) => CarModelListModel(
      allCarModels: json["all_cars"] == null
          ? []
          : List<CarModel>.from(
              json["all_cars"]!.map((x) => CarModel.fromJson(x))),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]));

  Map<String, dynamic> toJson() => {
        "all_cars": allCarModels == null
            ? []
            : List<dynamic>.from(allCarModels!.map((x) => x.toJson())),
      };
}

class CarModel {
  final dynamic id;
  final String? name;
  final String? image;
  final List<ModelVariant> variants;

  CarModel({
    this.id,
    this.name,
    this.image,
    required this.variants,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        variants: json["varient"] == null
            ? []
            : List<ModelVariant>.from(
                json["varient"]!.map((x) => ModelVariant.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "varient": List<dynamic>.from(variants.map((x) => x.toJson())),
      };
}

class ModelVariant {
  final dynamic id;
  final dynamic carId;
  final VariantTypes? engineType;
  final VariantTypes? fuelType;

  ModelVariant({
    this.id,
    this.carId,
    this.engineType,
    this.fuelType,
  });

  factory ModelVariant.fromJson(Map<String, dynamic> json) => ModelVariant(
        id: json["id"],
        carId: json["car_id"],
        engineType: json["engine_type"] == null
            ? null
            : VariantTypes.fromJson(json["engine_type"]),
        fuelType: json["fual_type"] == null
            ? null
            : VariantTypes.fromJson(json["fual_type"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "car_id": carId,
        "engine_type": engineType?.toJson(),
        "fual_type": fuelType?.toJson(),
      };
}

class VariantTypes {
  final dynamic id;
  final dynamic name;
  final String? image;

  VariantTypes({
    this.id,
    this.name,
    this.image,
  });

  factory VariantTypes.fromJson(Map<String, dynamic> json) => VariantTypes(
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
