class AdminMediaListModel {
  final List<AdminMediaItem> media;
  final AdminMediaPagination pagination;

  AdminMediaListModel({required this.media, required this.pagination});

  factory AdminMediaListModel.fromJson(Map<String, dynamic> json) {
    return AdminMediaListModel(
      media: (json['data'] as List? ?? [])
          .map((m) => AdminMediaItem.fromJson(m as Map<String, dynamic>))
          .toList(),
      pagination: AdminMediaPagination.fromJson(json['pagination'] ?? {}),
    );
  }

  factory AdminMediaListModel.empty() => AdminMediaListModel(
        media: [],
        pagination: AdminMediaPagination(currentPage: 1, totalPages: 1),
      );
}

class AdminMediaItem {
  final int id;
  final String title;
  final String? path;
  final String? type;
  final String? size;

  AdminMediaItem({
    required this.id,
    required this.title,
    this.path,
    this.type,
    this.size,
  });

  factory AdminMediaItem.fromJson(Map<String, dynamic> json) {
    return AdminMediaItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      path: json['path'],
      type: json['type'],
      size: json['size']?.toString(),
    );
  }

  String get thumbUrl {
    if (path == null) return '';
    if (path!.startsWith('http')) {
      return path!.replaceFirst('/media/', '/media/thumb/');
    }
    return path!; // Should be full URL from backend usually
  }
}

class AdminMediaPagination {
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  AdminMediaPagination({
    required this.currentPage,
    required this.totalPages,
    this.hasNextPage = false,
    this.hasPrevPage = false,
  });

  factory AdminMediaPagination.fromJson(Map<String, dynamic> json) {
    return AdminMediaPagination(
      currentPage: json['page'] ?? json['current_page'] ?? 1,
      totalPages: json['totalPages'] ?? json['total_pages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}
