import 'dart:convert';

import 'package:car_service/models/address_models/states_model.dart';

CompleteRequestHistoryListModel completeRequestListModelFromJson(String str) =>
    CompleteRequestHistoryListModel.fromJson(json.decode(str));

String completeRequestListModelToJson(CompleteRequestHistoryListModel data) =>
    json.encode(data.toJson());

class CompleteRequestHistoryListModel {
  final List<OrderCompleteRequest> orderCompleteRequest;
  final Pagination? pagination;

  CompleteRequestHistoryListModel({
    required this.orderCompleteRequest,
    this.pagination,
  });

  factory CompleteRequestHistoryListModel.fromJson(Map json) =>
      CompleteRequestHistoryListModel(
        orderCompleteRequest: json["order_complete_request"] == null
            ? []
            : List<OrderCompleteRequest>.from(json["order_complete_request"]!
                .map((x) => OrderCompleteRequest.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "order_complete_request":
            List<dynamic>.from(orderCompleteRequest.map((x) => x.toJson())),
        "pagination": pagination,
      };
}

class OrderCompleteRequest {
  final dynamic id;
  final dynamic orderId;
  final dynamic subOrderId;
  final dynamic clientId;
  final dynamic providerId;
  final String? message;
  final dynamic status;
  final dynamic image;

  OrderCompleteRequest({
    this.id,
    this.orderId,
    this.subOrderId,
    this.clientId,
    this.providerId,
    this.message,
    this.status,
    this.image,
  });

  factory OrderCompleteRequest.fromJson(Map<String, dynamic> json) =>
      OrderCompleteRequest(
        id: json["id"],
        orderId: json["order_id"],
        subOrderId: json["sub_order_id"],
        clientId: json["client_id"],
        providerId: json["provider_id"],
        message: json["message"],
        status: json["status"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "sub_order_id": subOrderId,
        "client_id": clientId,
        "provider_id": providerId,
        "message": message,
        "status": status,
        "image": image,
      };
}
