import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/profile_models/profile_info_model.dart';

class ProfileInfoService with ChangeNotifier {
  ProfileInfoModel? _profileInfoModel;
  ProfileInfoModel get profileInfoModel =>
      _profileInfoModel ?? ProfileInfoModel();

  fetchProfileInfo({trySkip = false}) async {
    var url = AppUrls.profileInfoUrl;
    final localProfile = sPref!.getString("prorile");
    if (localProfile != null && trySkip) {
      _profileInfoModel = ProfileInfoModel.fromJson(
          jsonDecode(sPref!.getString("prorile") ?? "{}"));
      notifyListeners();
      return true;
    }
    final responseData = await NetworkApiServices().getApi(
        url, trySkip ? null : LocalKeys.profile,
        headers: acceptJsonAuthHeader);

    if (responseData != null) {
      _profileInfoModel = ProfileInfoModel.fromJson(responseData);
      sPref?.setString(
          "profile", jsonEncode(_profileInfoModel?.toJson() ?? {}));
      notifyListeners();
      return true;
    }
  }

  void reset() {
    _profileInfoModel = null;
    sPref?.remove("profile");
    setToken(null);
    notifyListeners();
    debugPrint("reset Everything".toString());
  }
}
