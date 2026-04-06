
class AdminCategoryListModel {
  final List<AdminCategoryItem> categories;
  final AdminCatalogPagination pagination;

  AdminCategoryListModel({
    required this.categories,
    required this.pagination,
  });

  factory AdminCategoryListModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryListModel(
      categories: (json['data'] as List? ?? [])
          .map((c) => AdminCategoryItem.fromJson(c as Map<String, dynamic>))
          .toList(),
      pagination: AdminCatalogPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminCategoryListModel.empty() => AdminCategoryListModel(
        categories: [],
        pagination: AdminCatalogPagination.empty(),
      );
}

class AdminCategoryItem {
  final int id;
  final String name;
  final String? image;
  final int status;

  AdminCategoryItem({
    required this.id,
    required this.name,
    this.image,
    required this.status,
  });

  factory AdminCategoryItem.fromJson(Map<String, dynamic> json) {
    return AdminCategoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      status: _toInt(json['status']),
    );
  }

  AdminCategoryItem copyWith({
    int? id,
    String? name,
    String? image,
    int? status,
  }) {
    return AdminCategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }
}

class AdminServiceListModel {
  final List<AdminServiceItem> services;
  final AdminCatalogPagination pagination;

  AdminServiceListModel({
    required this.services,
    required this.pagination,
  });

  factory AdminServiceListModel.fromJson(Map<String, dynamic> json) {
    return AdminServiceListModel(
      services: (json['data'] as List? ?? [])
          .map((s) => AdminServiceItem.fromJson(s as Map<String, dynamic>))
          .toList(),
      pagination: AdminCatalogPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminServiceListModel.empty() => AdminServiceListModel(
        services: [],
        pagination: AdminCatalogPagination.empty(),
      );
}

class AdminServiceItem {
  final int id;
  final String title;
  final int categoryId;
  final double price;
  final double? discountPrice;
  final String? image;
  final int status;
  final int isFeatured;
  final int type; // 0=Service, 1=Product
  final String? description;
  final String? duration;
  final AdminCategoryItem? category;

  AdminServiceItem({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.price,
    this.discountPrice,
    this.image,
    required this.status,
    required this.isFeatured,
    required this.type,
    this.description,
    this.duration,
    this.category,
  });

  factory AdminServiceItem.fromJson(Map<String, dynamic> json) {
    return AdminServiceItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryId: _toInt(json['category_id']),
      price: _toDouble(json['price']),
      discountPrice: _toDouble(json['discount_price']),
      image: json['image'],
      status: _toInt(json['status']),
      isFeatured: _toInt(json['is_featured']),
      type: _toInt(json['type']),
      description: json['description'],
      duration: json['duration'],
      category: json['category'] != null 
          ? AdminCategoryItem.fromJson(json['category'] as Map<String, dynamic>) 
          : null,
    );
  }

  AdminServiceItem copyWith({
    int? id,
    String? title,
    int? categoryId,
    double? price,
    double? discountPrice,
    String? image,
    int? status,
    int? isFeatured,
    int? type,
    String? description,
    String? duration,
    AdminCategoryItem? category,
  }) {
    return AdminServiceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      image: image ?? this.image,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      type: type ?? this.type,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      category: category ?? this.category,
    );
  }
}

class AdminCatalogPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminCatalogPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminCatalogPagination.fromJson(Map<String, dynamic> json) =>
      AdminCatalogPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminCatalogPagination.empty() => AdminCatalogPagination(
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

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
