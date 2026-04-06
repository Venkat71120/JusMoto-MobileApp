class AdminUserListModel {
  final List<AdminBaseUserItem> data;
  final AdminUserPagination? pagination;

  AdminUserListModel({required this.data, this.pagination});

  factory AdminUserListModel.fromJson(Map<String, dynamic> json) {
    return AdminUserListModel(
      data: (json['data'] as List? ?? [])
          .map((item) => AdminBaseUserItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null 
          ? AdminUserPagination.fromJson(json['pagination']) 
          : null,
    );
  }

  factory AdminUserListModel.empty() => AdminUserListModel(data: []);
}

class AdminBaseUserItem {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final int status;
  final DateTime? createdAt;
  final String? type; // 'franchise', 'user', 'staff'

  AdminBaseUserItem({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    required this.status,
    this.createdAt,
    this.type,
  });

  factory AdminBaseUserItem.fromJson(Map<String, dynamic> json) {
    // Handle name field variations (some have first_name, some just name)
    String fullName = json['name'] ?? '';
    if (fullName.isEmpty) {
      final fName = json['first_name'] ?? '';
      final lName = json['last_name'] ?? '';
      fullName = '$fName $lName'.trim();
    }
    if (fullName.isEmpty) fullName = 'Unnamed';

    return AdminBaseUserItem(
      id: json['id'] ?? 0,
      name: fullName,
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['mobile_number'],
      role: json['role']?['name'] ?? json['role'],
      status: _toInt(json['status']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      type: json['account_type'], // May be added by service locally or in API
    );
  }
}

class AdminUserPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminUserPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminUserPagination.fromJson(Map<String, dynamic> json) {
    return AdminUserPagination(
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
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
