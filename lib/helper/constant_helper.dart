import 'package:car_service/models/color_model.dart';
import 'package:car_service/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/services/app_string_service.dart';
import '../services/dynamics/dynamics_service.dart';

late DynamicsService dProvider;
late ColorModel _color;
late AppStringService asProvider;
SharedPreferences? sPref;
ColorModel get color => _color;
var _chatProviderId;

get chatProviderId => _chatProviderId?.toString();
setChatProviderId(id) {
  _chatProviderId = id;
}

var _orderId;

get orderId => _orderId;
setOrderId(id) {
  _orderId = id;
}

String get getToken {
  return sPref?.getString("token") ?? "";
}

setToken(token) {
  sPref?.setString("token", token ?? "");
}

/// Session duration: 6 months (180 days)
const int sessionDurationDays = 180;

/// Save the login timestamp when user logs in
setLoginTimestamp() {
  sPref?.setString("login_timestamp", DateTime.now().toIso8601String());
}

/// Clear the login timestamp on logout
clearLoginTimestamp() {
  sPref?.remove("login_timestamp");
}

/// Check if the login session has expired (older than 6 months)
bool isSessionExpired() {
  final timestamp = sPref?.getString("login_timestamp");
  if (timestamp == null) {
    // No timestamp means old session before this feature — treat as expired
    return getToken.isNotEmpty;
  }
  final loginDate = DateTime.tryParse(timestamp);
  if (loginDate == null) return true;
  final now = DateTime.now();
  return now.difference(loginDate).inDays >= sessionDurationDays;
}

get commonAuthHeader => {'Authorization': 'Bearer $getToken'};
get acceptJsonHeader => {'Accept': 'application/json'};
get acceptJsonAuthHeader =>
    {'Accept': 'application/json', 'Authorization': 'Bearer $getToken'};

coreInit(BuildContext context) async {
  dProvider = Provider.of<DynamicsService>(context, listen: false);
  _color = Provider.of<ThemeService>(context, listen: false).selectedTheme;
  asProvider = Provider.of<AppStringService>(context, listen: false);
  sPref ??= await SharedPreferences.getInstance();
}

final customCacheManager = CacheManager(
  Config(
    'customCacheKey',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 500,
  ),
);
