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
    // ── Handle both direct keys and nested "statistics" key ───────────────────
    final data = json.containsKey('total_orders') ? json : (json['statistics'] as Map<String, dynamic>? ?? json);

    return FranchiseDashboardStatisticsModel(
      orders: OrderStats(
        total: _toInt(data['total_orders'] ?? data['orders']?['total']),
        pending: _toInt(data['pending_orders'] ?? data['orders']?['pending']),
        active: _toInt(data['active_orders'] ?? data['accepted_orders'] ?? data['orders']?['active'] ?? 0) +
            _toInt(data['in_progress_orders'] ?? 0),
        completed: _toInt(data['completed_orders'] ?? data['orders']?['completed']),
        delivered: _toInt(data['delivered_orders'] ?? data['orders']?['delivered']),
        cancelled: _toInt(data['cancelled_orders'] ?? data['orders']?['cancelled']),
        today: _toInt(data['today_orders'] ?? data['orders']?['today']),
        thisWeek: _toInt(data['this_week_orders'] ?? data['orders']?['this_week']),
        thisMonth: _toInt(data['this_month_orders'] ?? data['orders']?['this_month']),
      ),
      tickets: TicketStats(
        total: _toInt(data['total_tickets'] ?? data['open_tickets'] ?? data['tickets']?['total']),
        open: _toInt(data['open_tickets'] ?? data['tickets']?['open']),
        closed: _toInt(data['closed_tickets'] ?? data['tickets']?['closed']),
        urgent: _toInt(data['urgent_tickets'] ?? data['tickets']?['by_priority']?['urgent']),
        high: _toInt(data['high_tickets'] ?? data['tickets']?['by_priority']?['high']),
        normal: _toInt(data['normal_tickets'] ?? data['tickets']?['by_priority']?['normal']),
        low: _toInt(data['low_tickets'] ?? data['tickets']?['by_priority']?['low']),
      ),
      earnings: EarningStats(
        total: _toNum(data['total_revenue'] ?? data['total_earnings'] ?? data['earnings']?['total']),
        totalTax: _toNum(data['total_tax'] ?? data['earnings']?['total_tax']),
        netTotal: _toNum(data['paid_revenue'] ?? data['net_earnings'] ?? data['earnings']?['net_total']),
        today: _toNum(data['today_revenue'] ?? data['earnings']?['today']),
        thisWeek: _toNum(data['week_revenue'] ?? data['earnings']?['this_week']),
        thisMonth: _toNum(data['month_revenue'] ?? data['earnings']?['this_month']),
      ),
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

  factory EarningStats.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('today') || json.containsKey('thisWeek')) {
      return EarningStats(
        total: _toNum(json['total']),
        totalTax: 0,
        netTotal: _toNum(json['total']),
        today: _toNum(json['today']),
        thisWeek: _toNum(json['thisWeek']),
        thisMonth: _toNum(json['thisMonth']),
      );
    }
    return EarningStats(
      total: json['total'] ?? 0,
      totalTax: json['total_tax'] ?? 0,
      netTotal: json['net_total'] ?? 0,
      today: json['today'] ?? 0,
      thisWeek: json['this_week'] ?? 0,
      thisMonth: json['this_month'] ?? 0,
    );
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

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
    // ── Handle both nested "order_counts" and direct keys ───────────────────
    final data = json.containsKey('total_orders') ? json : (json['order_counts'] as Map<String, dynamic>? ?? json);

    return FranchiseOrderCountsModel(
      total: _toInt(data['total_orders'] ?? data['total']),
      pending: _toInt(data['pending_orders'] ?? data['pending']),
      active: _toInt(data['active_orders'] ?? data['active'] ?? data['accepted_orders'] ?? 0) + 
              _toInt(data['in_progress_orders'] ?? 0),
      completed: _toInt(data['completed_orders'] ?? data['completed']),
      delivered: _toInt(data['delivered_orders'] ?? data['delivered']),
      cancelled: _toInt(data['cancelled_orders'] ?? data['cancelled']),
      paid: _toInt(data['paid_orders'] ?? data['paid']),
      unpaid: _toInt(data['unpaid_orders'] ?? data['unpaid']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
    // ── Handle both nested "earnings" and direct keys ───────────────────────
    final data = json.containsKey('total_revenue') ? json : (json['earnings'] as Map<String, dynamic>? ?? json);

    final total = _toNum(data['total_revenue'] ?? data['total_earnings'] ?? data['total'] ?? 0);
    final count = _toInt(data['total_orders'] ?? data['order_count'] ?? 0);

    return FranchiseEarningsModel(
      period: data['period']?.toString() ?? 'all',
      totalEarnings: total,
      totalTax: _toNum(data['total_tax'] ?? 0),
      netEarnings: _toNum(data['paid_revenue'] ?? data['net_earnings'] ?? data['net_total'] ?? 0),
      orderCount: count,
      averageOrderValue: count > 0 ? total / count : 0,
    );
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
    // ── Handle both {recent_activity: {orders...}} and {orders: [...]} structure ──
    final data = json.containsKey('recent_activity') 
        ? (json['recent_activity'] as Map<String, dynamic>? ?? {})
        : (json.containsKey('data') && json['data'] is Map 
            ? (json['data'] as Map<String, dynamic>) 
            : json);

    return FranchiseRecentActivityModel(
      orders: (data['orders'] as List? ?? [])
          .map((o) => RecentOrder.fromJson(o as Map<String, dynamic>))
          .toList(),
      tickets: (data['tickets'] as List? ?? [])
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