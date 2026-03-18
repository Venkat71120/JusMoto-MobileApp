import 'dart:async';
import 'dart:io';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/support_models/ticket_messages_model.dart';

class TicketConversationService with ChangeNotifier {
  List<TicketMessage> messagesList = [];
  TicketDetails? ticketDetails;
  bool isLoading = false;
  String message = '';
  bool noMessage = false;
  bool msgSendingLoading = false;
  bool noMoreMessages = false;
  String? nextPage;
  bool nextPageLoading = false;

  setIsLoading(value) {
    isLoading = value;
    notifyListeners();
  }

  setMsgSendingLoading() {
    msgSendingLoading = true;
    notifyListeners();
  }

  setMessage(value) {
    message = value;
    notifyListeners();
  }

  clearAllMessages() {
    messagesList = [];
    noMessage = false;
    noMoreMessages = false;
    ticketDetails = null;
    notifyListeners();
  }

  Future fetchSingleTickets(BuildContext context, id) async {
    final url = "${AppUrls.fetchTicketConversationUrl}/$id";
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.message,
      headers: commonAuthHeader,
    );

    if (responseData != null) {
      final temTicketModel = TicketMessagesModel.fromJson(responseData);
      messagesList = temTicketModel.messages.reversed.toList();
      ticketDetails = temTicketModel.ticketDetails;
      noMessage = temTicketModel.messages.isEmpty;
      nextPage = temTicketModel.pagination?.nextPageUrl;
      if (messagesList.length < 20) {
        noMoreMessages = true;
      }
    } else {}
    setIsLoading(false);
  }

  Future fetchSingleTicketsSilently(BuildContext context, id) async {
    final url = "${AppUrls.fetchTicketConversationUrl}/$id";
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.message,
      headers: commonAuthHeader,
    );

    if (responseData != null) {
      final temTicketModel = TicketMessagesModel.fromJson(responseData);
      // Update only if there are new messages to prevent unnecessary rebuilds if possible
      if (temTicketModel.messages.length != messagesList.length) {
        messagesList = temTicketModel.messages.reversed.toList();
        ticketDetails = temTicketModel.ticketDetails;
        noMessage = temTicketModel.messages.isEmpty;
        nextPage = temTicketModel.pagination?.nextPageUrl;
        if (messagesList.length < 20) {
          noMoreMessages = true;
        }
        notifyListeners();
      }
    }
  }

  Future sendMessage(
    BuildContext context,
    id, {
    required String message,
    bool notifyViaMail = false,
    File? file,
  }) async {
    final url = "${AppUrls.sendTicketMessageUrl}/$id/messages";
    nextPageLoading = false;
    var headers = {'Authorization': 'Bearer $getToken'};
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll({'message': message});
    if (file != null) {
      String extension = file.path.split('.').last.toLowerCase();
      MediaType? mediaType;
      if (['jpg', 'jpeg'].contains(extension)) {
        mediaType = MediaType('image', 'jpeg');
      } else if (extension == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (extension == 'gif') {
        mediaType = MediaType('image', 'gif');
      } else if (extension == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else if (extension == 'pdf') {
        mediaType = MediaType('application', 'pdf');
      } else if (extension == 'doc') {
        mediaType = MediaType('application', 'msword');
      } else if (extension == 'docx') {
        mediaType = MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          file.path,
          contentType: mediaType,
        ),
      );
    }
    request.headers.addAll(headers);

    final responseData = await NetworkApiServices().postWithFileApi(
      request,
      LocalKeys.sendMessage,
    );

    if (responseData != null) {
      debugPrint('📥 TicketConversationService.sendMessage response: $responseData');
      if (responseData["data"] != null) {
        messagesList.insert(0, TicketMessage.fromJson(responseData["data"]));
      } else if (responseData["ticket_message_lists"] is List) {
        messagesList.insert(
          0,
          TicketMessage.fromJson(
            (responseData["ticket_message_lists"] as List).firstOrNull,
          ),
        );
      }
    } else {}
    setIsLoading(false);
  }

  Future fetchOnlyMessages() async {
    nextPageLoading = true;
    notifyListeners();
    final url = "$nextPage";
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.message,
      headers: commonAuthHeader,
    );

    if (responseData != null) {
      final tempData = TicketMessagesModel.fromJson(responseData);
      for (var element in tempData.messages) {
        messagesList.add(element);
      }
      nextPage = tempData.pagination?.nextPageUrl;
    } else if (responseData != null &&
        responseData["all_message"]["data"].isEmpty) {
      LocalKeys.noMessageFound.showToast();
      noMoreMessages = true;
    } else {
      noMoreMessages = true;
    }
    Future.delayed(const Duration(milliseconds: 600), () {
      noMoreMessages = false;
      notifyListeners();
    });
    nextPageLoading = false;
    notifyListeners();
  }
}
