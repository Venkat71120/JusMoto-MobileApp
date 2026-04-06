import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../customization.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

/// Handles franchise / admin authentication.
///
/// Admin login response shape (different from regular user login!):
///   { success, message, data: { admin: { id, name, email, username, role,
///                                        is_franchise, image, permissions[] },
///                               token: "JWT" } }
class FranchiseLoginService with ChangeNotifier {
  var token = "";
  var username = "";
  var email = "";
  var phone = "";
  var name = "";
  String? image;
  var role = "";
  var userId = "";
  var franchiseCode = "";
  var franchiseLocation = "";
  var outletLocationId = "";
  List<dynamic> permissions = [];

  bool isFranchise = false;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ─── Restore session from SharedPreferences on app start ─────────────────

  Future<void> initFranchiseData() async {
    // Always re-read from SharedPreferences to ensure fresh state on app restart
    isFranchise = sPref?.getBool("is_franchise") ?? false;

    debugPrint("initFranchiseData: is_franchise=$isFranchise");

    if (isFranchise) {
      token = sPref?.getString("token") ?? "";
      username = sPref?.getString("franchise_username") ?? "";
      franchiseCode = sPref?.getString("franchise_code") ?? "";
      franchiseLocation = sPref?.getString("franchise_location") ?? "";
      userId = sPref?.getString("user_id") ?? "";

      debugPrint("initFranchiseData: token=${token.isNotEmpty ? 'EXISTS' : 'EMPTY'}");

      if (token.isNotEmpty) setToken(token);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Authenticates a franchise/admin user.
  /// Endpoint: POST /auth/admin/login   Body: { email, password }
  ///
  /// Note: backend accepts email OR username in the 'email' field (same as regular login).
  /// Response key is 'admin' (not 'user') — this is the critical difference.
  Future<bool?> tryFranchiseLogin({
    required String username,
    required String password,
  }) async {
    final data = {
      'email': username,     // backend accepts email or username in this field
      'password': password,
    };

    try {
      final responseData = await NetworkApiServices().postApi(
        data,
        AppUrls.franchiseLoginUrl, // /auth/admin/login
        LocalKeys.franchiseLogin,
      );

      // ✅ Admin login response uses 'admin' key, not 'user'
      // Shape: { success, message, data: { admin: {...}, token: "..." } }
      if (responseData != null && responseData['data'] != null) {
        final dataObj = responseData['data'];
        final admin = dataObj['admin'];   // ← 'admin', NOT 'user'

        if (admin == null) {
          LocalKeys.invalidFranchiseCredentials.showToast();
          return false;
        }

        // ✅ Block access if not a franchise user
        final rawFlag = admin['is_franchise'];
        final int franchiseFlag = rawFlag is bool
            ? (rawFlag ? 1 : 0)
            : int.tryParse(rawFlag?.toString() ?? '0') ?? 0;

        if (franchiseFlag != 1) {
          LocalKeys.notAFranchiseUser.showToast();
          return false;
        }

        // ── Parse admin fields ──
        token = dataObj['token'] ?? "";
        this.username = admin['username'] ?? "";
        this.email = admin['email'] ?? "";
        this.name = admin['name'] ?? "";
        this.image = admin['image']?.toString();
        this.role = admin['role'] ?? "";
        userId = admin['id']?.toString() ?? "";
        permissions = admin['permissions'] ?? [];

        // Franchise-specific fields (may or may not be in response)
        franchiseCode = admin['franchise_code'] ?? "";
        franchiseLocation = admin['franchise_location'] ?? "";
        outletLocationId = admin['outlet_location_id']?.toString() ?? "";
        isFranchise = true;
        _isInitialized = true;

        // ── Persist ──
        await sPref?.setString("token", token);
        setToken(token);
        await sPref?.setBool("is_franchise", true);
        await sPref?.setString("franchise_username", this.username);
        await sPref?.setString("franchise_code", franchiseCode);
        await sPref?.setString("franchise_location", franchiseLocation);
        await sPref?.setString("user_id", userId);

        LocalKeys.signedInSuccessfully.showToast();
        notifyListeners();
        return true;
      } else if (responseData != null && responseData.containsKey("message")) {
        responseData["message"]?.toString().showToast();
        return false;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Franchise login error: $e');
      return null;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool get isFranchiseUser => sPref?.getBool("is_franchise") ?? false;
  String get savedUsername => sPref?.getString("franchise_username") ?? "";

  Future<void> clearFranchiseData() async {
    await sPref?.remove("is_franchise");
    await sPref?.remove("franchise_username");
    await sPref?.remove("franchise_code");
    await sPref?.remove("franchise_location");
    await sPref?.remove("user_id");
    await sPref?.remove("token");

    isFranchise = false;
    token = "";
    username = "";
    franchiseCode = "";
    franchiseLocation = "";
    userId = "";
    name = "";
    email = "";
    image = null;
    role = "";
    permissions = [];
    _isInitialized = false;

    setToken("");
    notifyListeners();
  }
}