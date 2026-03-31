import 'package:flutter/foundation.dart';

class AdminOrderListModel {
  final List<AdminOrderItem> orders;
  final AdminOrderPagination pagination;

  AdminOrderListModel({
    required this.orders,
    required this.pagination,
  });

  factory AdminOrderListModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderListModel(
      orders: (json['data'] as List? ?? [])
          .map((o) => AdminOrderItem.fromJson(o as Map<String, dynamic>))
          .toList(),
      pagination: AdminOrderPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminOrderListModel.empty() => AdminOrderListModel(
        orders: [],
        pagination: AdminOrderPagination.empty(),
      );
}

class AdminOrderPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminOrderPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminOrderPagination.fromJson(Map<String, dynamic> json) =>
      AdminOrderPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminOrderPagination.empty() => AdminOrderPagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 15,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

class AdminOrderItem {
  final int id;
  final String invoiceNumber;
  final num total;
  final int statusCode;
  final int paymentStatusCode;
  final String createdAt;
  final AdminOrderCustomer customer;

  AdminOrderItem({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    required this.statusCode,
    required this.paymentStatusCode,
    required this.createdAt,
    required this.customer,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '#${json['id']}',
      total: _toNum(json['total']),
      statusCode: _toInt(json['status']),
      paymentStatusCode: _toInt(json['payment_status']),
      createdAt: json['created_at'] ?? '',
      customer: AdminOrderCustomer.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  String get statusLabel {
    switch (statusCode) {
      case 0: return 'Pending';
      case 1: return 'Accepted';
      case 2: return 'In Progress';
      case 3: return 'Completed';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  String get paymentStatusLabel => paymentStatusCode == 1 ? 'Paid' : 'Unpaid';
  
  AdminOrderItem copyWith({
    int? id,
    String? invoiceNumber,
    num? total,
    int? statusCode,
    int? paymentStatusCode,
    String? createdAt,
    AdminOrderCustomer? customer,
  }) {
    return AdminOrderItem(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      total: total ?? this.total,
      statusCode: statusCode ?? this.statusCode,
      paymentStatusCode: paymentStatusCode ?? this.paymentStatusCode,
      createdAt: createdAt ?? this.createdAt,
      customer: customer ?? this.customer,
    );
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

class AdminOrderCustomer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  AdminOrderCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory AdminOrderCustomer.fromJson(Map<String, dynamic> json) =>
      AdminOrderCustomer(
        id: json['id'] ?? 0,
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
      );

  String get fullName => '$firstName $lastName'.trim();
}
