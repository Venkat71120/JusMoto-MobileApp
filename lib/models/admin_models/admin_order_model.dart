import 'package:flutter/foundation.dart';

class AdminOrderListModel {
  final List<AdminOrderItem> orders;
  final AdminOrderPagination pagination;

  AdminOrderListModel({
    required this.orders,
    required this.pagination,
  });

  factory AdminOrderListModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderListModel(
      orders: (json['data'] as List? ?? [])
          .map((o) => AdminOrderItem.fromJson(o as Map<String, dynamic>))
          .toList(),
      pagination: AdminOrderPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminOrderListModel.empty() => AdminOrderListModel(
        orders: [],
        pagination: AdminOrderPagination.empty(),
      );
}

class AdminOrderPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminOrderPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminOrderPagination.fromJson(Map<String, dynamic> json) =>
      AdminOrderPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminOrderPagination.empty() => AdminOrderPagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 15,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

class AdminOrderItem {
  final int id;
  final String invoiceNumber;
  final num total;
  final int statusCode;
  final int paymentStatusCode;
  final String createdAt;
  final AdminOrderCustomer customer;

  AdminOrderItem({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    required this.statusCode,
    required this.paymentStatusCode,
    required this.createdAt,
    required this.customer,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '#${json['id']}',
      total: _toNum(json['total']),
      statusCode: _toInt(json['status']),
      paymentStatusCode: _toInt(json['payment_status']),
      createdAt: json['created_at'] ?? '',
      customer: AdminOrderCustomer.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  String get statusLabel {
    switch (statusCode) {
      case 0: return 'Pending';
      case 1: return 'Accepted';
      case 2: return 'In Progress';
      case 3: return 'Completed';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  String get paymentStatusLabel => paymentStatusCode == 1 ? 'Paid' : 'Unpaid';
  
  AdminOrderItem copyWith({
    int? id,
    String? invoiceNumber,
    num? total,
    int? statusCode,
    int? paymentStatusCode,
    String? createdAt,
    AdminOrderCustomer? customer,
  }) {
    return AdminOrderItem(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      total: total ?? this.total,
      statusCode: statusCode ?? this.statusCode,
      paymentStatusCode: paymentStatusCode ?? this.paymentStatusCode,
      createdAt: createdAt ?? this.createdAt,
      customer: customer ?? this.customer,
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
}

class AdminOrderCustomer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  AdminOrderCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory AdminOrderCustomer.fromJson(Map<String, dynamic> json) =>
      AdminOrderCustomer(
        id: json['id'] ?? 0,
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
      );

  String get fullName => '$firstName $lastName'.trim();
}

// ── Order Detail Model ───────────────────────────────────────────────────────

class AdminOrderDetailModel {
  final int id;
  final String invoiceNumber;
  final String date;
  final String schedule;
  final String status;
  final int statusCode;
  final String paymentStatus;
  final int paymentStatusCode;
  final String paymentGateway;
  final String? transactionId;
  final num subTotal;
  final num tax;
  final num deliveryCharge;
  final String? couponCode;
  final num couponAmount;
  final num total;
  final String? orderNote;
  final bool? isRefunded;
  final num? refundAmount;
  final AdminOrderCustomerDetail customer;
  final AdminOrderLocation? location;
  final dynamic outlet;
  final AdminOrderStaff? staff;
  final AdminOrderFranchise? franchise;
  final List<AdminOrderLineItem> items;
  final String createdAt;
  final String updatedAt;

  AdminOrderDetailModel({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.schedule,
    required this.status,
    required this.statusCode,
    required this.paymentStatus,
    required this.paymentStatusCode,
    required this.paymentGateway,
    this.transactionId,
    required this.subTotal,
    required this.tax,
    required this.deliveryCharge,
    this.couponCode,
    required this.couponAmount,
    required this.total,
    this.orderNote,
    this.isRefunded,
    this.refundAmount,
    required this.customer,
    this.location,
    this.outlet,
    this.staff,
    this.franchise,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminOrderDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      final order = _toMap(json['data']).isNotEmpty
          ? _toMap(json['data'])
          : _toMap(json['order']).isNotEmpty
              ? _toMap(json['order'])
              : json;

      final statusInt = AdminOrderItem._toInt(order['status']);
      final pStatusInt = AdminOrderItem._toInt(order['payment_status']);

      return AdminOrderDetailModel(
        id: AdminOrderItem._toInt(order['id']),
        invoiceNumber: order['invoice_number']?.toString() ?? '',
        date: order['date']?.toString() ?? '',
        schedule: order['schedule']?.toString() ?? '',
        status: _statusLabel(statusInt),
        statusCode: statusInt,
        paymentStatus: pStatusInt == 1 ? 'Paid' : 'Unpaid',
        paymentStatusCode: pStatusInt,
        paymentGateway: order['payment_gateway']?.toString() ?? '',
        transactionId: order['transaction_id']?.toString(),
        subTotal: AdminOrderItem._toNum(order['sub_total']),
        tax: AdminOrderItem._toNum(order['tax']),
        deliveryCharge: AdminOrderItem._toNum(order['delivery_charge']),
        couponCode: order['coupon_code']?.toString(),
        couponAmount: AdminOrderItem._toNum(order['coupon_amount']),
        total: AdminOrderItem._toNum(order['total']),
        orderNote: order['order_note']?.toString(),
        isRefunded: order['is_refunded'] == 1 || order['is_refunded'] == true,
        refundAmount: AdminOrderItem._toNum(order['refund_amount']),
        customer: AdminOrderCustomerDetail.fromJson(
          _toMap(order['user']).isNotEmpty
              ? _toMap(order['user'])
              : _toMap(order['customer']),
        ),
        location: order['location'] != null
            ? AdminOrderLocation.fromJson(_toMap(order['location']))
            : null,
        outlet: order['outlet'],
        staff: order['staff'] != null
            ? AdminOrderStaff.fromJson(_toMap(order['staff']))
            : null,
        franchise: _parseFranchise(order),
        items: ((order['items'] ??
                    order['order_details'] ??
                    order['invoice_items']) as List? ??
                [])
            .map((i) {
              try {
                if (i is! Map) return null;
                return AdminOrderLineItem.fromJson(
                    Map<String, dynamic>.from(i));
              } catch (e) {
                debugPrint('Error parsing admin order line item: $e');
                return null;
              }
            })
            .whereType<AdminOrderLineItem>()
            .toList(),
        createdAt: order['created_at']?.toString() ?? '',
        updatedAt: order['updated_at']?.toString() ?? '',
      );
    } catch (e, stack) {
      debugPrint('AdminOrderDetailModel.fromJson Error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  static String _statusLabel(int code) {
    switch (code) {
      case 0: return 'Pending';
      case 1: return 'Accepted';
      case 2: return 'In Progress';
      case 3: return 'Completed';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  static AdminOrderFranchise? _parseFranchise(Map<String, dynamic> order) {
    // Try nested object: "franchise" or "franchise_admin"
    final franchiseObj = order['franchise'] ?? order['franchise_admin'];
    if (franchiseObj is Map && franchiseObj.isNotEmpty) {
      return AdminOrderFranchise.fromJson(Map<String, dynamic>.from(franchiseObj));
    }

    // Fallback: flat fields like franchise_admin_id + franchise_admin_name
    final franchiseId = AdminOrderItem._toInt(
        order['franchise_admin_id'] ?? order['franchise_id']);
    if (franchiseId > 0) {
      return AdminOrderFranchise(
        id: franchiseId,
        name: order['franchise_admin_name']?.toString() ??
            order['franchise_name']?.toString() ??
            'Franchise #$franchiseId',
        location: order['franchise_location']?.toString(),
      );
    }

    return null;
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}

class AdminOrderCustomerDetail {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final dynamic image;

  AdminOrderCustomerDetail({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.image,
  });

  factory AdminOrderCustomerDetail.fromJson(Map<String, dynamic> json) {
    String name = json['name']?.toString() ??
        json['full_name']?.toString() ??
        json['customer_name']?.toString() ??
        '';
    if (name.isEmpty) {
      name = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }

    return AdminOrderCustomerDetail(
      id: AdminOrderItem._toInt(json['id']),
      name: name,
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      image: json['image'],
    );
  }
}

class AdminOrderStaff {
  final int id;
  final String name;

  AdminOrderStaff({required this.id, required this.name});

  factory AdminOrderStaff.fromJson(Map<String, dynamic> json) =>
      AdminOrderStaff(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );
}

class AdminOrderLocation {
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? latitude;
  final String? longitude;

  AdminOrderLocation({
    this.address,
    this.city,
    this.state,
    this.zip,
    this.latitude,
    this.longitude,
  });

  factory AdminOrderLocation.fromJson(Map<String, dynamic> json) =>
      AdminOrderLocation(
        address: json['address'],
        city: json['city'],
        state: json['state'],
        zip: json['zip'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}

class AdminOrderFranchise {
  final int id;
  final String name;
  final String? location;

  AdminOrderFranchise({required this.id, required this.name, this.location});

  factory AdminOrderFranchise.fromJson(Map<String, dynamic> json) {
    String name = json['name']?.toString() ??
        json['franchise_name']?.toString() ??
        '';
    if (name.isEmpty) {
      name = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }
    return AdminOrderFranchise(
      id: json['id'] ?? 0,
      name: name,
      location: json['location']?.toString(),
    );
  }
}

class AdminOrderLineItem {
  final int id;
  final int serviceId;
  final String type;
  final String name;
  final dynamic image;
  final int quantity;
  final num price;
  final num total;

  AdminOrderLineItem({
    required this.id,
    required this.serviceId,
    required this.type,
    required this.name,
    this.image,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory AdminOrderLineItem.fromJson(Map<String, dynamic> json) {
    final serviceGroup = json['service'] as Map<String, dynamic>?;
    final productGroup = json['product'] as Map<String, dynamic>?;

    String name = json['name']?.toString() ??
        json['title']?.toString() ??
        json['item_title']?.toString() ??
        '';

    dynamic image = json['image'] ??
        json['img'] ??
        serviceGroup?['image'] ??
        serviceGroup?['img'] ??
        productGroup?['image'] ??
        productGroup?['img'];

    if (name.isEmpty) {
      if (serviceGroup != null) {
        name = serviceGroup['title']?.toString() ??
            serviceGroup['name']?.toString() ??
            '';
        image ??= serviceGroup['image'];
      } else if (productGroup != null) {
        name = productGroup['title']?.toString() ??
            productGroup['name']?.toString() ??
            '';
        image ??= productGroup['image'];
      }
    }

    num price = AdminOrderItem._toNum(json['price']);
    int quantity =
        AdminOrderItem._toInt(json['quantity'] ?? json['qty'] ?? 1);
    num total = AdminOrderItem._toNum(
        json['total'] ?? json['subtotal'] ?? json['sub_total'] ?? json['amount']);

    if (total == 0 && price > 0) {
      total = price * quantity;
    }

    return AdminOrderLineItem(
      id: AdminOrderItem._toInt(json['id']),
      serviceId: AdminOrderItem._toInt(json['service_id']),
      type: json['type']?.toString() ??
          (productGroup != null ? 'product' : 'service'),
      name: name,
      image: image,
      quantity: quantity,
      price: price,
      total: total,
    );
  }
}
