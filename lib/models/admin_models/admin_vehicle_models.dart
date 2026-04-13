class AdminBrandListModel {
  final List<AdminBrandItem> brands;
  final AdminVehiclePagination pagination;

  AdminBrandListModel({
    required this.brands,
    required this.pagination,
  });

  factory AdminBrandListModel.fromJson(Map<String, dynamic> json) {
    return AdminBrandListModel(
      brands: (json['data'] as List? ?? [])
          .map((b) => AdminBrandItem.fromJson(b as Map<String, dynamic>))
          .toList(),
      pagination: AdminVehiclePagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminBrandListModel.empty() => AdminBrandListModel(
        brands: [],
        pagination: AdminVehiclePagination.empty(),
      );
}

class AdminBrandItem {
  final int id;
  final String name;
  final String? image;
  final int status;

  AdminBrandItem({
    required this.id,
    required this.name,
    this.image,
    required this.status,
  });

  factory AdminBrandItem.fromJson(Map<String, dynamic> json) {
    return AdminBrandItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      status: _toInt(json['status']),
    );
  }

  AdminBrandItem copyWith({
    int? id,
    String? name,
    String? image,
    int? status,
  }) {
    return AdminBrandItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }
}

class AdminCarListModel {
  final List<AdminCarItem> cars;
  final AdminVehiclePagination pagination;

  AdminCarListModel({
    required this.cars,
    required this.pagination,
  });

  factory AdminCarListModel.fromJson(Map<String, dynamic> json) {
    return AdminCarListModel(
      cars: (json['data'] as List? ?? [])
          .map((c) => AdminCarItem.fromJson(c as Map<String, dynamic>))
          .toList(),
      pagination: AdminVehiclePagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminCarListModel.empty() => AdminCarListModel(
        cars: [],
        pagination: AdminVehiclePagination.empty(),
      );
}

class AdminCarItem {
  final int id;
  final String name;
  final int brandId;
  final String? year;
  final String? image;
  final int status;
  final AdminBrandItem? brand;

  AdminCarItem({
    required this.id,
    required this.name,
    required this.brandId,
    this.year,
    this.image,
    required this.status,
    this.brand,
  });

  factory AdminCarItem.fromJson(Map<String, dynamic> json) {
    return AdminCarItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brandId: _toInt(json['brand_id']),
      year: json['year'] ?? json['Year'],
      image: json['image'],
      status: _toInt(json['status']),
      brand: json['brand'] != null 
          ? AdminBrandItem.fromJson(json['brand'] as Map<String, dynamic>) 
          : null,
    );
  }

  AdminCarItem copyWith({
    int? id,
    String? name,
    int? brandId,
    String? year,
    String? image,
    int? status,
    AdminBrandItem? brand,
  }) {
    return AdminCarItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId,
      year: year ?? this.year,
      image: image ?? this.image,
      status: status ?? this.status,
      brand: brand ?? this.brand,
    );
  }
}

class AdminVehiclePagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminVehiclePagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminVehiclePagination.fromJson(Map<String, dynamic> json) =>
      AdminVehiclePagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminVehiclePagination.empty() => AdminVehiclePagination(
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
