import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL: franchise_order_model.dart
// Location: lib/models/franchise_models/franchise_order_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Order List Item ───────────────────────────────────────────────────────────

class FranchiseOrderListModel {
  final List<FranchiseOrderItem> orders;
  final FranchiseOrderPagination pagination;

  FranchiseOrderListModel({
    required this.orders,
    required this.pagination,
  });

  factory FranchiseOrderListModel.fromJson(Map<String, dynamic> json) {
    return FranchiseOrderListModel(
      orders: (json['data'] as List? ?? [])
          .map((o) => FranchiseOrderItem.fromJson(o as Map<String, dynamic>))
          .toList(),
      pagination: FranchiseOrderPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory FranchiseOrderListModel.empty() => FranchiseOrderListModel(
        orders: [],
        pagination: FranchiseOrderPagination.empty(),
      );
}

class FranchiseOrderPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  FranchiseOrderPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory FranchiseOrderPagination.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 10,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory FranchiseOrderPagination.empty() => FranchiseOrderPagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 10,
        hasNextPage: false,
        hasPrevPage: false,
      );


}

class FranchiseOrderItem {
  final int id;
  final String invoiceNumber;
  final String date;
  final String schedule;
  final String status;
  final int statusCode;
  final String paymentStatus;
  final int paymentStatusCode;
  final num total;
  final FranchiseOrderCustomer customer;
  final FranchiseOrderStaff? staff;
  final int itemsCount;
  final String createdAt;

  FranchiseOrderItem({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.schedule,
    required this.status,
    required this.statusCode,
    required this.paymentStatus,
    required this.paymentStatusCode,
    required this.total,
    required this.customer,
    this.staff,
    required this.itemsCount,
    required this.createdAt,
  });

  factory FranchiseOrderItem.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderItem(
        id: json['id'] ?? 0,
        invoiceNumber: json['invoice_number'] ?? '',
        date: json['date'] ?? '',
        schedule: json['schedule'] ?? '',
        status: _statusLabel(_toInt(json['status'])),
        statusCode: _toInt(json['status']),
        paymentStatus: _paymentStatusLabel(_toInt(json['payment_status'])),
        paymentStatusCode: _toInt(json['payment_status']),
        total: _toNum(json['total']),
        customer: FranchiseOrderCustomer.fromJson(
          json['user'] as Map<String, dynamic>? ?? {},
        ),
        staff: json['staff'] != null
            ? FranchiseOrderStaff.fromJson(
                json['staff'] as Map<String, dynamic>)
            : null,
        itemsCount: (json['items'] as List?)?.length ?? 0,
        createdAt: json['created_at'] ?? '',
      );

  static String _statusLabel(int code) {
    switch (code) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
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

  static String _paymentStatusLabel(int code) {
    return code == 1 ? 'Paid' : 'Unpaid';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

// ── Order Detail ──────────────────────────────────────────────────────────────

class FranchiseOrderDetailModel {
  final int id;
  final String invoiceNumber;
  final String date;
  final String schedule;
  final String status;
  final int statusCode;
  final String paymentStatus;
  final int paymentStatusCode;
  final String paymentGateway;
  final String? transactionId;
  final num subTotal;
  final num tax;
  final num deliveryCharge;
  final String? couponCode;
  final num couponAmount;
  final num total;
  final String? orderNote;
  final bool? isRefunded;
  final num? refundAmount;
  final FranchiseOrderCustomerDetail customer;
  final FranchiseOrderLocation? location;
  final dynamic outlet;
  final FranchiseOrderStaff? staff;
  final List<FranchiseOrderLineItem> items;
  final String createdAt;
  final String updatedAt;

  FranchiseOrderDetailModel({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.schedule,
    required this.status,
    required this.statusCode,
    required this.paymentStatus,
    required this.paymentStatusCode,
    required this.paymentGateway,
    this.transactionId,
    required this.subTotal,
    required this.tax,
    required this.deliveryCharge,
    this.couponCode,
    required this.couponAmount,
    required this.total,
    this.orderNote,
    this.isRefunded,
    this.refundAmount,
    required this.customer,
    this.location,
    this.outlet,
    this.staff,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FranchiseOrderDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      final order = _toMap(json['data']).isNotEmpty
          ? _toMap(json['data'])
          : _toMap(json['order']).isNotEmpty
              ? _toMap(json['order'])
              : json;

      final statusInt = FranchiseOrderItem._toInt(order['status']);
      final pStatusInt = FranchiseOrderItem._toInt(order['payment_status']);

      return FranchiseOrderDetailModel(
        id: FranchiseOrderItem._toInt(order['id']),
        invoiceNumber: order['invoice_number']?.toString() ?? '',
        date: order['date']?.toString() ?? '',
        schedule: order['schedule']?.toString() ?? '',
        status: FranchiseOrderItem._statusLabel(statusInt),
        statusCode: statusInt,
        paymentStatus: FranchiseOrderItem._paymentStatusLabel(pStatusInt),
        paymentStatusCode: pStatusInt,
        paymentGateway: order['payment_gateway']?.toString() ?? '',
        transactionId: order['transaction_id']?.toString(),
        subTotal: FranchiseOrderItem._toNum(order['sub_total']),
        tax: FranchiseOrderItem._toNum(order['tax']),
        deliveryCharge: FranchiseOrderItem._toNum(order['delivery_charge']),
        couponCode: order['coupon_code']?.toString(),
        couponAmount: FranchiseOrderItem._toNum(order['coupon_amount']),
        total: FranchiseOrderItem._toNum(order['total']),
        orderNote: order['order_note']?.toString(),
        isRefunded: order['is_refunded'] == 1 || order['is_refunded'] == true,
        refundAmount: FranchiseOrderItem._toNum(order['refund_amount']),
        customer: FranchiseOrderCustomerDetail.fromJson(
          _toMap(order['user']).isNotEmpty ? _toMap(order['user']) : _toMap(order['customer']),
        ),
        location: order['location'] != null
            ? FranchiseOrderLocation.fromJson(_toMap(order['location']))
            : null,
        outlet: order['outlet'],
        staff: order['staff'] != null
            ? FranchiseOrderStaff.fromJson(_toMap(order['staff']))
            : null,
        items: ((order['items'] ?? order['order_details'] ?? order['invoice_items']) as List? ?? [])
            .map((i) {
              try {
                if (i is! Map) return null;
                return FranchiseOrderLineItem.fromJson(Map<String, dynamic>.from(i));
              } catch (e) {
                debugPrint('❌ Error parsing line item: $e');
                return null;
              }
            })
            .whereType<FranchiseOrderLineItem>()
            .toList(),
        createdAt: order['created_at']?.toString() ?? '',
        updatedAt: order['updated_at']?.toString() ?? '',
      );
    } catch (e, stack) {
      debugPrint('❌ FranchiseOrderDetailModel.fromJson Error: $e');
      debugPrint(stack.toString());
      // Return a minimal model to avoid crashing the UI, but this will likely trigger the null check in the view
      rethrow; 
    }
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}

// ── Shared sub-models ─────────────────────────────────────────────────────────

class FranchiseOrderCustomer {
  final int id;
  final String name;
  final String? phone;

  FranchiseOrderCustomer({
    required this.id,
    required this.name,
    this.phone,
  });

  factory FranchiseOrderCustomer.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderCustomer(
        id: json['id'] ?? 0,
        name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
        phone: json['phone'],
      );
}

class FranchiseOrderCustomerDetail {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final dynamic image;

  FranchiseOrderCustomerDetail({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.image,
  });

  factory FranchiseOrderCustomerDetail.fromJson(Map<String, dynamic> json) {
    String name = json['name']?.toString() ?? 
                 json['full_name']?.toString() ?? 
                 json['customer_name']?.toString() ?? 
                 '';
    if (name.isEmpty) {
      name = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }

    return FranchiseOrderCustomerDetail(
      id: FranchiseOrderItem._toInt(json['id']),
      name: name,
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      image: json['image'],
    );
  }
}

class FranchiseOrderStaff {
  final int id;
  final String name;

  FranchiseOrderStaff({required this.id, required this.name});

  factory FranchiseOrderStaff.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderStaff(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );
}

class FranchiseOrderLocation {
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? latitude;
  final String? longitude;

  FranchiseOrderLocation({
    this.address,
    this.city,
    this.state,
    this.zip,
    this.latitude,
    this.longitude,
  });

  factory FranchiseOrderLocation.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderLocation(
        address: json['address'],
        city: json['city'],
        state: json['state'],
        zip: json['zip'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}

class FranchiseOrderLineItem {
  final int id;
  final int serviceId;
  final String type; // "product" | "service"
  final String name;
  final dynamic image;
  final int quantity;
  final num price;
  final num total;

  FranchiseOrderLineItem({
    required this.id,
    required this.serviceId,
    required this.type,
    required this.name,
    this.image,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory FranchiseOrderLineItem.fromJson(Map<String, dynamic> json) {
    // Backend often nests the actual service/product info
    final serviceGroup = json['service'] as Map<String, dynamic>?;
    final productGroup = json['product'] as Map<String, dynamic>?;

    // Try all common title/name keys at top level first
    String name = json['name']?.toString() ?? 
                 json['title']?.toString() ?? 
                 json['item_title']?.toString() ?? 
                 '';
                 
    dynamic image = json['image'] ?? 
                    json['img'] ?? 
                    serviceGroup?['image'] ?? 
                    serviceGroup?['img'] ?? 
                    productGroup?['image'] ?? 
                    productGroup?['img'];

    if (name.isEmpty) {
      if (serviceGroup != null) {
        name = serviceGroup['title']?.toString() ?? 
               serviceGroup['name']?.toString() ?? 
               '';
        image ??= serviceGroup['image'];
      } else if (productGroup != null) {
        name = productGroup['title']?.toString() ?? 
               productGroup['name']?.toString() ?? 
               '';
        image ??= productGroup['image'];
      }
    }

    num price = FranchiseOrderItem._toNum(json['price']);
    int quantity = FranchiseOrderItem._toInt(json['quantity'] ?? json['qty'] ?? 1);
    num total = FranchiseOrderItem._toNum(json['total'] ?? json['subtotal'] ?? json['sub_total'] ?? json['amount']);

    // Fallback: if total is 0 but we have price and quantity, calculate it
    if (total == 0 && price > 0) {
      total = price * quantity;
    }

    return FranchiseOrderLineItem(
      id: FranchiseOrderItem._toInt(json['id']),
      serviceId: FranchiseOrderItem._toInt(json['service_id']),
      type: json['type']?.toString() ?? (productGroup != null ? 'product' : 'service'),
      name: name,
      image: image,
      quantity: quantity,
      price: price,
      total: total,
    );
  }
}