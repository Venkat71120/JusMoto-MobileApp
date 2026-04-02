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
    // ── Try returning cached profile first ────────────────────────────────
    if (trySkip) {
      final localProfile = sPref?.getString("profile");
      if (localProfile != null) {
        try {
          _profileInfoModel = ProfileInfoModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(localProfile)),
          );
          notifyListeners();
          return true;
        } catch (e) {
          debugPrint('⚠️ Failed to parse cached profile: $e');
          // Fall through to fetch from network
        }
      }
    }

    // ── Fetch from network ────────────────────────────────────────────────
    final responseData = await NetworkApiServices().getApi(
      AppUrls.profileInfoUrl,
      trySkip ? null : LocalKeys.profile,
      headers: acceptJsonAuthHeader,
    );

    debugPrint('📥 Profile response: $responseData');

    if (responseData == null) return null;

    // ✅ FIX: New backend wraps the user object in a 'data' key:
    //    { "success": true, "data": { "id": 18, "first_name": ... } }
    // Old backend returned the user fields at the top level.
    // We unwrap 'data' if present, otherwise fall back to the raw response.
    final Map<String, dynamic> userJson;
    if (responseData['data'] is Map) {
      userJson = Map<String, dynamic>.from(responseData['data']);
    } else {
      // Fallback: old shape or already-flat object
      userJson = Map<String, dynamic>.from(responseData);
    }

    try {
      _profileInfoModel = ProfileInfoModel.fromJson(userJson);
      // Cache for offline use (key fixed: was "prorile", now "profile")
      sPref?.setString("profile", jsonEncode(_profileInfoModel?.toJson()));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to parse profile response: $e');
      return null;
    }
  }

  void reset() {
    _profileInfoModel = null;
    sPref?.remove("profile");
    setToken(null);
    clearLoginTimestamp();
    notifyListeners();
    debugPrint('🔄 Profile reset');
  }
}