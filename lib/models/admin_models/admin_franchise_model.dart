import 'AdminOutletModels.dart';

class AdminFranchiseListModel {
  final List<AdminFranchiseItem> franchises;
  final AdminFranchisePagination pagination;

  AdminFranchiseListModel({
    required this.franchises,
    required this.pagination,
  });

  factory AdminFranchiseListModel.fromJson(Map<String, dynamic> json) {
    return AdminFranchiseListModel(
      franchises: (json['data'] as List? ?? [])
          .map((f) => AdminFranchiseItem.fromJson(f as Map<String, dynamic>))
          .toList(),
      pagination: AdminFranchisePagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminFranchiseListModel.empty() => AdminFranchiseListModel(
        franchises: [],
        pagination: AdminFranchisePagination.empty(),
      );
}

class AdminFranchisePagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminFranchisePagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminFranchisePagination.fromJson(Map<String, dynamic> json) =>
      AdminFranchisePagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminFranchisePagination.empty() => AdminFranchisePagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 15,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

class AdminFranchiseItem {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final int status;
  final String createdAt;
  final AdminOutletItem? outlet;

  AdminFranchiseItem({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.createdAt,
    this.outlet,
  });

  factory AdminFranchiseItem.fromJson(Map<String, dynamic> json) {
    return AdminFranchiseItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      status: _toInt(json['status']),
      createdAt: json['created_at'] ?? '',
      outlet: json['outlet'] != null ? AdminOutletItem.fromJson(json['outlet']) : null,
    );
  }

  AdminFranchiseItem copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    int? status,
    String? createdAt,
    AdminOutletItem? outlet,
  }) {
    return AdminFranchiseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      outlet: outlet ?? this.outlet,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
