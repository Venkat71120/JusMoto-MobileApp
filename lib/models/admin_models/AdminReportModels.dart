class AdminRevenueReportListModel {
  final List<AdminRevenueReportItem> data;

  AdminRevenueReportListModel({required this.data});

  factory AdminRevenueReportListModel.fromJson(Map<String, dynamic> json) {
    return AdminRevenueReportListModel(
      data: (json['data'] as List? ?? [])
          .map((item) => AdminRevenueReportItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory AdminRevenueReportListModel.empty() => AdminRevenueReportListModel(data: []);
}

class AdminRevenueReportItem {
  final String period;
  final int orderCount;
  final double totalRevenue;
  final double paidRevenue;

  AdminRevenueReportItem({
    required this.period,
    required this.orderCount,
    required this.totalRevenue,
    required this.paidRevenue,
  });

  factory AdminRevenueReportItem.fromJson(Map<String, dynamic> json) {
    return AdminRevenueReportItem(
      period: json['period'] ?? '',
      orderCount: _toInt(json['order_count'] ?? json['orderCount']),
      totalRevenue: _toDouble(json['total_revenue'] ?? json['totalRevenue']),
      paidRevenue: _toDouble(json['paid_revenue'] ?? json['paidRevenue']),
    );
  }
}

class AdminOrderReportListModel {
  final List<AdminOrderReportItem> data;

  AdminOrderReportListModel({required this.data});

  factory AdminOrderReportListModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderReportListModel(
      data: (json['data'] as List? ?? [])
          .map((item) => AdminOrderReportItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory AdminOrderReportListModel.empty() => AdminOrderReportListModel(data: []);
}

class AdminOrderReportItem {
  final int status;
  final int count;
  final double totalAmount;

  AdminOrderReportItem({
    required this.status,
    required this.count,
    required this.totalAmount,
  });

  factory AdminOrderReportItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderReportItem(
      status: _toInt(json['status']),
      count: _toInt(json['count']),
      totalAmount: _toDouble(json['total_amount'] ?? json['totalAmount']),
    );
  }

  String get statusLabel {
    switch (status) {
      case 0: return 'Pending';
      case 1: return 'Confirmed';
      case 2: return 'In Progress';
      case 3: return 'Completed';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  }
}

// Helpers
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
