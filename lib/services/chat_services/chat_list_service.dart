import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/messages/chat_list_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

class ChatListService with ChangeNotifier {
  ChatListModel? _chatListModel;

  ChatListModel get chatListModel =>
      _chatListModel ?? ChatListModel(chatList: []);

  var token = "";

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _chatListModel == null || token.isInvalid;

  fetchChatList() async {
    token = getToken;
    var url = AppUrls.chatListUrl;

    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.chatList, headers: acceptJsonAuthHeader);

    try {
      if (responseData != null) {
        var tempData = ChatListModel.fromJson(responseData);
        _chatListModel = tempData;
        nextPage = tempData.pagination?.nextPageUrl;
      }
    } finally {
      _chatListModel ??= ChatListModel(chatList: []);
      notifyListeners();
    }
  }

  void setChatRead(id) {
    _chatListModel?.chatList
        .firstWhere((element) => element.id.toString() == id.toString())
        .clientUnseenMsgCount = 0;
    notifyListeners();
  }

  void fetchNextPage() async {
    token = getToken;
    if (nextPageLoading) return;
    nextPageLoading = true;
    final responseData = await NetworkApiServices()
        .getApi(nextPage, LocalKeys.messages, headers: commonAuthHeader);

    if (responseData != null) {
    } else {
      nexLoadingFailed = true;
      Future.delayed(const Duration(seconds: 1)).then((value) {
        nexLoadingFailed = false;
        notifyListeners();
      });
    }
    nextPageLoading = false;
    notifyListeners();
  }
}
