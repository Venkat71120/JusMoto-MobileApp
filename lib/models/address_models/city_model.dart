import 'dart:convert';

import 'states_model.dart';

CityModel? stateModelFromJson(String str) =>
    CityModel.fromJson(json.decode(str));

String stateModelToJson(CityModel? data) => json.encode(data!.toJson());

class CityModel {
  CityModel({
    required this.cities,
    this.pagination,
  });

  List<City?> cities;
  Pagination? pagination;

  factory CityModel.fromJson(Map json) => CityModel(
        cities: json["states"] == null
            ? []
            : List<City?>.from(json["states"]!.map((x) => City.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "cities": List<dynamic>.from(cities.map((x) => x!.toJson())),
      };
}

class City {
  final dynamic id;
  final dynamic stateId;
  final String? city;
  final dynamic status;

  City({
    this.id,
    this.stateId,
    this.city,
    this.status,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        stateId: json["state_id"],
        city: json["city"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "state_id": stateId,
        "city": city,
        "status": status,
      };
}
