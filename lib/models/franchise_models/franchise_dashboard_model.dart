// ─────────────────────────────────────────────────────────────────────────────
// MODEL: franchise_dashboard_model.dart
// Location: lib/models/franchise_models/franchise_dashboard_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── 1. Statistics (combined) ──────────────────────────────────────────────────

class FranchiseDashboardStatisticsModel {
  final OrderStats orders;
  final TicketStats tickets;
  final EarningStats earnings;

  FranchiseDashboardStatisticsModel({
    required this.orders,
    required this.tickets,
    required this.earnings,
  });

  factory FranchiseDashboardStatisticsModel.fromJson(
      Map<String, dynamic> json) {
    final stats = json['statistics'] as Map<String, dynamic>? ?? {};
    return FranchiseDashboardStatisticsModel(
      orders: OrderStats.fromJson(stats['orders'] as Map<String, dynamic>? ?? {}),
      tickets: TicketStats.fromJson(stats['tickets'] as Map<String, dynamic>? ?? {}),
      earnings: EarningStats.fromJson(stats['earnings'] as Map<String, dynamic>? ?? {}),
    );
  }

  factory FranchiseDashboardStatisticsModel.empty() =>
      FranchiseDashboardStatisticsModel(
        orders: OrderStats.empty(),
        tickets: TicketStats.empty(),
        earnings: EarningStats.empty(),
      );
}

class OrderStats {
  final int total;
  final int pending;
  final int active;
  final int completed;
  final int delivered;
  final int cancelled;
  final int today;
  final int thisWeek;
  final int thisMonth;

  OrderStats({
    required this.total,
    required this.pending,
    required this.active,
    required this.completed,
    required this.delivered,
    required this.cancelled,
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) => OrderStats(
        total: json['total'] ?? 0,
        pending: json['pending'] ?? 0,
        active: json['active'] ?? 0,
        completed: json['completed'] ?? 0,
        delivered: json['delivered'] ?? 0,
        cancelled: json['cancelled'] ?? 0,
        today: json['today'] ?? 0,
        thisWeek: json['this_week'] ?? 0,
        thisMonth: json['this_month'] ?? 0,
      );

  factory OrderStats.empty() => OrderStats(
        total: 0, pending: 0, active: 0, completed: 0,
        delivered: 0, cancelled: 0, today: 0, thisWeek: 0, thisMonth: 0,
      );
}

class TicketStats {
  final int total;
  final int open;
  final int closed;
  final int urgent;
  final int high;
  final int normal;
  final int low;

  TicketStats({
    required this.total,
    required this.open,
    required this.closed,
    required this.urgent,
    required this.high,
    required this.normal,
    required this.low,
  });

  factory TicketStats.fromJson(Map<String, dynamic> json) {
    final byPriority = json['by_priority'] as Map<String, dynamic>? ?? {};
    return TicketStats(
      total: json['total'] ?? 0,
      open: json['open'] ?? 0,
      closed: json['closed'] ?? 0,
      urgent: byPriority['urgent'] ?? 0,
      high: byPriority['high'] ?? 0,
      normal: byPriority['normal'] ?? 0,
      low: byPriority['low'] ?? 0,
    );
  }

  factory TicketStats.empty() => TicketStats(
        total: 0, open: 0, closed: 0,
        urgent: 0, high: 0, normal: 0, low: 0,
      );
}

class EarningStats {
  final num total;
  final num totalTax;
  final num netTotal;
  final num today;
  final num thisWeek;
  final num thisMonth;

  EarningStats({
    required this.total,
    required this.totalTax,
    required this.netTotal,
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory EarningStats.fromJson(Map<String, dynamic> json) => EarningStats(
        total: json['total'] ?? 0,
        totalTax: json['total_tax'] ?? 0,
        netTotal: json['net_total'] ?? 0,
        today: json['today'] ?? 0,
        thisWeek: json['this_week'] ?? 0,
        thisMonth: json['this_month'] ?? 0,
      );

  factory EarningStats.empty() => EarningStats(
        total: 0, totalTax: 0, netTotal: 0,
        today: 0, thisWeek: 0, thisMonth: 0,
      );
}

// ── 2. Order Counts ───────────────────────────────────────────────────────────

class FranchiseOrderCountsModel {
  final int total;
  final int pending;
  final int active;
  final int completed;
  final int delivered;
  final int cancelled;
  final int paid;
  final int unpaid;

  FranchiseOrderCountsModel({
    required this.total,
    required this.pending,
    required this.active,
    required this.completed,
    required this.delivered,
    required this.cancelled,
    required this.paid,
    required this.unpaid,
  });

  factory FranchiseOrderCountsModel.fromJson(Map<String, dynamic> json) {
    final counts = json['order_counts'] as Map<String, dynamic>? ?? {};
    return FranchiseOrderCountsModel(
      total: counts['total'] ?? 0,
      pending: counts['pending'] ?? 0,
      active: counts['active'] ?? 0,
      completed: counts['completed'] ?? 0,
      delivered: counts['delivered'] ?? 0,
      cancelled: counts['cancelled'] ?? 0,
      paid: counts['paid'] ?? 0,
      unpaid: counts['unpaid'] ?? 0,
    );
  }

  factory FranchiseOrderCountsModel.empty() => FranchiseOrderCountsModel(
        total: 0, pending: 0, active: 0, completed: 0,
        delivered: 0, cancelled: 0, paid: 0, unpaid: 0,
      );
}

// ── 3. Earnings ───────────────────────────────────────────────────────────────

class FranchiseEarningsModel {
  final String period;
  final num totalEarnings;
  final num totalTax;
  final num netEarnings;
  final int orderCount;
  final num averageOrderValue;

  FranchiseEarningsModel({
    required this.period,
    required this.totalEarnings,
    required this.totalTax,
    required this.netEarnings,
    required this.orderCount,
    required this.averageOrderValue,
  });

  factory FranchiseEarningsModel.fromJson(Map<String, dynamic> json) {
    final e = json['earnings'] as Map<String, dynamic>? ?? {};
    return FranchiseEarningsModel(
      period: e['period'] ?? 'all',
      totalEarnings: e['total_earnings'] ?? 0,
      totalTax: e['total_tax'] ?? 0,
      netEarnings: e['net_earnings'] ?? 0,
      orderCount: e['order_count'] ?? 0,
      averageOrderValue: e['average_order_value'] ?? 0,
    );
  }

  factory FranchiseEarningsModel.empty() => FranchiseEarningsModel(
        period: 'all', totalEarnings: 0, totalTax: 0,
        netEarnings: 0, orderCount: 0, averageOrderValue: 0,
      );
}

// ── 4. Recent Activity ────────────────────────────────────────────────────────

class FranchiseRecentActivityModel {
  final List<RecentOrder> orders;
  final List<RecentTicket> tickets;

  FranchiseRecentActivityModel({
    required this.orders,
    required this.tickets,
  });

  factory FranchiseRecentActivityModel.fromJson(Map<String, dynamic> json) {
    final activity = json['recent_activity'] as Map<String, dynamic>? ?? {};
    return FranchiseRecentActivityModel(
      orders: (activity['orders'] as List? ?? [])
          .map((o) => RecentOrder.fromJson(o as Map<String, dynamic>))
          .toList(),
      tickets: (activity['tickets'] as List? ?? [])
          .map((t) => RecentTicket.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  factory FranchiseRecentActivityModel.empty() =>
      FranchiseRecentActivityModel(orders: [], tickets: []);
}

class RecentOrder {
  final int id;
  final String invoiceNumber;
  final String customerName;
  final num total;
  final String status;
  final int statusCode;
  final String paymentStatus;
  final String createdAt;

  RecentOrder({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.total,
    required this.status,
    required this.statusCode,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) => RecentOrder(
        id: json['id'] ?? 0,
        invoiceNumber: json['invoice_number'] ?? '',
        customerName: json['customer_name'] ?? '',
        total: json['total'] ?? 0,
        status: json['status'] ?? '',
        statusCode: json['status_code'] ?? 0,
        paymentStatus: json['payment_status'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}

class RecentTicket {
  final int id;
  final String title;
  final String customerName;
  final String status;
  final String priority;
  final String createdAt;

  RecentTicket({
    required this.id,
    required this.title,
    required this.customerName,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  factory RecentTicket.fromJson(Map<String, dynamic> json) => RecentTicket(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        customerName: json['customer_name'] ?? '',
        status: json['status'] ?? '',
        priority: json['priority'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}