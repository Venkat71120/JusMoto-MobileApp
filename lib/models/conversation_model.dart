import 'dart:convert';

import 'address_models/states_model.dart';

ConversationModel conversationModelFromJson(String str) =>
    ConversationModel.fromJson(json.decode(str));

String conversationModelToJson(ConversationModel data) =>
    json.encode(data.toJson());

class ConversationModel {
  final List<MessageModel>? allMessage;
  final Pagination? pagination;

  ConversationModel({this.allMessage, this.pagination});

  factory ConversationModel.fromJson(Map json) => ConversationModel(
        allMessage: json["all_message"] == null
            ? null
            : List<MessageModel>.from(
                json["all_message"]!.map((x) => MessageModel.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {};
}

class AllMessage {
  List<MessageModel>? data;
  dynamic nextPageUrl;

  AllMessage({
    this.data,
    this.nextPageUrl,
  });

  factory AllMessage.fromJson(Map<String, dynamic> json) => AllMessage(
        data: json["data"] == null
            ? []
            : List<MessageModel>.from(
                json["data"]!.map((x) => MessageModel.fromJson(x))),
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class MessageModel {
  dynamic id;
  dynamic liveChatId;
  dynamic fromUser;
  Message? message;
  String? messageText;
  dynamic file;
  dynamic isSeen;
  DateTime? createdAt;
  DateTime? updatedAt;

  MessageModel({
    this.id,
    this.liveChatId,
    this.fromUser,
    this.message,
    this.messageText,
    this.file,
    this.isSeen,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["id"],
        liveChatId: json["live_chat_id"],
        fromUser: json["from_user"],
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
        messageText: json["message_title"],
        file: json["file"],
        isSeen: json["is_seen"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "live_chat_id": liveChatId,
        "from_user": fromUser,
        "message": message?.toJson(),
        "file": file,
        "is_seen": isSeen,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Message {
  String? message;
  Project? project;

  Message({
    this.message,
    this.project,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        message: json["message"],
        project:
            json["project"] == null ? null : Project.fromJson(json["project"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "project": project?.toJson(),
      };
}

class Project {
  dynamic id;
  dynamic projectCreator;
  String? username;
  String? title;
  String? slug;
  String? image;
  String? type;
  String? interviewMessage;

  Project({
    this.id,
    this.projectCreator,
    this.username,
    this.title,
    this.slug,
    this.image,
    this.type,
    this.interviewMessage,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json["id"],
        projectCreator: json["project_creator"],
        username: json["username"],
        title: json["title"],
        slug: json["slug"],
        image: json["image"],
        type: json["type"],
        interviewMessage: json["interview_message"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "project_creator": projectCreator,
        "username": username,
        "title": title,
        "slug": slug,
        "image": image,
        "type": type,
        "interview_message": interviewMessage,
      };
}
