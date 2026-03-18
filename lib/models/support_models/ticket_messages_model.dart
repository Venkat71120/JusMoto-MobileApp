import 'dart:convert';

import '../address_models/states_model.dart';

TicketMessagesModel ticketMessagesModelFromJson(String str) =>
    TicketMessagesModel.fromJson(json.decode(str));

String ticketMessagesModelToJson(TicketMessagesModel data) =>
    json.encode(data.toJson());

class TicketMessagesModel {
  final TicketDetails? ticketDetails;
  final List<TicketMessage> messages;
  final Pagination? pagination;

  TicketMessagesModel({
    this.ticketDetails,
    required this.messages,
    this.pagination,
  });

  factory TicketMessagesModel.fromJson(Map json) {
    var data = json["data"];
    if (data != null) {
      return TicketMessagesModel(
        ticketDetails: TicketDetails.fromJson(data),
        messages:
            data["ticketMessages"] == null
                ? []
                : List<TicketMessage>.from(
                  data["ticketMessages"].map((x) => TicketMessage.fromJson(x)),
                ),
        pagination: null,
      );
    }
    return TicketMessagesModel(
      ticketDetails:
          json["ticket_details"] == null
              ? null
              : TicketDetails.fromJson(json["ticket_details"]),
      messages:
          json["messages"] == null
              ? []
              : List<TicketMessage>.from(
                json["messages"]!.map((x) => TicketMessage.fromJson(x)),
              ),
      pagination:
          json["pagination"] == null
              ? null
              : Pagination.fromJson(json["pagination"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "ticket_details": ticketDetails?.toJson(),
    "messages":
        messages == null
            ? []
            : List<dynamic>.from(messages.map((x) => x.toJson())),
  };
}

class TicketMessage {
  final dynamic id;
  final dynamic ticketId;
  final String? message;
  final String? notify;
  final String? attachment;
  final String? type;
  final DateTime? createdAt;

  TicketMessage({
    this.id,
    this.ticketId,
    this.message,
    this.notify,
    this.attachment,
    this.type,
    this.createdAt,
  });

  factory TicketMessage.fromJson(Map json) => TicketMessage(
    id: json["id"],
    ticketId: json["ticket_id"],
    message: json["message"],
    notify: json["notify"],
    attachment: json["attachment"],
    type: json["type"] ?? (json["admin_id"] != null ? "admin" : "user"),
    createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"].toString()) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticket_id": ticketId,
    "message": message,
    "notify": notify,
    "attachment": attachment,
    "type": type,
    "created_at": createdAt?.toIso8601String(),
  };
}

class TicketDetails {
  final dynamic id;
  final dynamic departmentId;
  final dynamic adminId;
  final dynamic userId;
  final String? title;
  final dynamic subject;
  final String? priority;
  final String? status;
  final String? description;

  TicketDetails({
    this.id,
    this.departmentId,
    this.adminId,
    this.userId,
    this.title,
    this.subject,
    this.priority,
    this.status,
    this.description,
  });

  factory TicketDetails.fromJson(Map<String, dynamic> json) => TicketDetails(
    id: json["id"],
    departmentId: json["department_id"],
    adminId: json["admin_id"],
    userId: json["user_id"],
    title: json["title"],
    subject: json["subject"],
    priority: json["priority"],
    status: json["status"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "department_id": departmentId,
    "admin_id": adminId,
    "user_id": userId,
    "title": title,
    "subject": subject,
    "priority": priority,
    "status": status,
    "description": description,
  };
}
