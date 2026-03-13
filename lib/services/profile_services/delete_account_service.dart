import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/view_models/delete_account_view_model/delete_account_view_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/local_keys.g.dart';
import '../../models/address_models/states_model.dart';

class DeleteAccountService with ChangeNotifier {
  ReasonsListModel _reasonsListModel = ReasonsListModel(reasons: [
    Reason(id: 1, title: "Privacy concerns"),
    Reason(id: 2, title: "No longer need the service"),
    Reason(id: 3, title: "Found a better alternative"),
    Reason(id: 4, title: "Too many notifications"),
    Reason(id: 5, title: "Other"),
  ]);
  ReasonsListModel get reasonsListModel => _reasonsListModel;

  bool _hasFetched = false;
  bool get shouldAutoFetch => !_hasFetched;

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  tryDeletingAccount() async {
    final dam = DeleteAccountViewModel.instance;

    if (AppUrls.deleteAccountUrl.toLowerCase().contains(
      "car-service.bytesed",
    )) {
      await Future.delayed(const Duration(seconds: 2));
      "This feature is turned off for demo app".showToast();
      return;
    }
    final data = {
      'reason_id': dam.selectedReason.value?.id?.toString(),
      'description': dam.descriptionController.text,
      'current_password': dam.currentPassController.text,
      'password': dam.currentPassController.text,
    };
    debugPrint(acceptJsonAuthHeader.toString());
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.deleteAccountUrl,
      LocalKeys.changePassword,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      LocalKeys.accountDeletedSuccessfully.showToast();
      return true;
    }
  }

  fetchDepartments() async {
    if (_hasFetched) return;
    _hasFetched = true;

    final responseData = await NetworkApiServices().getApi(
      AppUrls.reasonListUrl,
      LocalKeys.reason,
      headers: commonAuthHeader,
    );

    if (responseData != null &&
        responseData["reasons"] != null &&
        responseData["reasons"] is List &&
        responseData["reasons"].isNotEmpty) {
      _reasonsListModel = ReasonsListModel.fromJson(responseData);
      notifyListeners();
    }
  }
}

class ReasonsListModel {
  final List<Reason> reasons;
  final Pagination? pagination;

  ReasonsListModel({required this.reasons, this.pagination});

  factory ReasonsListModel.fromJson(Map json) => ReasonsListModel(
    reasons:
        json["reasons"] == null
            ? []
            : List<Reason>.from(
              json["reasons"]!.map((x) => Reason.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "reasons":
        reasons == null
            ? []
            : List<dynamic>.from(reasons.map((x) => x.toJson())),
  };
}

class Reason {
  final dynamic id;
  final String? type;
  final String? title;

  Reason({this.id, this.type, this.title});

  factory Reason.fromJson(Map<String, dynamic> json) =>
      Reason(id: json["id"], type: json["type"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "type": type, "title": title};
}
