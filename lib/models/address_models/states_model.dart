import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

StatesModel? countryModelFromJson(String str) =>
    StatesModel.fromJson(json.decode(str));

String countryModelToJson(StatesModel? data) => json.encode(data!.toJson());

class StatesModel {
  StatesModel({required this.states, this.pagination});

  Pagination? pagination;
  List<States?> states;

  factory StatesModel.fromJson(json) => StatesModel(
    states:
        json["data"] == null
            ? []
            : List<States?>.from(
              json["data"]!.map((x) => States.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "countries": List<dynamic>.from(states.map((x) => x!.toJson())),
  };
}

class States {
  final dynamic id;
  final String? state;
  final dynamic stateCode;
  final dynamic stateStateCode;
  final dynamic latitude;
  final dynamic longitude;
  final dynamic status;

  States({
    this.id,
    this.state,
    this.stateCode,
    this.stateStateCode,
    this.latitude,
    this.longitude,
    this.status,
  });

  factory States.fromJson(Map<String, dynamic> json) => States(
    id: json["id"],
    state: json["state"],
    stateCode: json["state_code"],
    stateStateCode: json["state_code "],
    latitude: json["latitude"],
    longitude: json["longitude"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "state": state,
    "state_code": stateCode,
    "state_code ": stateStateCode,
    "latitude": latitude,
    "longitude": longitude,
    "status": status,
  };
}

class Pagination {
  final num total;
  final num count;
  final num perPage;
  final num currentPage;
  final num lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final bool? hasNextPage;

  Pagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    this.hasNextPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: (json["total"] ?? 0).toString().tryToParse,
    count: (json["count"] ?? json["limit"] ?? 0).toString().tryToParse,
    perPage: (json["per_page"] ?? json["limit"] ?? 0).toString().tryToParse,
    currentPage:
        (json["current_page"] ?? json["page"] ?? 0).toString().tryToParse,
    lastPage:
        (json["last_page"] ?? json["totalPages"] ?? 0).toString().tryToParse,
    nextPageUrl: json["next_page_url"],
    prevPageUrl: json["prev_page_url"],
    hasNextPage: json["hasNextPage"],
  );
}
