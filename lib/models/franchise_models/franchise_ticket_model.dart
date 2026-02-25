// ─────────────────────────────────────────────────────────────────────────────
// MODEL: franchise_ticket_model.dart
// Location: lib/models/franchise_models/franchise_ticket_model.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Statistics ────────────────────────────────────────────────────────────────

class FranchiseTicketStatisticsModel {
  final int total;
  final int open;
  final int closed;
  final int low;
  final int normal;
  final int high;
  final int urgent;

  FranchiseTicketStatisticsModel({
    required this.total,
    required this.open,
    required this.closed,
    required this.low,
    required this.normal,
    required this.high,
    required this.urgent,
  });

  factory FranchiseTicketStatisticsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['statistics'] as Map<String, dynamic>? ?? json;
    final byPriority = stats['by_priority'] as Map<String, dynamic>? ?? {};
    return FranchiseTicketStatisticsModel(
      total: stats['total'] ?? 0,
      open: stats['open'] ?? 0,
      closed: stats['closed'] ?? 0,
      low: byPriority['low'] ?? 0,
      normal: byPriority['normal'] ?? 0,
      high: byPriority['high'] ?? 0,
      urgent: byPriority['urgent'] ?? 0,
    );
  }

  factory FranchiseTicketStatisticsModel.empty() =>
      FranchiseTicketStatisticsModel(
        total: 0, open: 0, closed: 0,
        low: 0, normal: 0, high: 0, urgent: 0,
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
        tickets: (json['tickets'] as List? ?? [])
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
  final String? nextPageUrl;
  final String? prevPageUrl;

  FranchiseTicketPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory FranchiseTicketPagination.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketPagination(
        total: json['total'] ?? 0,
        count: json['count'] ?? 0,
        perPage: json['per_page'] ?? 10,
        currentPage: json['current_page'] ?? 1,
        lastPage: json['last_page'] ?? 1,
        nextPageUrl: json['next_page_url'],
        prevPageUrl: json['prev_page_url'],
      );

  factory FranchiseTicketPagination.empty() => FranchiseTicketPagination(
        total: 0, count: 0, perPage: 10,
        currentPage: 1, lastPage: 1,
      );

  bool get hasNextPage => nextPageUrl != null;
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
        id: json['id'] ?? 0,
        orderId: json['order_id'],
        title: json['title'] ?? '',
        priority: json['priority'] ?? 'normal',
        status: json['status'] ?? 'open',
        department: json['department'] ?? '',
        customer: FranchiseTicketCustomer.fromJson(
          json['customer'] as Map<String, dynamic>? ?? {},
        ),
        lastMessage: json['last_message'],
        lastMessageType: json['last_message_type'],
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
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

  factory FranchiseTicketDetailModel.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketDetailModel(
        ticket: FranchiseTicketDetail.fromJson(
          json['ticket'] as Map<String, dynamic>? ?? {},
        ),
        serviceRequest: json['service_request'] != null
            ? FranchiseTicketServiceRequest.fromJson(
                json['service_request'] as Map<String, dynamic>)
            : null,
        messages: (json['messages'] as List? ?? [])
            .map((m) => FranchiseTicketMessage.fromJson(
                m as Map<String, dynamic>))
            .toList(),
        messagePagination: FranchiseTicketPagination.fromJson(
          json['message_pagination'] as Map<String, dynamic>? ?? {},
        ),
      );
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

  factory FranchiseTicketDetail.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketDetail(
        id: json['id'] ?? 0,
        orderId: json['order_id'],
        title: json['title'] ?? '',
        subject: json['subject'],
        description: json['description'],
        priority: json['priority'] ?? 'normal',
        status: json['status'] ?? 'open',
        department: json['department'] != null
            ? FranchiseTicketDepartment.fromJson(
                json['department'] as Map<String, dynamic>)
            : null,
        customer: FranchiseTicketCustomerDetail.fromJson(
          json['customer'] as Map<String, dynamic>? ?? {},
        ),
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
      );
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

  factory FranchiseTicketServiceRequest.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketServiceRequest(
        id: json['id'] ?? 0,
        invoiceNumber: json['invoice_number'] ?? '',
        date: json['date'] ?? '',
        schedule: json['schedule'] ?? '',
        status: json['status'] ?? '',
        statusCode: json['status_code'] ?? 0,
        paymentStatus: json['payment_status'] ?? '',
        paymentGateway: json['payment_gateway'] ?? '',
        subTotal: json['sub_total'] ?? 0,
        tax: json['tax'] ?? 0,
        deliveryCharge: json['delivery_charge'] ?? 0,
        couponAmount: json['coupon_amount'] ?? 0,
        total: json['total'] ?? 0,
        orderNote: json['order_note'],
        customer: FranchiseTicketCustomer.fromJson(
          json['customer'] as Map<String, dynamic>? ?? {},
        ),
        outlet: json['outlet'] != null
            ? FranchiseTicketOutlet.fromJson(
                json['outlet'] as Map<String, dynamic>)
            : null,
        staff: json['staff'],
        items: (json['items'] as List? ?? [])
            .map((i) => FranchiseTicketOrderItem.fromJson(
                i as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at'] ?? '',
      );
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

  factory FranchiseTicketCustomer.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketCustomer(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'],
        phone: json['phone'],
      );
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

  factory FranchiseTicketCustomerDetail.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketCustomerDetail(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'],
        phone: json['phone'],
        image: json['image'],
      );
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

  factory FranchiseTicketMessage.fromJson(Map<String, dynamic> json) =>
      FranchiseTicketMessage(
        id: json['id'] ?? 0,
        message: json['message'] ?? '',
        type: json['type'] ?? 'user',
        attachment: json['attachment'],
        createdAt: json['created_at'] ?? '',
      );
}