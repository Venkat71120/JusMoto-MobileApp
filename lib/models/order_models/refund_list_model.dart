import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

import '../address_models/states_model.dart';

RefundListModel refundListModelFromJson(String str) =>
    RefundListModel.fromJson(json.decode(str));

String refundListModelToJson(RefundListModel data) =>
    json.encode(data.toJson());

class RefundListModel {
  final List<RefundModel>? clientAllRefundList;
  final Pagination? pagination;

  RefundListModel({
    this.clientAllRefundList,
    this.pagination,
  });

  factory RefundListModel.fromJson(Map json) => RefundListModel(
        clientAllRefundList: json["client_all_refund_list"] == null
            ? []
            : List<RefundModel>.from(json["client_all_refund_list"]!
                .map((x) => RefundModel.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "client_all_refund_list": clientAllRefundList == null
            ? []
            : List<dynamic>.from(clientAllRefundList!.map((x) => x.toJson())),
      };
}

class RefundModel {
  final dynamic id;
  final dynamic orderId;
  final dynamic userId;
  final num amount;
  final dynamic gatewayId;
  final dynamic status;

  RefundModel({
    this.id,
    this.orderId,
    this.userId,
    this.amount = 0,
    this.gatewayId,
    this.status,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) => RefundModel(
        id: json["id"],
        orderId: json["order_id"],
        userId: json["user_id"],
        amount: json["amount"].toString().tryToParse,
        gatewayId: json["gateway_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "user_id": userId,
        "amount": amount,
        "gateway_id": gatewayId,
        "status": status,
      };
}
