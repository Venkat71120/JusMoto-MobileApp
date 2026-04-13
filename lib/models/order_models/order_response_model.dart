import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/outlet_model.dart';

import '../service/admin_staff_list_model.dart';

OrderResponseModel orderResponseModelFromJson(String str) =>
    OrderResponseModel.fromJson(json.decode(str));

String orderResponseModelToJson(OrderResponseModel data) =>
    json.encode(data.toJson());

class OrderResponseModel {
  final OrderDetails? orderDetails;

  OrderResponseModel({
    this.orderDetails,
  });

  factory OrderResponseModel.fromJson(Map json) => OrderResponseModel(
        // ✅ UPDATED: API now returns "data"; keep old keys as fallback
        orderDetails:
            (json["data"] ?? json["order_details"] ?? json["all_services"]) ==
                    null
                ? null
                : OrderDetails.fromJson(
                    json["data"] ?? json["order_details"] ?? json["all_services"]),
      );

  Map<String, dynamic> toJson() => {
        "order_details": orderDetails?.toJson(),
      };
}

class OrderDetails {
  final dynamic id;
  final dynamic userId;
  final num subTotal;
  final num tax;
  final num total;
  final dynamic couponCode;
  final dynamic couponType;
  final num couponAmount;
  final String? paymentGateway;
  String? paymentStatus;
  final dynamic transactionId;
  final String? invoiceNumber;
  final dynamic commissionType;
  final dynamic commissionCharge;
  final dynamic commissionAmount;
  final dynamic status;
  final DateTime? createdAt;
  final Staff? staffDetails;
  final num deliveryCharge;
  final String? deliveryMode;

  // ✅ UPDATED: "schedule" field holds the time slot (e.g. "9:25 AM")
  final String? time;

  // ✅ UPDATED: location is now OrderLocation (not Address)
  final OrderLocation? userLocation;
  final List<OrderItem>? items;
  final Outlet? outletDetails;
  final DateTime? date;

  OrderDetails({
    this.id,
    this.userId,
    required this.subTotal,
    required this.tax,
    required this.total,
    this.couponCode,
    this.couponType,
    required this.couponAmount,
    this.paymentGateway,
    this.paymentStatus,
    this.transactionId,
    this.invoiceNumber,
    this.commissionType,
    this.commissionCharge,
    this.commissionAmount,
    this.status,
    this.createdAt,
    this.staffDetails,
    this.deliveryCharge = 0,
    this.deliveryMode,
    this.time,
    this.userLocation,
    this.outletDetails,
    this.items,
    this.date,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
        id: json["id"],
        userId: json["user_id"],
        subTotal: json["sub_total"].toString().tryToParse,
        tax: json["tax"].toString().tryToParse,
        total: json["total"].toString().tryToParse,

        // ✅ UPDATED: key changed from "user_location" → "location"
        userLocation: (json["location"] ?? json["user_location"]) == null
            ? null
            : OrderLocation.fromJson(json["location"] ?? json["user_location"]),

        outletDetails: (json["outlet_details"] ?? json["outlet"]) == null
            ? null
            : Outlet.fromJson(json["outlet_details"] ?? json["outlet"]),
        deliveryCharge: json["delivery_charge"].toString().tryToParse,
        deliveryMode: json["delivery_mode"],

        // ✅ UPDATED: API stores time in "schedule"; fall back to "time"
        time: json["schedule"]?.toString() ?? json["time"]?.toString(),

        date: json["date"] == null ? null : DateTime.tryParse(json["date"]),
        couponCode: json["coupon_code"],
        couponType: json["coupon_type"],
        couponAmount: json["coupon_amount"].toString().tryToParse,
        paymentGateway: json["payment_gateway"],
        paymentStatus: json["payment_status"]?.toString(),
        transactionId: json["transaction_id"],
        invoiceNumber: json["invoice_number"],
        commissionType: json["commission_type"],
        staffDetails: json["staff_details"] == null
            ? null
            : Staff.fromJson(json["staff_details"]),

        // ✅ UPDATED: items now contain nested "service" object for title/image
        items: (json["items"] ?? json["order_items"] ?? json["sub_orders"]) == null
            ? []
            : List<OrderItem>.from(
                (json["items"] ?? json["order_items"] ?? json["sub_orders"])!.map((x) => OrderItem.fromJson(x))),

        commissionCharge: json["commission_charge"],
        commissionAmount: json["commission_amount"],
        status: json["status"],
        createdAt: DateTime.tryParse(json["created_at"].toString()),
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
        "payment_gateway": paymentGateway,
        "payment_status": paymentStatus,
        "transaction_id": transactionId,
        "invoice_number": invoiceNumber,
        "commission_type": commissionType,
        "commission_charge": commissionCharge,
        "commission_amount": commissionAmount,
        "status": status,
        "created_at": createdAt,
      };
}

// ✅ NEW: Lightweight location model matching the "location" object in the API
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
}

class OrderItem {
  final dynamic id;
  String? image;
  String? itemTitle;
  final String? type;
  final String? serviceId;
  final num qty;
  final num price;
  final List<dynamic>? reviewsAll;
  final String? carName;
  final String? variantName;
  final OrderItemService? service;

  OrderItem({
    this.id,
    this.image,
    this.itemTitle,
    this.type,
    this.serviceId,
    this.qty = 0,
    this.price = 0,
    this.reviewsAll,
    this.carName,
    this.variantName,
    this.service,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final serviceData = json["service"] as Map<String, dynamic>?;
    return OrderItem(
        id: json["id"],
        // ✅ Try: image → service_image → service.image
        image: json["image"]?.toString() ??
            json["service_image"]?.toString() ??
            serviceData?["image"]?.toString(),
        // ✅ Try: item_title → title → name → service.title
        itemTitle: json["item_title"]?.toString() ??
            json["title"]?.toString() ??
            json["name"]?.toString() ??
            serviceData?["title"]?.toString() ??
            serviceData?["name"]?.toString(),
        type: json["type"]?.toString(),
        serviceId: (json["service_id"] ?? json["id"])?.toString(),
        qty: (json["qty"] ?? json["quantity"] ?? 1).toString().tryToParse,
        price: json["price"].toString().tryToParse,
        reviewsAll: json["reviews_all"] == null
            ? []
            : List<dynamic>.from(json["reviews_all"]!.map((x) => x)),
        service: serviceData == null
            ? null
            : OrderItemService.fromJson(serviceData),
        carName: json["car_name"]?.toString() ??
            json["car"]?["name"]?.toString() ??
            serviceData?["car_name"]?.toString(),
        variantName: json["variant_name"]?.toString() ??
            json["variant"]?["name"]?.toString() ??
            serviceData?["variant_name"]?.toString(),
      );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "item_title": itemTitle,
        "type": type,
        "qty": qty,
        "price": price,
        "reviews_all": reviewsAll == null
            ? []
            : List<dynamic>.from(reviewsAll!.map((x) => x)),
      };
}

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
}

// ── Unchanged models below ────────────────────────────────────────────────────

class Review {
  final dynamic id;
  final dynamic userId;
  final dynamic reviewerId;
  final num rating;
  final dynamic orderId;
  final dynamic subOrderId;
  final dynamic serviceId;
  final dynamic jobId;
  final String? type;
  final String? message;
  final String? status;
  final DateTime? createdAt;
  final User? user;

  Review({
    this.id,
    this.userId,
    this.reviewerId,
    required this.rating,
    this.orderId,
    this.subOrderId,
    this.serviceId,
    this.jobId,
    this.type,
    this.message,
    this.status,
    this.createdAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        userId: json["user_id"],
        reviewerId: json["reviewer_id"],
        rating: json["rating"].toString().tryToParse,
        orderId: json["order_id"],
        subOrderId: json["sub_order_id"],
        serviceId: json["service_id"],
        jobId: json["job_id"],
        type: json["type"],
        message: json["message"],
        status: json["status"]?.toString(),
        createdAt: DateTime.tryParse(json["created_at"].toString()),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "reviewer_id": reviewerId,
        "rating": rating,
        "order_id": orderId,
        "sub_order_id": subOrderId,
        "service_id": serviceId,
        "job_id": jobId,
        "type": type,
        "message": message,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "user": user?.toJson(),
      };
}

class User {
  final dynamic id;
  final String? fullName;
  final String? image;

  User({this.id, this.fullName, this.image});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fullName: json["full_name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "image": image,
      };
}

class OrderCompleteRequest {
  final dynamic id;
  final dynamic orderId;
  final dynamic subOrderId;
  final dynamic clientId;
  final dynamic providerId;
  String? message;
  String status;
  final dynamic image;
  final DateTime? createdAt;

  OrderCompleteRequest({
    this.id,
    this.orderId,
    this.subOrderId,
    this.clientId,
    this.providerId,
    this.message,
    this.status = "",
    this.image,
    this.createdAt,
  });

  factory OrderCompleteRequest.fromJson(Map<String, dynamic> json) =>
      OrderCompleteRequest(
        id: json["id"],
        orderId: json["order_id"],
        subOrderId: json["sub_order_id"],
        clientId: json["client_id"],
        providerId: json["provider_id"],
        message: json["message"],
        status: json["status"].toString(),
        image: json["image"],
        createdAt: DateTime.tryParse(json["created_at"].toString()),
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