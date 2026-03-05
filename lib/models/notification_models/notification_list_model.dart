import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

import '../address_models/states_model.dart';

NotificationListModel notificationListModelFromJson(String str) =>
    NotificationListModel.fromJson(json.decode(str));

String notificationListModelToJson(NotificationListModel data) =>
    json.encode(data.toJson());

class NotificationListModel {
  final List<NotificationModel> notifications;
  final Pagination? pagination;

  NotificationListModel({required this.notifications, this.pagination});

  factory NotificationListModel.fromJson(Map json) => NotificationListModel(
    notifications:
        json["data"] == null
            ? []
            : List<NotificationModel>.from(
              json["data"]!.map((x) => NotificationModel.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "notifications":
        notifications == null
            ? []
            : List<dynamic>.from(notifications.map((x) => x.toJson())),
  };
}

class NotificationModel {
  final dynamic id;
  final dynamic identity;
  final dynamic userId;
  final String? type;
  final String? title;
  final String? message;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    this.identity,
    this.userId,
    this.type,
    this.title,
    this.message,
    required this.isRead,
    this.data,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        identity: json["identity"],
        userId: json["notifiable_id"] ?? json["user_id"],
        type: json["type"],
        title: json["title"],
        message: json["message"],
        isRead:
            json["read_at"] != null
                ? true
                : (json["is_read"]?.toString().parseToBool ?? false),
        data: json["data"],
        createdAt: DateTime.tryParse(json["created_at"].toString()),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "identity": identity,
    "user_id": userId,
    "type": type,
    "title": title,
    "message": message,
    "is_read": isRead,
    "data": data,
    "created_at": createdAt?.toIso8601String(),
  };
}
