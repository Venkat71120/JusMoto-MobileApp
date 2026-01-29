import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/network/network_api_services.dart';
import '../../models/schedule_list_model.dart';

class BookingScheduleService with ChangeNotifier {
  ScheduleListModel? _scheduleListModel;
  ScheduleListModel get scheduleListModel =>
      _scheduleListModel ?? ScheduleListModel(schedules: []);

  bool isLoading = false;

  dynamic providerId;
  dynamic admin;

  bool shouldAutoFetch(proId, date) {
    final weekdayName = DateFormat('EEEE').format(date);
    return _scheduleListModel == null ||
        weekdayName != wd ||
        providerId.toString() != proId.toString();
  }

  String wd = "";

  bool ignoreScheduleFetch(date, proId, ad) {
    final weekdayName = DateFormat('EEEE').format(date);
    if (proId != null) {
      return (weekdayName == wd && scheduleListModel.schedules.isNotEmpty) &&
          (providerId?.toString() == proId.toString());
    }

    return (weekdayName == wd && scheduleListModel.schedules.isNotEmpty) &&
        (ad == admin);
  }

  fetchScheduleList(DateTime date, providerId, {admin}) async {
    final weekdayName = DateFormat('EEEE').format(date);
    if (providerId != null &&
        (weekdayName == wd && scheduleListModel.schedules.isNotEmpty) &&
        (providerId?.toString() == this.providerId.toString())) {
      return;
    }
    if (providerId == null &&
        (weekdayName == wd && scheduleListModel.schedules.isNotEmpty) &&
        (admin == this.admin)) {
      return;
    }

    this.providerId = providerId;
    this.admin = admin;
    wd = weekdayName;
    var url =
        "${AppUrls.providerScheduleListUrl}?day=$weekdayName&provider_id=${providerId ?? ""}&admin=${admin ?? ""}";
    isLoading = true;
    notifyListeners();
    final responseData =
        await NetworkApiServices().getApi(url, LocalKeys.schedule);

    try {
      if (responseData != null) {
        _scheduleListModel = ScheduleListModel.fromJson(responseData);
      } else {
        _scheduleListModel ??= ScheduleListModel(schedules: []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
    isLoading = false;
    notifyListeners();
  }

  void reset() {}
}
