import 'dart:convert';

import 'package:car_service/models/address_models/states_model.dart';

CarModelListModel brandListModelFromJson(String str) =>
    CarModelListModel.fromJson(json.decode(str));

String brandListModelToJson(CarModelListModel data) =>
    json.encode(data.toJson());

class CarModelListModel {
  final List<CarModel>? allCarModels;
  final Pagination? pagination;

  CarModelListModel({this.allCarModels, this.pagination});

  factory CarModelListModel.fromJson(Map json) {
    var list = json["data"] ?? json["all_cars"];
    if (list != null && list is List) {
      return CarModelListModel(
        allCarModels: List<CarModel>.from(
          list.map((x) => CarModel.fromJson(x)),
        ),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );
    }
    return CarModelListModel(allCarModels: []);
  }

  Map<String, dynamic> toJson() => {
    "all_cars":
        allCarModels == null
            ? []
            : List<dynamic>.from(allCarModels!.map((x) => x.toJson())),
  };
}

class CarModel {
  final dynamic id;
  final dynamic brandId;
  final String? name;
  final String? image;
  final String? year;
  final dynamic status;

  CarModel({
    this.id,
    this.brandId,
    this.name,
    this.image,
    this.year,
    this.status,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
    id: json["id"],
    brandId: json["brand_id"],
    name: json["name"],
    image: json["image"],
    year: json["Year"]?.toString(),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_id": brandId,
    "name": name,
    "image": image,
    "Year": year,
    "status": status,
  };
}

class ModelVariant {
  final dynamic id;
  final dynamic carId;
  final String? name;
  final VariantTypes? engineType;
  final VariantTypes? fuelType;

  ModelVariant({
    this.id,
    this.carId,
    this.name,
    this.engineType,
    this.fuelType,
  });

  factory ModelVariant.fromJson(Map<String, dynamic> json) => ModelVariant(
    id: json["id"],
    carId: json["car_id"],
    name: json["name"],
    engineType:
        json["engineType"] == null
            ? null
            : VariantTypes.fromJson(json["engineType"]),
    fuelType:
        json["fuelType"] == null
            ? null
            : VariantTypes.fromJson(json["fuelType"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "car_id": carId,
    "name": name,
    "engineType": engineType?.toJson(),
    "fuelType": fuelType?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelVariant &&
          runtimeType == other.runtimeType &&
          id.toString() == other.id.toString();

  @override
  int get hashCode => id.toString().hashCode;
}

class VariantTypes {
  final dynamic id;
  final dynamic name;
  final String? image;

  VariantTypes({this.id, this.name, this.image});

  factory VariantTypes.fromJson(Map<String, dynamic> json) =>
      VariantTypes(id: json["id"], name: json["name"], image: json["image"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "image": image};
}
