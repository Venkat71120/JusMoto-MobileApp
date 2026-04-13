class AdminCouponListModel {
  final List<AdminCouponItem> coupons;

  AdminCouponListModel({required this.coupons});

  factory AdminCouponListModel.fromJson(Map<String, dynamic> json) {
    return AdminCouponListModel(
      coupons: (json['data'] as List? ?? [])
          .map((c) => AdminCouponItem.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  factory AdminCouponListModel.empty() => AdminCouponListModel(coupons: []);
}

class AdminCouponItem {
  final int id;
  final String? title;
  final String code;
  final String discountType; // percentage / fixed
  final double discount;
  final String? expireDate;
  final int status;

  AdminCouponItem({
    required this.id,
    this.title,
    required this.code,
    required this.discountType,
    required this.discount,
    this.expireDate,
    required this.status,
  });

  factory AdminCouponItem.fromJson(Map<String, dynamic> json) {
    return AdminCouponItem(
      id: json['id'] ?? 0,
      title: json['title'],
      code: json['code'] ?? '',
      discountType: json['discount_type'] ?? 'percentage',
      discount: _toDouble(json['discount']),
      expireDate: json['expire_date'],
      status: _toInt(json['status']),
    );
  }

  AdminCouponItem copyWith({
    int? id,
    String? title,
    String? code,
    String? discountType,
    double? discount,
    String? expireDate,
    int? status,
  }) {
    return AdminCouponItem(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discount: discount ?? this.discount,
      expireDate: expireDate ?? this.expireDate,
      status: status ?? this.status,
    );
  }

  bool get isExpired {
    if (expireDate == null) return false;
    try {
      final date = DateTime.parse(expireDate!);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}

class AdminOfferListModel {
  final List<AdminOfferItem> offers;

  AdminOfferListModel({required this.offers});

  factory AdminOfferListModel.fromJson(Map<String, dynamic> json) {
    return AdminOfferListModel(
      offers: (json['data'] as List? ?? [])
          .map((o) => AdminOfferItem.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  factory AdminOfferListModel.empty() => AdminOfferListModel(offers: []);
}

class AdminOfferItem {
  final int id;
  final String title;
  final double offerPercentage;
  final String? expiresAt;
  final String? image;
  final int status;

  final int isPrimary;
  final List<int> serviceIds;

  AdminOfferItem({
    required this.id,
    required this.title,
    required this.offerPercentage,
    this.expiresAt,
    this.image,
    required this.status,
    this.isPrimary = 0,
    this.serviceIds = const [],
  });

  factory AdminOfferItem.fromJson(Map<String, dynamic> json) {
    return AdminOfferItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      offerPercentage: _toDouble(json['offerPercentage'] ?? json['offer_percentage']),
      expiresAt: json['expires_at'],
      image: json['image'],
      status: _toInt(json['status']),
      isPrimary: _toInt(json['is_primary'] ?? json['isPrimary']),
      serviceIds: (json['services'] as List? ?? []).map((s) => _toInt(s is Map ? s['id'] : s)).toList(),
    );
  }

  AdminOfferItem copyWith({
    int? id,
    String? title,
    double? offerPercentage,
    String? expiresAt,
    String? image,
    int? status,
    int? isPrimary,
    List<int>? serviceIds,
  }) {
    return AdminOfferItem(
      id: id ?? this.id,
      title: title ?? this.title,
      offerPercentage: offerPercentage ?? this.offerPercentage,
      expiresAt: expiresAt ?? this.expiresAt,
      image: image ?? this.image,
      status: status ?? this.status,
      isPrimary: isPrimary ?? this.isPrimary,
      serviceIds: serviceIds ?? this.serviceIds,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    try {
      final date = DateTime.parse(expiresAt!);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
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
