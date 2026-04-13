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
  final String? username;
  final String? role;
  final int status;
  final int? outletId;
  final String? outletName;
  final DateTime? createdAt;
  final String? type; // 'franchise', 'user', 'staff'

  AdminBaseUserItem({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.username,
    this.role,
    required this.status,
    this.outletId,
    this.outletName,
    this.createdAt,
    this.type,
  });

  factory AdminBaseUserItem.fromJson(Map<String, dynamic> json) {
    // Handle name field variations
    String fullName = json['name'] ?? '';
    if (fullName.isEmpty) {
      final fName = json['first_name'] ?? '';
      final lName = json['last_name'] ?? '';
      fullName = '$fName $lName'.trim();
    }
    if (fullName.isEmpty) fullName = 'Unnamed';

    // Handle nested outlet location
    int? oId;
    String? oName;
    if (json['outletLocation'] != null) {
      oId = json['outletLocation']['id'];
      oName = json['outletLocation']['name'];
    } else if (json['outlet'] != null) {
      oId = json['outlet']['id'];
      oName = json['outlet']['name'];
    } else if (json['branch'] != null) {
      oId = json['branch']['id'];
      oName = json['branch']['name'];
    } else if (json['outlet_location_id'] != null) {
      oId = _toInt(json['outlet_location_id']);
    }

    return AdminBaseUserItem(
      id: json['id'] ?? 0,
      name: fullName,
      email: json['email'] ?? '',
      username: json['username'],
      phone: json['phone'] ?? json['mobile_number'],
      role: json['role']?['name'] ?? json['role'],
      // ROBUST STATUS PARSING: Some APIs return boolean, some string "1"/"0", some int
      status: _toStatusInt(json['status']),
      outletId: oId,
      outletName: oName,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      type: json['account_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile_number': phone,
    'username': username,
    'role': role,
    'outlet_location_id': outletId,
    'status': status,
  };
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

int _toStatusInt(dynamic value) {
  if (value == null) return 0;
  if (value is bool) return value ? 1 : 0;
  if (value is int) return value;
  if (value is String) {
    if (value.toLowerCase() == "active" || value == "1" || value.toLowerCase() == "true") return 1;
    return 0;
  }
  return 0;
}
