import 'package:flutter/foundation.dart';

class AdminUserListModel {
  final List<AdminUserItem> users;
  final AdminUserPagination pagination;

  AdminUserListModel({
    required this.users,
    required this.pagination,
  });

  factory AdminUserListModel.fromJson(Map<String, dynamic> json) {
    return AdminUserListModel(
      users: (json['data'] as List? ?? [])
          .map((u) => AdminUserItem.fromJson(u as Map<String, dynamic>))
          .toList(),
      pagination: AdminUserPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminUserListModel.empty() => AdminUserListModel(
        users: [],
        pagination: AdminUserPagination.empty(),
      );
}

class AdminUserPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminUserPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminUserPagination.fromJson(Map<String, dynamic> json) =>
      AdminUserPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminUserPagination.empty() => AdminUserPagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 15,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

class AdminUserItem {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final int status;
  final bool emailVerified;
  final String createdAt;

  AdminUserItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.status,
    required this.emailVerified,
    required this.createdAt,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      status: _toInt(json['status']),
      emailVerified: _toBool(json['email_verified']),
      createdAt: json['created_at'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  
  AdminUserItem copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    int? status,
    bool? emailVerified,
    String? createdAt,
  }) {
    return AdminUserItem(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
