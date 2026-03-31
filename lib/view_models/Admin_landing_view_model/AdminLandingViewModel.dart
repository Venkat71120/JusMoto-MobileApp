import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/helper/extension/string_extension.dart';
import '/helper/local_keys.g.dart';

class AdminLandingViewModel {
  DateTime? currentBackPressTime;
  ValueNotifier currentIndex = ValueNotifier(0);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext? context;

  AdminLandingViewModel._init();
  static AdminLandingViewModel? _instance;
  static AdminLandingViewModel get instance {
    _instance ??= AdminLandingViewModel._init();
    return _instance!;
  }

  AdminLandingViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void setNavIndex(int value) async {
    if (value == currentIndex.value) return;
    currentIndex.value = value;
  }

  void setNavIndexP(int value) {
    if (value == currentIndex.value) return;
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
