import 'dart:convert';

import 'states_model.dart';

AreaModel cityDropdownModelFromJson(String str) =>
    AreaModel.fromJson(json.decode(str));

String cityDropdownModelToJson(AreaModel data) => json.encode(data.toJson());

class AreaModel {
  List<Area> areas;
  Pagination? pagination;

  AreaModel({
    required this.areas,
    this.pagination,
  });

  factory AreaModel.fromJson(json) => AreaModel(
        areas: json["states"] == null || json["states"] is! List
            ? []
            : List<Area>.from(json["states"]!.map((x) => Area.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "state": [],
      };
}

class Area {
  final dynamic id;
  final dynamic stateId;
  final dynamic cityId;
  final String? area;
  final dynamic status;

  Area({
    this.id,
    this.stateId,
    this.cityId,
    this.area,
    this.status,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        id: json["id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        area: json["area"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "state_id": stateId,
        "city_id": cityId,
        "area": area,
        "status": status,
      };
}
