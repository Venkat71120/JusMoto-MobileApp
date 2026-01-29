import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

import '../address_models/states_model.dart';
import '../conversation_model.dart';

ChatListModel chatListModelFromJson(String str) =>
    ChatListModel.fromJson(json.decode(str));

String chatListModelToJson(ChatListModel data) => json.encode(data.toJson());

class ChatListModel {
  final List<ChatModel> chatList;
  final dynamic activeUsers;
  final dynamic activityCheck;
  final Pagination? pagination;

  ChatListModel({
    required this.chatList,
    this.activeUsers,
    this.activityCheck,
    this.pagination,
  });

  factory ChatListModel.fromJson(Map json) => ChatListModel(
        chatList: json["chat_list"] == null
            ? []
            : List<ChatModel>.from(
                json["chat_list"]!.map((x) => ChatModel.fromJson(x))),
        activeUsers: json["active_users"],
        activityCheck: json["activity_check"],
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "chat_list": chatList == null
            ? []
            : List<dynamic>.from(chatList.map((x) => x.toJson())),
        "active_users": activeUsers,
      };
}

class ChatModel {
  final dynamic id;
  final dynamic clientId;
  final String? clientName;
  final String? clientImage;
  final dynamic providerId;
  final String? providerName;
  final String? providerImage;
  final dynamic adminId;
  MessageModel? lastMessage;
  final DateTime? createdAt;
  num clientUnseenMsgCount;
  final num providerUnseenMsgCount;

  ChatModel({
    this.id,
    this.clientId,
    this.clientName,
    this.clientImage,
    this.providerId,
    this.providerName,
    this.providerImage,
    this.adminId,
    this.createdAt,
    required this.clientUnseenMsgCount,
    required this.providerUnseenMsgCount,
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json["id"],
        clientId: json["client_id"],
        clientName: json["client_name"],
        clientImage: json["client_image"],
        providerId: json["provider_id"],
        providerName: json["provider_name"],
        providerImage: json["provider_image"],
        lastMessage: json["last_message"] == null
            ? null
            : MessageModel.fromJson(json["last_message"]),
        adminId: json["admin_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        clientUnseenMsgCount:
            json["client_unseen_msg_count"].toString().tryToParse,
        providerUnseenMsgCount:
            json["provider_unseen_msg_count"].toString().tryToParse,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_id": clientId,
        "client_name": clientName,
        "client_image": clientImage,
        "provider_id": providerId,
        "provider_name": providerName,
        "provider_image": providerImage,
        "admin_id": adminId,
        "created_at": createdAt?.toIso8601String(),
        "client_unseen_msg_count": clientUnseenMsgCount,
        "provider_unseen_msg_count": providerUnseenMsgCount,
      };
}
