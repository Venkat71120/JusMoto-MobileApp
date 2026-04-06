class AdminNotificationListModel {
  final List<AdminNotificationItem> data;
  final AdminNotificationPagination? pagination;

  AdminNotificationListModel({required this.data, this.pagination});

  factory AdminNotificationListModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationListModel(
      data: (json['data'] as List? ?? [])
          .map((item) => AdminNotificationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null 
          ? AdminNotificationPagination.fromJson(json['pagination']) 
          : null,
    );
  }

  factory AdminNotificationListModel.empty() => AdminNotificationListModel(data: []);
}

class AdminNotificationItem {
  final int id;
  final String? type;
  final String message;
  final DateTime? readAt;
  final DateTime createdAt;
  final String? status;

  AdminNotificationItem({
    required this.id,
    this.type,
    required this.message,
    this.readAt,
    required this.createdAt,
    this.status,
  });

  factory AdminNotificationItem.fromJson(Map<String, dynamic> json) {
    // Message can be direct or in data.message
    String msg = json['message'] ?? '';
    if (msg.isEmpty && json['data'] != null && json['data']['message'] != null) {
      msg = json['data']['message'];
    }

    return AdminNotificationItem(
      id: json['id'] ?? 0,
      type: json['type'],
      message: msg,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'],
    );
  }

  bool get isRead => readAt != null || status == 'read';
}

class AdminNotificationPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminNotificationPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminNotificationPagination.fromJson(Map<String, dynamic> json) {
    return AdminNotificationPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 15,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}
