import 'dart:convert';

RefundSettingsModel withdrawSettingsModelFromJson(String str) =>
    RefundSettingsModel.fromJson(json.decode(str));

String withdrawSettingsModelToJson(RefundSettingsModel data) =>
    json.encode(data.toJson());

class RefundSettingsModel {
  List<RefundGateway> withdrawGateways;

  RefundSettingsModel({required this.withdrawGateways});

  factory RefundSettingsModel.fromJson(json) => RefundSettingsModel(
    withdrawGateways:
        json["refund_gateways"] == null
            ? []
            : List<RefundGateway>.from(
              json["refund_gateways"]!.map((x) => RefundGateway.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "refund_gateways": List<dynamic>.from(
      withdrawGateways.map((x) => x.toJson()),
    ),
  };
}

class RefundGateway {
  final id;
  String name;
  List<String> field;

  RefundGateway({this.id, required this.name, required this.field});

  factory RefundGateway.fromJson(Map<String, dynamic> json) => RefundGateway(
    id: json["id"],
    name: json["name"] ?? "",
    field:
        json["field"] == null
            ? []
            : List<String>.from((json["field"] ?? "").map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "field": List<dynamic>.from(field.map((x) => x)),
  };
}
