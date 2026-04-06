class AdminRefundListModel {
  final List<AdminRefundItem> data;
  final AdminRefundPagination? pagination;

  AdminRefundListModel({required this.data, this.pagination});

  factory AdminRefundListModel.fromJson(Map<String, dynamic> json) {
    return AdminRefundListModel(
      data: (json['data'] as List? ?? [])
          .map((item) => AdminRefundItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null 
          ? AdminRefundPagination.fromJson(json['pagination']) 
          : null,
    );
  }

  factory AdminRefundListModel.empty() => AdminRefundListModel(data: []);
}

class AdminRefundItem {
  final int id;
  final int orderId;
  final String orderInvoice;
  final String customerName;
  final double amount;
  final String? cancelReason;
  final int status; // 0=pending, 1=approved, 2=rejected
  final DateTime createdAt;

  AdminRefundItem({
    required this.id,
    required this.orderId,
    required this.orderInvoice,
    required this.customerName,
    required this.amount,
    this.cancelReason,
    required this.status,
    required this.createdAt,
  });

  factory AdminRefundItem.fromJson(Map<String, dynamic> json) {
    // User info
    final user = json['user'] ?? {};
    final fName = user['first_name'] ?? '';
    final lName = user['last_name'] ?? '';
    final name = '$fName $lName'.trim();

    return AdminRefundItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      orderInvoice: json['order'] != null ? (json['order']['invoice_number'] ?? '') : '',
      customerName: name.isNotEmpty ? name : 'Unknown Customer',
      amount: _toDouble(json['amount']),
      cancelReason: json['cancel_reason'],
      status: _toInt(json['status']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get statusLabel {
    switch (status) {
      case 0: return 'Pending';
      case 1: return 'Approved';
      case 2: return 'Rejected';
      default: return 'Unknown';
    }
  }
}

class AdminRefundPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminRefundPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminRefundPagination.fromJson(Map<String, dynamic> json) {
    return AdminRefundPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 15,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}

// Helpers
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    if (value == 'pending') return 0;
    if (value == 'approved') return 1;
    if (value == 'rejected') return 2;
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
