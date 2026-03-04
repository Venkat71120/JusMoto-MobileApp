import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

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
        // ✅ UPDATED: root key changed from "all_orders" to "data"
        orders: json["data"] == null || json["data"] is! List
            ? []
            : List<Order>.from(json["data"]!.map((x) => Order.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(orders.map((x) => x.toJson())),
      };
}

// ✅ NEW: Order item (service line inside an order)
class OrderItem {
  final dynamic id;
  final dynamic orderId;
  final dynamic serviceId;
  final int? type;
  final int? qty;
  final num price;
  final String? image;
  final OrderItemService? service;

  OrderItem({
    this.id,
    this.orderId,
    this.serviceId,
    this.type,
    this.qty,
    required this.price,
    this.image,
    this.service,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        orderId: json["order_id"],
        serviceId: json["service_id"],
        type: json["type"],
        qty: json["qty"],
        price: json["price"].toString().tryToParse,
        image: json["image"]?.toString(),
        service: json["service"] == null
            ? null
            : OrderItemService.fromJson(json["service"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "service_id": serviceId,
        "type": type,
        "qty": qty,
        "price": price,
        "image": image,
        "service": service?.toJson(),
      };
}

// ✅ NEW: Nested service info inside each order item
class OrderItemService {
  final dynamic id;
  final String? title;
  final String? image;
  final int? type;

  OrderItemService({this.id, this.title, this.image, this.type});

  factory OrderItemService.fromJson(Map<String, dynamic> json) =>
      OrderItemService(
        id: json["id"],
        title: json["title"]?.toString(),
        image: json["image"]?.toString(),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "type": type,
      };
}

// ✅ NEW: Order delivery location
class OrderLocation {
  final dynamic id;
  final dynamic orderId;
  final String? address;
  final String? phone;
  final String? emergencyPhone;
  final String? postCode;
  final double? latitude;
  final double? longitude;

  OrderLocation({
    this.id,
    this.orderId,
    this.address,
    this.phone,
    this.emergencyPhone,
    this.postCode,
    this.latitude,
    this.longitude,
  });

  factory OrderLocation.fromJson(Map<String, dynamic> json) => OrderLocation(
        id: json["id"],
        orderId: json["order_id"],
        address: json["address"]?.toString(),
        phone: json["phone"]?.toString(),
        emergencyPhone: json["emergency_phone"]?.toString(),
        postCode: json["post_code"]?.toString(),
        latitude: double.tryParse(json["latitude"]?.toString() ?? ''),
        longitude: double.tryParse(json["longitude"]?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "address": address,
        "phone": phone,
        "emergency_phone": emergencyPhone,
        "post_code": postCode,
        "latitude": latitude,
        "longitude": longitude,
      };
}

class Order {
  final dynamic id;
  final dynamic userId;
  final num subTotal;
  final num tax;
  final num total;
  final num deliveryCharge;
  final dynamic couponCode;
  final dynamic couponType;
  final num couponAmount;
  final String? paymentGateway;

  // ✅ UPDATED: payment_status and status are now int (0 = pending, 1 = paid, etc.)
  final int? paymentStatus;
  final int? status;

  final dynamic transactionId;
  final String? invoiceNumber;
  final String? type;
  final String? schedule;
  final String? deliveryMode;
  final String? orderNote;
  final int? completeRequest;
  final int? isRefunded;
  final DateTime? createdAt;
  final DateTime? date;

  // ✅ NEW: items list and location
  final List<OrderItem> items;
  final OrderLocation? location;

  Order({
    this.id,
    this.userId,
    required this.subTotal,
    required this.tax,
    required this.total,
    this.deliveryCharge = 0,
    this.couponCode,
    this.couponType,
    this.couponAmount = 0,
    this.paymentGateway,
    this.paymentStatus,
    this.status,
    this.transactionId,
    this.invoiceNumber,
    this.type,
    this.schedule,
    this.deliveryMode,
    this.orderNote,
    this.completeRequest,
    this.isRefunded,
    this.createdAt,
    this.date,
    this.items = const [],
    this.location,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        userId: json["user_id"],
        subTotal: json["sub_total"].toString().tryToParse,
        tax: json["tax"].toString().tryToParse,
        total: json["total"].toString().tryToParse,
        deliveryCharge: json["delivery_charge"].toString().tryToParse,
        couponCode: json["coupon_code"],
        couponType: json["coupon_type"],
        couponAmount: json["coupon_amount"].toString().tryToParse,
        paymentGateway: json["payment_gateway"]?.toString(),

        // ✅ UPDATED: Parse as int directly (API now sends integer codes)
        paymentStatus: int.tryParse(json["payment_status"]?.toString() ?? ''),
        status: int.tryParse(json["status"]?.toString() ?? ''),

        transactionId: json["transaction_id"],
        invoiceNumber: json["invoice_number"],
        type: json["type"]?.toString(),
        schedule: json["schedule"]?.toString(),
        deliveryMode: json["delivery_mode"]?.toString(),
        orderNote: json["order_note"]?.toString(),
        completeRequest: json["complete_request"],
        isRefunded: json["is_refunded"],
        createdAt: DateTime.tryParse(json["created_at"].toString()),
        date: DateTime.tryParse(json["date"].toString()),

        // ✅ NEW: Parse nested items and location
        items: json["items"] == null || json["items"] is! List
            ? []
            : List<OrderItem>.from(
                json["items"].map((x) => OrderItem.fromJson(x))),
        location: json["location"] == null
            ? null
            : OrderLocation.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "sub_total": subTotal,
        "tax": tax,
        "total": total,
        "delivery_charge": deliveryCharge,
        "coupon_code": couponCode,
        "coupon_type": couponType,
        "coupon_amount": couponAmount,
        "transaction_id": transactionId,
        "invoice_number": invoiceNumber,
        "status": status,
        "payment_status": paymentStatus,
      };

  // ✅ HELPER: Convenience getters for status labels
  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'In Progress';
      case 3:
        return 'Completed';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 0:
        return 'Unpaid';
      case 1:
        return 'Paid';
      case 2:
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  // ✅ HELPER: First item's service title (common display use-case)
  String? get firstServiceTitle =>
      items.isNotEmpty ? items.first.service?.title : null;

  // ✅ HELPER: First item's service image
  String? get firstServiceImage =>
      items.isNotEmpty ? items.first.service?.image : null;
}

// ✅ UPDATED: Pagination now uses page/limit/hasNextPage instead of nextPageUrl
class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"] ?? 0,
        page: json["page"] ?? 1,
        limit: json["limit"] ?? 10,
        totalPages: json["totalPages"] ?? 1,
        hasNextPage: json["hasNextPage"] ?? false,
        hasPrevPage: json["hasPrevPage"] ?? false,
      );

  // ✅ HELPER: Build next page URL for the service layer
  String? nextPageUrl(String baseUrl) {
    if (!hasNextPage) return null;
    return '$baseUrl?page=${page + 1}&limit=$limit';
  }
}