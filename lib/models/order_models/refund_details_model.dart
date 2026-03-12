import 'dart:convert';
import 'package:car_service/helper/extension/string_extension.dart';
import 'order_list_model.dart';

RefundDetailsModel refundDetailsModelFromJson(String str) =>
    RefundDetailsModel.fromJson(json.decode(str));

String refundDetailsModelToJson(RefundDetailsModel data) =>
    json.encode(data.toJson());

class RefundDetailsModel {
  final RefundDetails? refundDetails;

  RefundDetailsModel({this.refundDetails});

  factory RefundDetailsModel.fromJson(Map json) => RefundDetailsModel(
        refundDetails: json["data"] == null
            ? null
            : RefundDetails.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"data": refundDetails?.toJson()};
}

class RefundDetails {
  final dynamic id;
  final dynamic userId;
  final dynamic orderId;
  final num amount;
  final String? cancelReason;
  final dynamic gatewayId;
  final dynamic gatewayFields;
  final String? image;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Order? order;
  final String? gatewayName;

  RefundDetails({
    this.id,
    this.userId,
    this.orderId,
    this.amount = 0,
    this.cancelReason,
    this.gatewayId,
    this.gatewayFields,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.order,
    this.gatewayName,
  });

  factory RefundDetails.fromJson(Map<String, dynamic> json) => RefundDetails(
        id: json["id"],
        userId: json["user_id"],
        orderId: json["order_id"],
        amount: json["amount"].toString().tryToParse,
        cancelReason: json["cancel_reason"],
        gatewayId: json["gateway_id"],
        gatewayFields: json["gateway_fields"],
        image: json["image"],
        status: json["status"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        gatewayName: json["gateway"]?["name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "order_id": orderId,
        "amount": amount,
        "cancel_reason": cancelReason,
        "gateway_id": gatewayId,
        "gateway_fields": gatewayFields,
        "image": image,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "order": order?.toJson(),
      };
}

