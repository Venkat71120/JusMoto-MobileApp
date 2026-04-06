
class AdminTicketListModel {
  final List<AdminTicketItem> tickets;
  final AdminTicketPagination pagination;

  AdminTicketListModel({
    required this.tickets,
    required this.pagination,
  });

  factory AdminTicketListModel.fromJson(Map<String, dynamic> json) {
    return AdminTicketListModel(
      tickets: (json['data'] as List? ?? [])
          .map((t) => AdminTicketItem.fromJson(t as Map<String, dynamic>))
          .toList(),
      pagination: AdminTicketPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory AdminTicketListModel.empty() => AdminTicketListModel(
        tickets: [],
        pagination: AdminTicketPagination.empty(),
      );
}

class AdminTicketPagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminTicketPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminTicketPagination.fromJson(Map<String, dynamic> json) =>
      AdminTicketPagination(
        total: json['total'] ?? 0,
        currentPage: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 1,
        limit: json['limit'] ?? 15,
        hasNextPage: json['hasNextPage'] ?? false,
        hasPrevPage: json['hasPrevPage'] ?? false,
      );

  factory AdminTicketPagination.empty() => AdminTicketPagination(
        total: 0,
        currentPage: 1,
        totalPages: 1,
        limit: 15,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

class AdminTicketItem {
  final int id;
  final String title;
  final String status;
  final String priority;
  final String departmentName;
  final String customerName;
  final String? assignedTo;
  final String createdAt;

  AdminTicketItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.departmentName,
    required this.customerName,
    this.assignedTo,
    required this.createdAt,
  });

  factory AdminTicketItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final dept = json['department'] as Map<String, dynamic>? ?? {};
    final admin = json['admin'] as Map<String, dynamic>? ?? {};

    return AdminTicketItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['subject'] ?? 'No Title',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'low',
      departmentName: dept['name'] ?? 'N/A',
      customerName: '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
      assignedTo: admin['name'],
      createdAt: json['created_at'] ?? '',
    );
  }

  AdminTicketItem copyWith({
    int? id,
    String? title,
    String? status,
    String? priority,
    String? departmentName,
    String? customerName,
    String? assignedTo,
    String? createdAt,
  }) {
    return AdminTicketItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      departmentName: departmentName ?? this.departmentName,
      customerName: customerName ?? this.customerName,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ── Ticket Detail Model ──────────────────────────────────────────────────────

class AdminTicketDetailModel {
  final AdminTicketDetail ticket;
  final AdminTicketServiceRequest? serviceRequest;
  final AdminTicketFranchise? franchise;
  final List<AdminTicketMessage> messages;

  AdminTicketDetailModel({
    required this.ticket,
    this.serviceRequest,
    this.franchise,
    required this.messages,
  });

  factory AdminTicketDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    // Franchise could be at root level, data level, or inside a nested ticket object
    final franchise = _parseFranchise(data) ?? _parseFranchise(json);
    return AdminTicketDetailModel(
      ticket: AdminTicketDetail.fromJson(data),
      serviceRequest: data['order'] != null
          ? AdminTicketServiceRequest.fromJson(
              data['order'] as Map<String, dynamic>)
          : null,
      franchise: franchise,
      messages: (data['ticketMessages'] as List? ??
              data['messages'] as List? ??
              [])
          .map((m) =>
              AdminTicketMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  static AdminTicketFranchise? _parseFranchise(Map<String, dynamic> data) {
    // Try nested objects: franchise, franchise_admin, or admin
    for (final key in ['franchise', 'franchise_admin', 'admin']) {
      final obj = data[key];
      if (obj is Map && obj.isNotEmpty) {
        return AdminTicketFranchise.fromJson(Map<String, dynamic>.from(obj));
      }
    }
    // Try flat ID fields
    final id = _toInt(data['franchise_admin_id'] ??
        data['franchise_id'] ??
        data['admin_id']);
    if (id > 0) {
      return AdminTicketFranchise(
        id: id,
        name: data['franchise_admin_name']?.toString() ??
            data['franchise_name']?.toString() ??
            data['admin_name']?.toString() ??
            'Franchise #$id',
      );
    }
    return null;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

class AdminTicketDetail {
  final int id;
  final int? orderId;
  final String title;
  final String? subject;
  final String? description;
  final String priority;
  final String status;
  final String? departmentName;
  final AdminTicketCustomer customer;
  final String createdAt;
  final String updatedAt;

  AdminTicketDetail({
    required this.id,
    this.orderId,
    required this.title,
    this.subject,
    this.description,
    required this.priority,
    required this.status,
    this.departmentName,
    required this.customer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminTicketDetail.fromJson(Map<String, dynamic> json) {
    final dept = json['department'] as Map<String, dynamic>?;
    return AdminTicketDetail(
      id: (json['id'] is int)
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id'] != null
          ? (json['order_id'] is int
              ? json['order_id']
              : int.tryParse(json['order_id'].toString()))
          : null,
      title: json['title']?.toString() ?? json['subject']?.toString() ?? '',
      subject: json['subject']?.toString(),
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? 'normal',
      status: json['status']?.toString() ?? 'open',
      departmentName: dept?['name'] ?? json['department_name']?.toString(),
      customer: AdminTicketCustomer.fromJson(
        json['user'] as Map<String, dynamic>? ??
            json['customer'] as Map<String, dynamic>? ??
            {},
      ),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class AdminTicketCustomer {
  final int id;
  final String name;
  final String? email;
  final String? phone;

  AdminTicketCustomer(
      {required this.id, required this.name, this.email, this.phone});

  factory AdminTicketCustomer.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString() ?? '';
    final lastName = json['last_name']?.toString() ?? '';
    final name = json['name']?.toString() ??
        (firstName.isEmpty && lastName.isEmpty
            ? ''
            : '$firstName $lastName'.trim());

    return AdminTicketCustomer(
      id: json['id'] ?? 0,
      name: name,
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class AdminTicketFranchise {
  final int id;
  final String name;
  final String? location;

  AdminTicketFranchise({required this.id, required this.name, this.location});

  factory AdminTicketFranchise.fromJson(Map<String, dynamic> json) {
    String name = json['name']?.toString() ??
        json['franchise_name']?.toString() ??
        '';
    if (name.isEmpty) {
      name = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }
    return AdminTicketFranchise(
      id: json['id'] ?? 0,
      name: name,
      location: json['location']?.toString(),
    );
  }
}

class AdminTicketServiceRequest {
  final int id;
  final String invoiceNumber;
  final String status;
  final int statusCode;
  final String paymentStatus;
  final num total;
  final String createdAt;

  AdminTicketServiceRequest({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.statusCode,
    required this.paymentStatus,
    required this.total,
    required this.createdAt,
  });

  factory AdminTicketServiceRequest.fromJson(Map<String, dynamic> json) {
    final statusInt = _toInt(json['status']);
    final pStatusInt = _toInt(json['payment_status']);

    return AdminTicketServiceRequest(
      id: _toInt(json['id']),
      invoiceNumber: json['invoice_number'] ?? json['invoice'] ?? '',
      status: _statusLabel(statusInt),
      statusCode: statusInt,
      paymentStatus: pStatusInt == 1 ? 'Paid' : 'Unpaid',
      total: _toNum(json['total']),
      createdAt: json['created_at']?.toString() ?? '',
    );
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

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }
}

class AdminTicketMessage {
  final int id;
  final String message;
  final String senderType; // "admin" | "user" | "franchise"
  final String? senderName;
  final String? attachment;
  final String createdAt;

  AdminTicketMessage({
    required this.id,
    required this.message,
    required this.senderType,
    this.senderName,
    this.attachment,
    required this.createdAt,
  });

  factory AdminTicketMessage.fromJson(Map<String, dynamic> json) {
    // Determine sender type and name
    String senderType;
    String? senderName;

    final admin = json['admin'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    final franchise = json['franchise'] ?? json['franchise_admin'];

    if (admin != null) {
      senderType = 'admin';
      senderName = admin['name']?.toString();
    } else if (franchise is Map) {
      senderType = 'franchise';
      senderName = franchise['name']?.toString();
    } else if (json['type'] == 'franchise' ||
        json['sender_type'] == 'franchise') {
      senderType = 'franchise';
      senderName = json['sender_name']?.toString();
    } else {
      senderType = 'user';
      senderName = user?['first_name']?.toString() ??
          user?['name']?.toString();
    }

    return AdminTicketMessage(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      senderType: senderType,
      senderName: senderName,
      attachment: json['attachment'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
