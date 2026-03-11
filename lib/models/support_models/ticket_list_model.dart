import 'dart:convert';

import '../address_models/states_model.dart';

TicketListModel ticketListModelFromJson(String str) =>
    TicketListModel.fromJson(json.decode(str));

String ticketListModelToJson(TicketListModel data) =>
    json.encode(data.toJson());

class TicketListModel {
  final List<Ticket> tickets;
  final Pagination? pagination;

  TicketListModel({required this.tickets, this.pagination});

  factory TicketListModel.fromJson(Map json) => TicketListModel(
    tickets:
        json["data"] == null && json["tickets"] == null
            ? []
            : List<Ticket>.from(
              (json["data"] ?? json["tickets"] ?? []).map(
                (x) => Ticket.fromJson(x),
              ),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data":
        tickets == null
            ? []
            : List<dynamic>.from(tickets.map((x) => x.toJson())),
  };
}

class TicketUser {
  final dynamic id;
  final String? firstName;
  final String? lastName;
  final String? email;

  TicketUser({this.id, this.firstName, this.lastName, this.email});

  factory TicketUser.fromJson(Map json) => TicketUser(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
  };
}

class Ticket {
  final dynamic id;
  final String? departmentId;
  final dynamic adminId;
  final dynamic userId;
  final dynamic orderId;
  final String? title;
  final dynamic subject;
  final String? priority;
  final String? status;
  final String? via;
  final String? operatingSystem;
  final String? userAgent;
  final String? description;
  final DateTime? createdAt;
  final TicketUser? user;

  Ticket({
    this.id,
    this.departmentId,
    this.adminId,
    this.userId,
    this.orderId,
    this.title,
    this.subject,
    this.priority,
    this.status,
    this.via,
    this.operatingSystem,
    this.userAgent,
    this.description,
    this.createdAt,
    this.user,
  });

  factory Ticket.fromJson(Map json) => Ticket(
    id: json["id"],
    departmentId: json["department_id"]?.toString(),
    adminId: json["admin_id"],
    userId: json["user_id"],
    orderId: json["order_id"],
    title: json["title"],
    subject: json["subject"],
    priority: json["priority"],
    status: json["status"],
    via: json["via"],
    operatingSystem: json["operating_system"],
    userAgent: json["user_agent"],
    description: json["description"],
    createdAt:
        json["created_at"] != null
            ? DateTime.tryParse(json["created_at"].toString())
            : null,
    user: json["user"] != null ? TicketUser.fromJson(json["user"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "department_id": departmentId,
    "admin_id": adminId,
    "user_id": userId,
    "order_id": orderId,
    "title": title,
    "subject": subject,
    "priority": priority,
    "status": status,
    "via": via,
    "operating_system": operatingSystem,
    "user_agent": userAgent,
    "description": description,
    "user": user?.toJson(),
  };
}

TicketDepartmentsModel ticketDepartmentsModelFromJson(String str) =>
    TicketDepartmentsModel.fromJson(json.decode(str));

String ticketDepartmentsModelToJson(TicketDepartmentsModel data) =>
    json.encode(data.toJson());

class TicketDepartmentsModel {
  final List<Department> departments;

  TicketDepartmentsModel({required this.departments});

  factory TicketDepartmentsModel.fromJson(Map json) => TicketDepartmentsModel(
    departments:
        json["data"] == null
            ? []
            : List<Department>.from(
              json["data"]!.map((x) => Department.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "data":
        departments == null
            ? []
            : List<dynamic>.from(departments.map((x) => x.toJson())),
  };
}

class Department {
  final dynamic id;
  final String? name;
  final dynamic status;

  Department({this.id, this.name, this.status});

  factory Department.fromJson(Map<String, dynamic> json) =>
      Department(id: json["id"], name: json["name"], status: json["status"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "status": status};
}
