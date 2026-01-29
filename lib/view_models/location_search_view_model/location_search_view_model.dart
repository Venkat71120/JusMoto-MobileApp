import 'dart:async';

import 'package:flutter/material.dart';

class LocationViewModel {
  ScrollController scrollController = ScrollController();

  Timer? timer;
  ValueNotifier<bool> locationSearchLoading = ValueNotifier(false);

  LocationViewModel._init();
  static LocationViewModel? _instance;
  static LocationViewModel get instance {
    _instance ??= LocationViewModel._init();
    return _instance!;
  }

  LocationViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }
}
