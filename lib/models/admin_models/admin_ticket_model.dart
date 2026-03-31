import 'package:flutter/foundation.dart';

class AdminTicketListModel {
  final List<AdminTicketItem> tickets;
  final AdminTicketPagination pagination;

  AdminTicketListModel({
    required this.tickets,
    required this.pagination,
  });

  factory AdminTicketListModel.fromJson(Map<String, dynamic> json) {
    return AdminTicketListModel(
      tickets: (json['data'] as List? ?? [])
          .map((t) => AdminTicketItem.fromJson(t as Map<String, dynamic>))
          .toList(),
      pagination: AdminTicketPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminTicketListModel.empty() => AdminTicketListModel(
        tickets: [],
        pagination: AdminTicketPagination.empty(),
      );
}

class AdminTicketPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminTicketPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminTicketPagination.fromJson(Map<String, dynamic> json) =>
      AdminTicketPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminTicketPagination.empty() => AdminTicketPagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 15,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

class AdminTicketItem {
  final int id;
  final String title;
  final String status;
  final String priority;
  final String departmentName;
  final String customerName;
  final String? assignedTo;
  final String createdAt;

  AdminTicketItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.departmentName,
    required this.customerName,
    this.assignedTo,
    required this.createdAt,
  });

  factory AdminTicketItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final dept = json['department'] as Map<String, dynamic>? ?? {};
    final admin = json['admin'] as Map<String, dynamic>? ?? {};

    return AdminTicketItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['subject'] ?? 'No Title',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'low',
      departmentName: dept['name'] ?? 'N/A',
      customerName: '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
      assignedTo: admin['name'],
      createdAt: json['created_at'] ?? '',
    );
  }

  AdminTicketItem copyWith({
    int? id,
    String? title,
    String? status,
    String? priority,
    String? departmentName,
    String? customerName,
    String? assignedTo,
    String? createdAt,
  }) {
    return AdminTicketItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      departmentName: departmentName ?? this.departmentName,
      customerName: customerName ?? this.customerName,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
