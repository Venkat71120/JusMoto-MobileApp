import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

import '../address_models/states_model.dart';

OrderListModel orderResponseModelFromJson(String str) =>
    OrderListModel.fromJson(json.decode(str));

String orderResponseModelToJson(OrderListModel data) =>
    json.encode(data.toJson());

class OrderListModel {
  final List<Order> orders;
  final Pagination? pagination;

  OrderListModel({
    required this.orders,
    this.pagination,
  });

  factory OrderListModel.fromJson(Map json) => OrderListModel(
        orders: json["all_orders"] == null || json["all_orders"] is! List
            ? []
            : List<Order>.from(
                json["all_orders"]!.map((x) => Order.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "all_services": List<dynamic>.from(orders.map((x) => x.toJson())),
      };
}

class Order {
  final dynamic id;
  final dynamic userId;
  final num subTotal;
  final num tax;
  final num total;
  final dynamic couponCode;
  final dynamic couponType;
  final dynamic couponAmount;
  final String? paymentGateway;
  final String? paymentStatus;
  final dynamic transactionId;
  final String? invoiceNumber;
  final String? status;
  final String? type;
  final DateTime? createdAt;
  final DateTime? date;
  final String? time;

  Order({
    this.id,
    this.userId,
    required this.subTotal,
    required this.tax,
    required this.total,
    this.couponCode,
    this.couponType,
    this.couponAmount,
    this.paymentGateway,
    this.paymentStatus,
    this.transactionId,
    this.invoiceNumber,
    this.status,
    this.type,
    this.createdAt,
    this.date,
    this.time,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        time: json["time"]?.toString(),
        userId: json["user_id"],
        subTotal: json["sub_total"].toString().tryToParse,
        tax: json["tax"].toString().tryToParse,
        total: json["total"].toString().tryToParse,
        couponCode: json["coupon_code"],
        couponType: json["coupon_type"],
        couponAmount: json["coupon_amount"],
        paymentGateway: json["payment_gateway"]?.toString(),
        paymentStatus: json["payment_status"]?.toString(),
        transactionId: json["transaction_id"],
        invoiceNumber: json["invoice_number"],
        status: json["status"]?.toString(),
        type: json["type"]?.toString(),
        createdAt: DateTime.tryParse(json["created_at"].toString()),
        date: DateTime.tryParse(json["date"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "sub_total": subTotal,
        "tax": tax,
        "total": total,
        "coupon_code": couponCode,
        "coupon_type": couponType,
        "coupon_amount": couponAmount,
        "transaction_id": transactionId,
        "invoice_number": invoiceNumber,
        "status": status,
      };
}
