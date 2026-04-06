class AdminOutletListModel {
  final List<AdminOutletItem> outlets;

  AdminOutletListModel({required this.outlets});

  factory AdminOutletListModel.fromJson(Map<String, dynamic> json) {
    return AdminOutletListModel(
      outlets: (json['data'] as List? ?? [])
          .map((o) => AdminOutletItem.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  factory AdminOutletListModel.empty() => AdminOutletListModel(outlets: []);
}

class AdminOutletItem {
  final int id;
  final String name;
  final String address;
  final String? postCode;
  final String? latitude;
  final String? longitude;
  final int status;

  AdminOutletItem({
    required this.id,
    required this.name,
    required this.address,
    this.postCode,
    this.latitude,
    this.longitude,
    required this.status,
  });

  factory AdminOutletItem.fromJson(Map<String, dynamic> json) {
    return AdminOutletItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      postCode: json['post_code'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: _toInt(json['status']),
    );
  }

  AdminOutletItem copyWith({
    int? id,
    String? name,
    String? address,
    String? postCode,
    String? latitude,
    String? longitude,
    int? status,
  }) {
    return AdminOutletItem(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      postCode: postCode ?? this.postCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
    );
  }
}

// Helpers
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
