class AdminReviewListModel {
  final List<AdminReviewItem> reviews;
  final AdminReviewPagination pagination;

  AdminReviewListModel({
    required this.reviews,
    required this.pagination,
  });

  factory AdminReviewListModel.fromJson(Map<String, dynamic> json) {
    return AdminReviewListModel(
      reviews: (json['data'] as List? ?? [])
          .map((r) => AdminReviewItem.fromJson(r as Map<String, dynamic>))
          .toList(),
      pagination: AdminReviewPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminReviewListModel.empty() => AdminReviewListModel(
        reviews: [],
        pagination: AdminReviewPagination.empty(),
      );
}

class AdminReviewItem {
  final int id;
  final int rating;
  final String message;
  final String status; // pending, approved, rejected
  final String createdAt;
  final ReviewUserInfo? user;
  final ReviewServiceInfo? service;

  AdminReviewItem({
    required this.id,
    required this.rating,
    required this.message,
    required this.status,
    required this.createdAt,
    this.user,
    this.service,
  });

  factory AdminReviewItem.fromJson(Map<String, dynamic> json) {
    return AdminReviewItem(
      id: json['id'] ?? 0,
      rating: _toInt(json['rating']),
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      user: json['user'] != null 
          ? ReviewUserInfo.fromJson(json['user'] as Map<String, dynamic>) 
          : null,
      service: json['service'] != null 
          ? ReviewServiceInfo.fromJson(json['service'] as Map<String, dynamic>) 
          : null,
    );
  }

  AdminReviewItem copyWith({
    int? id,
    int? rating,
    String? message,
    String? status,
    String? createdAt,
    ReviewUserInfo? user,
    ReviewServiceInfo? service,
  }) {
    return AdminReviewItem(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      service: service ?? this.service,
    );
  }
}

class ReviewUserInfo {
  final int id;
  final String name;
  final String? email;

  ReviewUserInfo({required this.id, required this.name, this.email});

  factory ReviewUserInfo.fromJson(Map<String, dynamic> json) {
    return ReviewUserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'],
    );
  }
}

class ReviewServiceInfo {
  final int id;
  final String name;

  ReviewServiceInfo({required this.id, required this.name});

  factory ReviewServiceInfo.fromJson(Map<String, dynamic> json) {
    return ReviewServiceInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Service',
    );
  }
}

class AdminReviewPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminReviewPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminReviewPagination.fromJson(Map<String, dynamic> json) =>
      AdminReviewPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminReviewPagination.empty() => AdminReviewPagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 15,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

// Helpers
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
