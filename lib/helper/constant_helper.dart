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
    maxNrOfCacheObjects: 100,
  ),
);
