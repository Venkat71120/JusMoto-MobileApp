import 'dart:convert';

import '../address_models/states_model.dart';
import 'services_list_model.dart';

OfferServiceListModel homeFeaturedServicesModelFromJson(String str) =>
    OfferServiceListModel.fromJson(json.decode(str));

String homeFeaturedServicesModelToJson(OfferServiceListModel data) =>
    json.encode(data.toJson());

class OfferServiceListModel {
  final List<ServiceModel> allServices;
  final Pagination? pagination;

  OfferServiceListModel({
    required this.allServices,
    this.pagination,
  });

  factory OfferServiceListModel.fromJson(Map json) => OfferServiceListModel(
        allServices: json["offerServices"] == null
            ? []
            : List<ServiceModel>.from(
                json["offerServices"]!.map((x) => ServiceModel.fromJson(x))),
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
