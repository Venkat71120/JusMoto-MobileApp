import 'dart:convert';

import 'address_models/states_model.dart';

OutletModel outletModelFromJson(String str) =>
    OutletModel.fromJson(json.decode(str));

String outletModelToJson(OutletModel data) => json.encode(data.toJson());

class OutletModel {
  final List<Outlet>? allOutlets;
  final Pagination? pagination;

  OutletModel({
    this.allOutlets,
    this.pagination,
  });

  factory OutletModel.fromJson(Map json) => OutletModel(
        allOutlets: json["all_outlets"] == null
            ? []
            : List<Outlet>.from(
                json["all_outlets"]!.map((x) => Outlet.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "all_outlets": allOutlets == null
            ? []
            : List<dynamic>.from(allOutlets!.map((x) => x.toJson())),
      };
}

class Outlet {
  final dynamic id;
  final String? outletName;
  final String? address;
  final double? latitude;
  final double? longitude;

  Outlet({
    this.id,
    this.outletName,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) => Outlet(
        id: json["id"],
        outletName: json["outlet_name"],
        address: json["address"],
        latitude: double.tryParse(json["latitude"].toString()),
        longitude: double.tryParse(json["longitude"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "outlet_name": outletName,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };
}
