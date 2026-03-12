import 'dart:convert';
import 'package:car_service/helper/extension/string_extension.dart';
import 'order_list_model.dart';

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
        clientAllRefundList: json["data"] == null
            ? []
            : List<RefundModel>.from(
                json["data"]!.map((x) => RefundModel.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "data": clientAllRefundList == null
            ? []
            : List<dynamic>.from(clientAllRefundList!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class RefundModel {
  final dynamic id;
  final dynamic orderId;
  final dynamic userId;
  final num amount;
  final String? cancelReason;
  final dynamic gatewayId;
  final dynamic gatewayFields;
  final String? image;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Order? order;
  final String? reason;
  final String? refundNumber;

  RefundModel({
    this.id,
    this.orderId,
    this.userId,
    this.amount = 0,
    this.cancelReason,
    this.gatewayId,
    this.gatewayFields,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.order,
    this.reason,
    this.refundNumber,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) => RefundModel(
        id: json["id"],
        orderId: json["order_id"],
        userId: json["user_id"],
        amount: json["amount"].toString().tryToParse,
        cancelReason: json["cancel_reason"],
        gatewayId: json["gateway_id"],
        gatewayFields: json["gateway_fields"],
        image: json["image"],
        status: json["status"],
        createdAt: DateTime.tryParse(json["created_at"].toString()),
        updatedAt: DateTime.tryParse(json["updated_at"].toString()),
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        reason: json["reason"],
        refundNumber: json["refund_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "user_id": userId,
        "amount": amount,
        "cancel_reason": cancelReason,
        "gateway_id": gatewayId,
        "gateway_fields": gatewayFields,
        "image": image,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "order": order?.toJson(),
        "reason": reason,
        "refund_number": refundNumber,
      };
}

