// ─────────────────────────────────────────────────────────────────────────────
// MODEL: franchise_order_model.dart
// Location: lib/models/franchise_models/franchise_order_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Order List Item ───────────────────────────────────────────────────────────

class FranchiseOrderListModel {
  final List<FranchiseOrderItem> orders;
  final FranchiseOrderPagination pagination;

  FranchiseOrderListModel({
    required this.orders,
    required this.pagination,
  });

  factory FranchiseOrderListModel.fromJson(Map<String, dynamic> json) {
    return FranchiseOrderListModel(
      orders: (json['orders'] as List? ?? [])
          .map((o) => FranchiseOrderItem.fromJson(o as Map<String, dynamic>))
          .toList(),
      pagination: FranchiseOrderPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory FranchiseOrderListModel.empty() => FranchiseOrderListModel(
        orders: [],
        pagination: FranchiseOrderPagination.empty(),
      );
}

class FranchiseOrderPagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  FranchiseOrderPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory FranchiseOrderPagination.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderPagination(
        total: json['total'] ?? 0,
        count: json['count'] ?? 0,
        perPage: json['per_page'] ?? 10,
        currentPage: json['current_page'] ?? 1,
        lastPage: json['last_page'] ?? 1,
        nextPageUrl: json['next_page_url'],
        prevPageUrl: json['prev_page_url'],
      );

  factory FranchiseOrderPagination.empty() => FranchiseOrderPagination(
        total: 0,
        count: 0,
        perPage: 10,
        currentPage: 1,
        lastPage: 1,
      );

  bool get hasNextPage => nextPageUrl != null;
}

class FranchiseOrderItem {
  final int id;
  final String invoiceNumber;
  final String date;
  final String schedule;
  final String status;
  final int statusCode;
  final String paymentStatus;
  final int paymentStatusCode;
  final num total;
  final FranchiseOrderCustomer customer;
  final FranchiseOrderStaff? staff;
  final int itemsCount;
  final String createdAt;

  FranchiseOrderItem({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.schedule,
    required this.status,
    required this.statusCode,
    required this.paymentStatus,
    required this.paymentStatusCode,
    required this.total,
    required this.customer,
    this.staff,
    required this.itemsCount,
    required this.createdAt,
  });

  factory FranchiseOrderItem.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderItem(
        id: json['id'] ?? 0,
        invoiceNumber: json['invoice_number'] ?? '',
        date: json['date'] ?? '',
        schedule: json['schedule'] ?? '',
        status: json['status'] ?? '',
        statusCode: json['status_code'] ?? 0,
        paymentStatus: json['payment_status'] ?? '',
        paymentStatusCode: json['payment_status_code'] ?? 0,
        total: json['total'] ?? 0,
        customer: FranchiseOrderCustomer.fromJson(
          json['customer'] as Map<String, dynamic>? ?? {},
        ),
        staff: json['staff'] != null
            ? FranchiseOrderStaff.fromJson(
                json['staff'] as Map<String, dynamic>)
            : null,
        itemsCount: json['items_count'] ?? 0,
        createdAt: json['created_at'] ?? '',
      );
}

// ── Order Detail ──────────────────────────────────────────────────────────────

class FranchiseOrderDetailModel {
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
  final FranchiseOrderCustomerDetail customer;
  final FranchiseOrderLocation? location;
  final dynamic outlet;
  final FranchiseOrderStaff? staff;
  final List<FranchiseOrderLineItem> items;
  final String createdAt;
  final String updatedAt;

  FranchiseOrderDetailModel({
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
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FranchiseOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>? ?? json;
    return FranchiseOrderDetailModel(
      id: order['id'] ?? 0,
      invoiceNumber: order['invoice_number'] ?? '',
      date: order['date'] ?? '',
      schedule: order['schedule'] ?? '',
      status: order['status'] ?? '',
      statusCode: order['status_code'] ?? 0,
      paymentStatus: order['payment_status'] ?? '',
      paymentStatusCode: order['payment_status_code'] ?? 0,
      paymentGateway: order['payment_gateway'] ?? '',
      transactionId: order['transaction_id'],
      subTotal: order['sub_total'] ?? 0,
      tax: order['tax'] ?? 0,
      deliveryCharge: order['delivery_charge'] ?? 0,
      couponCode: order['coupon_code'],
      couponAmount: order['coupon_amount'] ?? 0,
      total: order['total'] ?? 0,
      orderNote: order['order_note'],
      isRefunded: order['is_refunded'],
      refundAmount: order['refund_amount'],
      customer: FranchiseOrderCustomerDetail.fromJson(
        order['customer'] as Map<String, dynamic>? ?? {},
      ),
      location: order['location'] != null
          ? FranchiseOrderLocation.fromJson(
              order['location'] as Map<String, dynamic>)
          : null,
      outlet: order['outlet'],
      staff: order['staff'] != null
          ? FranchiseOrderStaff.fromJson(order['staff'] as Map<String, dynamic>)
          : null,
      items: (order['items'] as List? ?? [])
          .map((i) =>
              FranchiseOrderLineItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdAt: order['created_at'] ?? '',
      updatedAt: order['updated_at'] ?? '',
    );
  }
}

// ── Shared sub-models ─────────────────────────────────────────────────────────

class FranchiseOrderCustomer {
  final int id;
  final String name;
  final String? phone;

  FranchiseOrderCustomer({
    required this.id,
    required this.name,
    this.phone,
  });

  factory FranchiseOrderCustomer.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderCustomer(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        phone: json['phone'],
      );
}

class FranchiseOrderCustomerDetail {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final dynamic image;

  FranchiseOrderCustomerDetail({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.image,
  });

  factory FranchiseOrderCustomerDetail.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderCustomerDetail(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'],
        phone: json['phone'],
        image: json['image'],
      );
}

class FranchiseOrderStaff {
  final int id;
  final String name;

  FranchiseOrderStaff({required this.id, required this.name});

  factory FranchiseOrderStaff.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderStaff(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );
}

class FranchiseOrderLocation {
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? latitude;
  final String? longitude;

  FranchiseOrderLocation({
    this.address,
    this.city,
    this.state,
    this.zip,
    this.latitude,
    this.longitude,
  });

  factory FranchiseOrderLocation.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderLocation(
        address: json['address'],
        city: json['city'],
        state: json['state'],
        zip: json['zip'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}

class FranchiseOrderLineItem {
  final int id;
  final int serviceId;
  final String type; // "product" | "service"
  final String name;
  final dynamic image;
  final int quantity;
  final num price;
  final num total;

  FranchiseOrderLineItem({
    required this.id,
    required this.serviceId,
    required this.type,
    required this.name,
    this.image,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory FranchiseOrderLineItem.fromJson(Map<String, dynamic> json) =>
      FranchiseOrderLineItem(
        id: json['id'] ?? 0,
        serviceId: json['service_id'] ?? 0,
        type: json['type'] ?? 'service',
        name: json['name'] ?? '',
        image: json['image'],
        quantity: json['quantity'] ?? 1,
        price: json['price'] ?? 0,
        total: json['total'] ?? 0,
      );
}