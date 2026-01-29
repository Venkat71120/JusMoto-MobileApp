import 'dart:convert';

import 'states_model.dart';

AddressListModel addressListModelFromJson(String str) =>
    AddressListModel.fromJson(json.decode(str));

String addressListModelToJson(AddressListModel data) =>
    json.encode(data.toJson());

class AddressListModel {
  final List<Address> allLocations;
  final Pagination? pagination;

  AddressListModel({
    required this.allLocations,
    this.pagination,
  });

  factory AddressListModel.fromJson(json) => AddressListModel(
        allLocations: json["all_locations"] == null
            ? []
            : List<Address>.from(
                json["all_locations"]!.map((x) => Address.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "all_locations": [],
      };
}

class Address {
  final dynamic id;
  final dynamic stateId;
  final dynamic cityId;
  final dynamic areaId;
  final dynamic phone;
  final dynamic emergencyPhone;
  final dynamic postCode;
  final String? title;
  final String? type;
  final String? address;
  final double? latitude;
  final double? longitude;

  Address({
    this.id,
    this.stateId,
    this.cityId,
    this.areaId,
    this.phone,
    this.emergencyPhone,
    this.postCode,
    this.type,
    this.title,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        title: json["title"],
        id: json["id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        areaId: json["area_id"],
        phone: json["phone"],
        emergencyPhone: json["emergency_phone"],
        postCode: json["post_code"],
        address: json["address"],
        type: json["type"]?.toString(),
        latitude: num.tryParse(json["latitude"].toString())?.toDouble(),
        longitude: num.tryParse(json["longitude"].toString())?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "state_id": stateId,
        "city_id": cityId,
        "area_id": areaId,
        "phone": phone,
        "post_code": postCode,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };
}
