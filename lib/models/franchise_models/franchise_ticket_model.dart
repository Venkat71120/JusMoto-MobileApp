// ─────────────────────────────────────────────────────────────────────────────
// MODEL: franchise_ticket_model.dart
// Location: lib/models/franchise_models/franchise_ticket_model.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'franchise_order_model.dart';

// ── Statistics ────────────────────────────────────────────────────────────────

class FranchiseTicketStatisticsModel {
  final int total;
  final int open;
  final int closed;
  final int inProgress;

  FranchiseTicketStatisticsModel({
    required this.total,
    required this.open,
    required this.closed,
    required this.inProgress,
  });

  factory FranchiseTicketStatisticsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['data'] as Map<String, dynamic>? ?? json;
    return FranchiseTicketStatisticsModel(
      total: stats['total'] ?? 0,
      open: stats['open'] ?? 0,
      closed: stats['closed'] ?? 0,
      inProgress: stats['in_progress'] ?? 0,
    );
  }

  factory FranchiseTicketStatisticsModel.empty() =>
      FranchiseTicketStatisticsModel(
        total: 0,
        open: 0,
        closed: 0,
        inProgress: 0,
      );
}

// ── Ticket List ───────────────────────────────────────────────────────────────

class FranchiseTicketListModel {
  final List<FranchiseTicketItem> tickets;
  final FranchiseTicketPagination pagination;

  FranchiseTicketListModel({
    required this.tickets,
    required this.pagination,
  });

  factory FranchiseTicketListModel.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketListModel(
        tickets: (json['data'] as List? ?? [])
            .map((t) =>
                FranchiseTicketItem.fromJson(t as Map<String, dynamic>))
            .toList(),
        pagination: FranchiseTicketPagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {},
        ),
      );

  factory FranchiseTicketListModel.empty() => FranchiseTicketListModel(
        tickets: [],
        pagination: FranchiseTicketPagination.empty(),
      );
}

class FranchiseTicketPagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  FranchiseTicketPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.hasNextPage = false,
    this.hasPrevPage = false,
  });

  factory FranchiseTicketPagination.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketPagination(
        total: json['total'] ?? 0,
        count: json['count'] ?? 0,
        perPage: json['limit'] ?? 15,
        currentPage: json['page'] ?? 1,
        lastPage: json['totalPages'] ?? 1,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory FranchiseTicketPagination.empty() => FranchiseTicketPagination(
        total: 0,
        count: 0,
        perPage: 15,
        currentPage: 1,
        lastPage: 1,
      );
}

class FranchiseTicketItem {
  final int id;
  final int? orderId;
  final String title;
  final String priority;
  final String status;
  final String department;
  final FranchiseTicketCustomer customer;
  final String? lastMessage;
  final String? lastMessageType;
  final String createdAt;
  final String updatedAt;

  FranchiseTicketItem({
    required this.id,
    this.orderId,
    required this.title,
    required this.priority,
    required this.status,
    required this.department,
    required this.customer,
    this.lastMessage,
    this.lastMessageType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FranchiseTicketItem.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketItem(
        id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        orderId: json['order_id'] != null ? (json['order_id'] is int ? json['order_id'] : int.tryParse(json['order_id'].toString())) : null,
        title: json['title']?.toString() ?? json['subject']?.toString() ?? '',
        priority: json['priority']?.toString() ?? 'normal',
        status: json['status']?.toString() ?? 'open',
        department: json['department_id']?.toString() ?? '',
        customer: FranchiseTicketCustomer.fromJson(
          json['user'] as Map<String, dynamic>? ?? {},
        ),
        lastMessage: json['description']?.toString(),
        lastMessageType: json['via']?.toString(),
        createdAt: json['created_at']?.toString() ?? '',
        updatedAt: json['updated_at']?.toString() ?? '',
      );
}

// ── Ticket Detail ─────────────────────────────────────────────────────────────

class FranchiseTicketDetailModel {
  final FranchiseTicketDetail ticket;
  final FranchiseTicketServiceRequest? serviceRequest;
  final List<FranchiseTicketMessage> messages;
  final FranchiseTicketPagination messagePagination;

  FranchiseTicketDetailModel({
    required this.ticket,
    this.serviceRequest,
    required this.messages,
    required this.messagePagination,
  });

  factory FranchiseTicketDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return FranchiseTicketDetailModel(
      ticket: FranchiseTicketDetail.fromJson(data),
      serviceRequest: data['order'] != null
          ? FranchiseTicketServiceRequest.fromJson(
              data['order'] as Map<String, dynamic>)
          : null,
      messages: (data['ticketMessages'] as List? ?? [])
          .map((m) =>
              FranchiseTicketMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      messagePagination: FranchiseTicketPagination.fromJson(
        data['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class FranchiseTicketDetail {
  final int id;
  final int? orderId;
  final String title;
  final String? subject;
  final String? description;
  final String priority;
  final String status;
  final FranchiseTicketDepartment? department;
  final FranchiseTicketCustomerDetail customer;
  final String createdAt;
  final String updatedAt;

  FranchiseTicketDetail({
    required this.id,
    this.orderId,
    required this.title,
    this.subject,
    this.description,
    required this.priority,
    required this.status,
    this.department,
    required this.customer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FranchiseTicketDetail.fromJson(Map<String, dynamic> json) {
    // Some APIs return status as int, we need it as String for the UI
    final statusRaw = json['status'];
    final priorityRaw = json['priority'];
    
    return FranchiseTicketDetail(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id'] != null ? (json['order_id'] is int ? json['order_id'] : int.tryParse(json['order_id'].toString())) : null,
      title: json['title']?.toString() ?? json['subject']?.toString() ?? '',
      subject: json['subject']?.toString(),
      description: json['description']?.toString(),
      priority: priorityRaw?.toString() ?? 'normal',
      status: statusRaw?.toString() ?? 'open',
      department: json['department_id'] != null
          ? FranchiseTicketDepartment(
              id: (json['department_id'] is int) ? json['department_id'] : int.tryParse(json['department_id']?.toString() ?? '0') ?? 0,
              name: json['department']?['name'] ?? json['department_name'] ?? '')
          : null,
      customer: FranchiseTicketCustomerDetail.fromJson(
        json['user'] as Map<String, dynamic>? ?? json['customer'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class FranchiseTicketDepartment {
  final int id;
  final String name;

  FranchiseTicketDepartment({required this.id, required this.name});

  factory FranchiseTicketDepartment.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketDepartment(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );
}

// ── Service Request (linked order) ───────────────────────────────────────────

class FranchiseTicketServiceRequest {
  final int id;
  final String invoiceNumber;
  final String date;
  final String schedule;
  final String status;
  final int statusCode;
  final String paymentStatus;
  final String paymentGateway;
  final num subTotal;
  final num tax;
  final num deliveryCharge;
  final num couponAmount;
  final num total;
  final String? orderNote;
  final FranchiseTicketCustomer customer;
  final FranchiseTicketOutlet? outlet;
  final dynamic staff;
  final List<FranchiseTicketOrderItem> items;
  final String createdAt;

  FranchiseTicketServiceRequest({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.schedule,
    required this.status,
    required this.statusCode,
    required this.paymentStatus,
    required this.paymentGateway,
    required this.subTotal,
    required this.tax,
    required this.deliveryCharge,
    required this.couponAmount,
    required this.total,
    this.orderNote,
    required this.customer,
    this.outlet,
    this.staff,
    required this.items,
    required this.createdAt,
  });

  factory FranchiseTicketServiceRequest.fromJson(Map<String, dynamic> json) {
    final statusInt = _toInt(json['status']);
    final pStatusInt = _toInt(json['payment_status']);

    return FranchiseTicketServiceRequest(
      id: _toInt(json['id']),
      invoiceNumber: json['invoice_number'] ?? json['invoice'] ?? '',
      date: json['date']?.toString() ?? '',
      schedule: json['schedule']?.toString() ?? '',
      status: FranchiseOrderItem.statusLabel(statusInt),
      statusCode: statusInt,
      paymentStatus: FranchiseOrderItem.paymentStatusLabel(pStatusInt),
      paymentGateway: json['payment_gateway']?.toString() ?? '',
      subTotal: _toNum(json['total'] ?? json['sub_total']),
      tax: _toNum(json['tax']),
      deliveryCharge: _toNum(json['delivery_charge']),
      couponAmount: _toNum(json['coupon_amount']),
      total: _toNum(json['total']),
      orderNote: json['order_note']?.toString(),
      customer: FranchiseTicketCustomer.fromJson(
        json['user'] as Map<String, dynamic>? ??
            json['customer'] as Map<String, dynamic>? ??
            {},
      ),
      outlet: json['outlet'] != null
          ? FranchiseTicketOutlet.fromJson(
              json['outlet'] as Map<String, dynamic>)
          : null,
      staff: json['staff'],
      createdAt: json['created_at']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((i) =>
              FranchiseTicketOrderItem.fromJson(i as Map<String, dynamic>))
          .where((item) => item.type.toLowerCase() != 'accessory')
          .toList(),
    );
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static num _toNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    return num.tryParse(val.toString()) ?? 0;
  }
}

class FranchiseTicketOutlet {
  final int id;
  final String name;
  final String? address;

  FranchiseTicketOutlet({required this.id, required this.name, this.address});

  factory FranchiseTicketOutlet.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketOutlet(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        address: json['address'],
      );
}

class FranchiseTicketOrderItem {
  final int id;
  final int serviceId;
  final String type;
  final String name;
  final dynamic image;
  final int quantity;
  final num price;
  final num total;

  FranchiseTicketOrderItem({
    required this.id,
    required this.serviceId,
    required this.type,
    required this.name,
    this.image,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory FranchiseTicketOrderItem.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketOrderItem(
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

// ── Shared customer models ────────────────────────────────────────────────────

class FranchiseTicketCustomer {
  final int id;
  final String name;
  final String? email;
  final String? phone;

  FranchiseTicketCustomer(
      {required this.id, required this.name, this.email, this.phone});

  factory FranchiseTicketCustomer.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString() ?? '';
    final lastName = json['last_name']?.toString() ?? '';
    final name = json['name']?.toString() ?? 
                (firstName.isEmpty && lastName.isEmpty ? '' : '$firstName $lastName'.trim());

    return FranchiseTicketCustomer(
      id: json['id'] ?? 0,
      name: name,
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class FranchiseTicketCustomerDetail {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final dynamic image;

  FranchiseTicketCustomerDetail({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.image,
  });

  factory FranchiseTicketCustomerDetail.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString() ?? '';
    final lastName = json['last_name']?.toString() ?? '';
    final name = json['name']?.toString() ?? 
                (firstName.isEmpty && lastName.isEmpty ? '' : '$firstName $lastName'.trim());

    return FranchiseTicketCustomerDetail(
      id: json['id'] ?? 0,
      name: name,
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      image: json['image'],
    );
  }
}

// ── Message ───────────────────────────────────────────────────────────────────

class FranchiseTicketMessage {
  final int id;
  final String message;
  final String type; // "admin" | "user"
  final String? attachment;
  final String createdAt;

  FranchiseTicketMessage({
    required this.id,
    required this.message,
    required this.type,
    this.attachment,
    required this.createdAt,
  });

  factory FranchiseTicketMessage.fromJson(Map<String, dynamic> json) {
    final admin = json['admin'] as Map<String, dynamic>?;
    final type = admin != null ? 'admin' : 'user';

    return FranchiseTicketMessage(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      type: type,
      attachment: json['attachment'],
      createdAt: json['created_at'] ?? '',
    );
  }
}