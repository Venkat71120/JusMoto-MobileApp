import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/support_models/ticket_list_model.dart';

class TicketListService with ChangeNotifier {
  TicketListModel? _ticketListModel;
  TicketListModel get ticketListModel =>
      _ticketListModel ?? TicketListModel(tickets: []);
  List<Department>? departments;
  var token = "";

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _ticketListModel == null || token.isInvalid;

  fetchTicketList() async {
    token = getToken;

    final url = AppUrls.ticketListListUrl;
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.supportTicket, headers: commonAuthHeader);

    if (responseData != null) {
      _ticketListModel = TicketListModel.fromJson(responseData);
      nextPage = _ticketListModel?.pagination?.nextPageUrl;
    } else {}
    notifyListeners();
  }

  fetchNextPage() async {
    token = getToken;
    if (nextPageLoading) return;
    nextPageLoading = true;
    final responseData = await NetworkApiServices()
        .getApi(nextPage, LocalKeys.supportTicket, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = TicketListModel.fromJson(responseData);
      for (var element in tempData.tickets) {
        _ticketListModel?.tickets.add(element);
      }
      nextPage = tempData.pagination?.nextPageUrl;
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

  fetchDepartments() async {
    if (departments != null) {
      debugPrint(departments?.map((e) => e.name).toList().toString());
      return;
    }
    final responseData = await NetworkApiServices().getApi(
        AppUrls.stDepartmentsUrl, LocalKeys.department,
        headers: commonAuthHeader);

    if (responseData != null) {
      departments = TicketDepartmentsModel.fromJson(responseData).departments;
    } else {
      departments = [];
      Future.delayed(const Duration(seconds: 1)).then((value) {
        departments = null;
      });
    }
    notifyListeners();
  }
}
