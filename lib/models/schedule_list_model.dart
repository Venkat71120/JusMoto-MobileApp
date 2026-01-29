import 'dart:convert';

ScheduleListModel scheduleListModelFromJson(String str) =>
    ScheduleListModel.fromJson(json.decode(str));

String scheduleListModelToJson(ScheduleListModel data) =>
    json.encode(data.toJson());

class ScheduleListModel {
  final List<Schedule> schedules;

  ScheduleListModel({
    required this.schedules,
  });

  factory ScheduleListModel.fromJson(Map json) => ScheduleListModel(
        schedules: json["schedules"] == null
            ? []
            : List<Schedule>.from(
                json["schedules"]!.map((x) => Schedule.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "schedules": List<dynamic>.from(schedules.map((x) => x.toJson())),
      };
}

class Schedule {
  final dynamic id;
  final dynamic providerId;
  final String? day;
  final String? value;
  final dynamic status;

  Schedule({
    this.id,
    this.providerId,
    this.day,
    this.value,
    this.status,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json["id"],
        providerId: json["provider_id"],
        day: json["day"],
        value: json["schedule"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "provider_id": providerId,
        "day": day,
        "schedule": value,
        "status": status,
      };
}
