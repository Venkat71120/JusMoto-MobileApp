import 'package:car_service/models/home_models/services_list_model.dart';

class Chat {
  final dynamic id;
  final String providerName;
  final String? providerImage;
  final Message lastMessage;

  final bool isActive;
  Chat({
    this.id,
    required this.providerName,
    this.providerImage,
    required this.lastMessage,
    this.isActive = false,
  });
}

class Message {
  final dynamic id;
  final String? message;
  final String? file;
  final dynamic senderId;
  final ServiceModel? service;
  final job;
  final DateTime createdAt;

  Message({
    this.id,
    this.message,
    this.file,
    this.senderId,
    this.service,
    this.job,
    required this.createdAt,
  });
}
