import 'dart:convert';

import 'package:car_service/models/address_models/states_model.dart';
import 'package:car_service/models/car_models/car_model_list_model.dart';

VariantListModel variantListModelFromJson(String str) =>
    VariantListModel.fromJson(json.decode(str));

String variantListModelToJson(VariantListModel data) =>
    json.encode(data.toJson());

class VariantListModel {
  final List<ModelVariant>? allVariants;
  final Pagination? pagination;

  VariantListModel({
    this.allVariants,
    this.pagination,
  });

  factory VariantListModel.fromJson(Map json) {
    var list = json["data"] ?? json["all_variants"];
    if (list != null && list is List) {
      return VariantListModel(
        allVariants: List<ModelVariant>.from(list.map((x) => ModelVariant.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"])
      );
    }
    return VariantListModel(allVariants: []);
  }

  Map<String, dynamic> toJson() => {
        "all_variants": allVariants == null
            ? []
            : List<dynamic>.from(allVariants!.map((x) => x.toJson())),
      };
}
