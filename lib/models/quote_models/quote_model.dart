class QuoteListModel {
  final bool success;
  final List<QuoteModel> data;
  final Pagination pagination;

  QuoteListModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory QuoteListModel.fromJson(Map<String, dynamic> json) => QuoteListModel(
    success: (json["success"] ?? false).toString() == "true",
    data: List<QuoteModel>.from(
      (json["data"] ?? []).map((x) => QuoteModel.fromJson(x)),
    ),
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
  );

  factory QuoteListModel.empty() =>
      QuoteListModel(success: false, data: [], pagination: Pagination.empty());
}

class QuoteModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String type;
  final String status;
  final String? adminNote;
  final String? quotedPrice;
  final String createdAt;
  final String updatedAt;

  QuoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.adminNote,
    this.quotedPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
    id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
    userId: int.tryParse(json["user_id"]?.toString() ?? '') ?? 0,
    title: json["title"]?.toString() ?? "",
    description: json["description"]?.toString() ?? "",
    type: json["type"]?.toString() ?? "",
    status: json["status"]?.toString() ?? "",
    adminNote: json["admin_note"]?.toString(),
    quotedPrice: json["quoted_price"]?.toString(),
    createdAt: json["created_at"]?.toString() ?? "",
    updatedAt: json["updated_at"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "description": description,
    "type": type,
    "status": status,
    "admin_note": adminNote,
    "quoted_price": quotedPrice,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"] ?? 0,
    page: json["page"] ?? 1,
    limit: json["limit"] ?? 15,
    totalPages: json["totalPages"] ?? 1,
    hasNextPage: json["hasNextPage"] ?? false,
    hasPrevPage: json["hasPrevPage"] ?? false,
  );

  factory Pagination.empty() => Pagination(
    total: 0,
    page: 1,
    limit: 15,
    totalPages: 1,
    hasNextPage: false,
    hasPrevPage: false,
  );
}
