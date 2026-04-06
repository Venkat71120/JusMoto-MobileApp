import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

/// Handles Admin authentication.
///
/// Admin login response shape:
///   { success, message, data: { admin: { id, name, email, username, role,
///                                        is_franchise, image, permissions[] },
///                               token: "JWT" } }
class AdminLoginService with ChangeNotifier {
  var token = "";
  var username = "";
  var email = "";
  var phone = "";
  var name = "";
  String? image;
  var role = "";
  var userId = "";
  List<dynamic> permissions = [];

  bool isAdmin = false;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ─── Restore session from SharedPreferences on app start ─────────────────

  Future<void> initAdminData() async {
    // Always re-read from SharedPreferences to ensure fresh state on app restart
    isAdmin = sPref?.getBool("is_admin") ?? false;

    debugPrint("initAdminData: is_admin=$isAdmin");

    if (isAdmin) {
      token = sPref?.getString("admin_token") ?? "";
      username = sPref?.getString("admin_username") ?? "";
      userId = sPref?.getString("admin_user_id") ?? "";

      debugPrint("initAdminData: token=${token.isNotEmpty ? 'EXISTS' : 'EMPTY'}");

      if (token.isNotEmpty) setToken(token);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Authenticates an admin user.
  /// Endpoint: POST /auth/admin/login   Body: { email, password }
  Future<bool?> tryAdminLogin({
    required String username,
    required String password,
  }) async {
    final data = {
      'email': username,
      'password': password,
    };

    try {
      final responseData = await NetworkApiServices().postApi(
        data,
        AppUrls.adminLoginUrl, // /auth/admin/login
        LocalKeys.signIn, // generic sign in key
      );

      // Shape: { success, message, data: { admin: {...}, token: "..." } }
      if (responseData != null && responseData['data'] != null) {
        final dataObj = responseData['data'];
        final admin = dataObj['admin'];

        if (admin == null) {
          "Invalid Admin Credentials".showToast();
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

        isAdmin = true;
        _isInitialized = true;

        // ── Persist ──
        await sPref?.setString("admin_token", token);
        setToken(token); // Update global token in network service
        await sPref?.setBool("is_admin", true);
        await sPref?.setString("admin_username", this.username);
        await sPref?.setString("admin_user_id", userId);

        "Admin signed in successfully".showToast();
        notifyListeners();
        return true;
      } else if (responseData != null) {
        if (responseData is Map && responseData.containsKey("message")) {
          responseData["message"]?.toString().showToast();
        } else if (responseData.toString().contains("<!doctype html>") || 
                 responseData.toString().contains("<html>")) {
          "Server configuration error (received HTML instead of JSON). Please try again or contact support.".showToast();
        } else {
          "Unknown server error".showToast();
        }
        return false;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Admin login error: $e');
      return null;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool get isAdminUser => sPref?.getBool("is_admin") ?? false;
  String get savedUsername => sPref?.getString("admin_username") ?? "";

  Future<void> clearAdminData() async {
    await sPref?.remove("is_admin");
    await sPref?.remove("admin_username");
    await sPref?.remove("admin_user_id");
    await sPref?.remove("admin_token");

    isAdmin = false;
    token = "";
    username = "";
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
