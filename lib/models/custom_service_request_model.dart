class CustomServiceRequestListModel {
  final List<CustomServiceRequest> requests;
  final CustomServicePagination pagination;

  CustomServiceRequestListModel({
    required this.requests,
    required this.pagination,
  });

  factory CustomServiceRequestListModel.fromJson(Map<String, dynamic> json) {
    return CustomServiceRequestListModel(
      requests: (json['data'] as List? ?? [])
          .map((e) =>
              CustomServiceRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: CustomServicePagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  factory CustomServiceRequestListModel.empty() =>
      CustomServiceRequestListModel(
        requests: [],
        pagination: CustomServicePagination.empty(),
      );
}

class CustomServiceRequest {
  final int id;
  final String description;
  final String status; // pending, accepted, rejected, completed, cancelled
  final int? ticketId; // set by backend when accepted (for chat)
  final String? adminNote;
  final String createdAt;
  final String updatedAt;

  CustomServiceRequest({
    required this.id,
    required this.description,
    required this.status,
    this.ticketId,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomServiceRequest.fromJson(Map<String, dynamic> json) {
    return CustomServiceRequest(
      id: _toInt(json['id']),
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      ticketId: json['ticket_id'] != null
          ? _toInt(json['ticket_id'])
          : null,
      adminNote: json['admin_note']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted =>
      status == 'accepted' || status == 'open' || status == 'in_progress';
  bool get isCompleted => status == 'completed' || status == 'closed';
  bool get isCancelled => status == 'cancelled' || status == 'rejected';
  bool get isChatEnabled => isAccepted && ticketId != null;

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }
}

class CustomServicePagination {
  final int total;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;

  CustomServicePagination({
    required this.total,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
  });

  factory CustomServicePagination.fromJson(Map<String, dynamic> json) {
    return CustomServicePagination(
      total: json['total'] ?? 0,
      currentPage: json['page'] ?? json['current_page'] ?? 1,
      lastPage: json['totalPages'] ?? json['last_page'] ?? 1,
      nextPageUrl: json['next_page_url']?.toString(),
    );
  }

  factory CustomServicePagination.empty() => CustomServicePagination(
        total: 0,
        currentPage: 1,
        lastPage: 1,
      );

  bool get hasNextPage => currentPage < lastPage;
}
