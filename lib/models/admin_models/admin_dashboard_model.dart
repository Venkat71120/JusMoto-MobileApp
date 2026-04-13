class AdminDashboardModel {
  final num totalRevenue;
  final int totalOrders;
  final int todayOrders;
  final int pendingOrders;
  final int totalUsers;
  final int totalServices;
  final int totalCars;
  final List<AdminOrderStatusCount> ordersByStatus;
  final List<AdminRecentUser> recentUsers;
  final List<AdminRecentOrder> recentOrders;

  AdminDashboardModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.todayOrders,
    required this.pendingOrders,
    required this.totalUsers,
    required this.totalServices,
    required this.totalCars,
    required this.ordersByStatus,
    required this.recentUsers,
    required this.recentOrders,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    var statusList = json['orders_by_status'] as List? ?? [];
    var usersList = json['recent_users'] as List? ?? [];
    var ordersList = json['recent_orders'] as List? ?? [];

    return AdminDashboardModel(
      totalRevenue: _toNum(json['total_revenue']),
      totalOrders: _toInt(json['total_orders'] ?? json['all_orders_count']),
      todayOrders: _toInt(json['today_orders']),
      pendingOrders: _toInt(json['pending_orders']),
      totalUsers: _toInt(json['total_users']),
      totalServices: _toInt(json['total_services']),
      totalCars: _toInt(json['total_cars']),
      ordersByStatus: statusList
          .map((e) => AdminOrderStatusCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentUsers: usersList
          .map((e) => AdminRecentUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentOrders: ordersList
          .map((e) => AdminRecentOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
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

  factory AdminDashboardModel.empty() => AdminDashboardModel(
        totalRevenue: 0,
        totalOrders: 0,
        todayOrders: 0,
        pendingOrders: 0,
        totalUsers: 0,
        totalServices: 0,
        totalCars: 0,
        ordersByStatus: [],
        recentUsers: [],
        recentOrders: [],
      );
}

class AdminOrderStatusCount {
  final int status;
  final int count;

  AdminOrderStatusCount({required this.status, required this.count});

  factory AdminOrderStatusCount.fromJson(Map<String, dynamic> json) {
    return AdminOrderStatusCount(
      status: json['status'] ?? 0,
      count: json['count'] ?? 0,
    );
  }
}

class AdminRecentUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String createdAt;

  AdminRecentUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
  });

  factory AdminRecentUser.fromJson(Map<String, dynamic> json) {
    return AdminRecentUser(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class AdminRecentOrder {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final num total;
  final int status;

  AdminRecentOrder({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.total,
    required this.status,
  });

  factory AdminRecentOrder.fromJson(Map<String, dynamic> json) {
    return AdminRecentOrder(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      total: num.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 0,
    );
  }
}
