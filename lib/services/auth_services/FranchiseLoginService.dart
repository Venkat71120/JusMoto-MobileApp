import 'package:flutter/material.dart';

import '../../customization.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';

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
  
  // Franchise-specific data
  bool isFranchise = false;
  
  Future<bool?> tryFranchiseLogin({
    required String username,
    required String password,
  }) async {
    debugPrint('📡 Attempting franchise login');
    debugPrint('   Username: $username');
    
    final data = {
      'username': username,
      'password': password,
    };

    try {   
      final responseData = await NetworkApiServices().postApi(
        data,
        AppUrls.franchiseLoginUrl,
        LocalKeys.franchiseLogin,
      );

      debugPrint('📥 Franchise login response: $responseData');

     if (responseData != null && responseData.containsKey("token")) {

  // ✅ Block sign-in if is_franchise is not 1
  final isFranchiseValue = responseData["user"]["is_franchise"];
  final int franchiseFlag = isFranchiseValue is bool
      ? (isFranchiseValue == true ? 1 : 0)
      : (isFranchiseValue ?? 0);

  if (franchiseFlag != 1) {
    debugPrint('🚫 Login blocked — not a franchise user (is_franchise = $franchiseFlag)');
    LocalKeys.notAFranchiseUser.showToast();
    return false;
  }

  debugPrint('✅ Franchise login successful');

  token = responseData["token"] ?? "";
        this.username = responseData["user"]["username"] ?? "";
        this.email = responseData["user"]["email"] ?? "";
        this.phone = responseData["user"]["phone"] ?? "";
        this.name = responseData["user"]["name"] ?? "";
        this.image = responseData["user"]["image"];
        this.role = responseData["user"]["role"] ?? "";
        userId = responseData["user"]["id"]?.toString() ?? "";
        franchiseCode = responseData["user"]["franchise_code"] ?? "";
        franchiseLocation = responseData["user"]["franchise_location"] ?? "";
        outletLocationId = responseData["user"]["outlet_location_id"]?.toString() ?? "";
       isFranchise = true;
        
        // Save token
        setToken(token);
        
        // Save franchise data
        sPref?.setBool("is_franchise", isFranchise);
        sPref?.setString("franchise_username", username);
        sPref?.setString("franchise_code", franchiseCode);
        sPref?.setString("franchise_location", franchiseLocation);
        
        LocalKeys.signedInSuccessfully.showToast();
        notifyListeners();
        
        return true;
      } else if (responseData != null && responseData.containsKey("message")) {
        debugPrint('❌ Franchise login failed: ${responseData["message"]}');
        responseData["message"]?.toString().showToast();
        return false;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Franchise login error: $e');
      return null;
    }
  }
  
  // Check if current user is a franchise
  bool get isFranchiseUser => sPref?.getBool("is_franchise") ?? false;
  
  String get savedUsername => sPref?.getString("franchise_username") ?? "";
  
  // Clear franchise data on logout
  void clearFranchiseData() {
    sPref?.remove("is_franchise");
    sPref?.remove("franchise_username");
    sPref?.remove("franchise_code");
    sPref?.remove("franchise_location");
    isFranchise = false;
    username = "";
    franchiseCode = "";
    franchiseLocation = "";
    notifyListeners();
  }
}