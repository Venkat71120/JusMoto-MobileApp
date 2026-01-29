import 'dart:convert';

import 'package:car_service/helper/constant_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/helper/extension/string_extension.dart';
import '/helper/local_keys.g.dart';
import '../../models/car_models/car_model_list_model.dart';

class LandingViewModel {
  DateTime? currentBackPressTime;
  ValueNotifier currentIndex = ValueNotifier(0);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext? context;
  final ValueNotifier<CarModel?> selectedCar = ValueNotifier(null);

  LandingViewModel._init();
  static LandingViewModel? _instance;
  static LandingViewModel get instance {
    _instance ??= LandingViewModel._init();
    return _instance!;
  }

  initCar() {
    final localCar = sPref?.getString("car");
    if (localCar == null) return;
    debugPrint("local car is $localCar".toString());
    selectedCar.value = CarModel.fromJson(jsonDecode(localCar));
  }

  LandingViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void setNavIndex(int value) async {
    if (value == currentIndex.value) {
      return;
    }
    currentIndex.value = value;
  }

  void setNavIndexP(int value) {
    if (value == currentIndex.value) {
      return;
    }
    currentIndex.value = value;
  }

  setContext(BuildContext? context) {
    this.context = context;
  }

  bool willPopFunction(BuildContext context) {
    this.context = context;
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return false;
    }

    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      LocalKeys.pressAgainToExit.showToast();
      return false;
    }
    SystemNavigator.pop();
    return true;
  }
}
