import 'dart:convert';

import '../address_models/states_model.dart';

TicketListModel ticketListModelFromJson(String str) =>
    TicketListModel.fromJson(json.decode(str));

String ticketListModelToJson(TicketListModel data) =>
    json.encode(data.toJson());

class TicketListModel {
  final List<Ticket> tickets;
  final Pagination? pagination;

  TicketListModel({
    required this.tickets,
    this.pagination,
  });

  factory TicketListModel.fromJson(Map json) => TicketListModel(
        tickets: json["tickets"] == null
            ? []
            : List<Ticket>.from(
                json["tickets"]!.map((x) => Ticket.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "tickets": tickets == null
            ? []
            : List<dynamic>.from(tickets.map((x) => x.toJson())),
      };
}

class Ticket {
  final dynamic id;
  final String? departmentId;
  final dynamic adminId;
  final dynamic userId;
  final String? title;
  final dynamic subject;
  final String? priority;
  final String? status;
  final String? description;
  final DateTime? createdAt;

  Ticket({
    this.id,
    this.departmentId,
    this.adminId,
    this.userId,
    this.title,
    this.subject,
    this.priority,
    this.status,
    this.description,
    this.createdAt,
  });

  factory Ticket.fromJson(Map json) => Ticket(
        id: json["id"],
        departmentId: json["department_id"],
        adminId: json["admin_id"],
        userId: json["user_id"],
        title: json["title"],
        subject: json["subject"],
        priority: json["priority"],
        status: json["status"],
        description: json["description"],
        createdAt: DateTime.tryParse(json["created_at"].toString()),
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

TicketDepartmentsModel ticketDepartmentsModelFromJson(String str) =>
    TicketDepartmentsModel.fromJson(json.decode(str));

String ticketDepartmentsModelToJson(TicketDepartmentsModel data) =>
    json.encode(data.toJson());

class TicketDepartmentsModel {
  final List<Department> departments;

  TicketDepartmentsModel({
    required this.departments,
  });

  factory TicketDepartmentsModel.fromJson(Map json) => TicketDepartmentsModel(
        departments: json["departments"] == null
            ? []
            : List<Department>.from(
                json["departments"]!.map((x) => Department.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "departments": departments == null
            ? []
            : List<dynamic>.from(departments.map((x) => x.toJson())),
      };
}

class Department {
  final dynamic id;
  final String? name;
  final dynamic status;

  Department({
    this.id,
    this.name,
    this.status,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json["id"],
        name: json["name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
      };
}
