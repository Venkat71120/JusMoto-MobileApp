import 'package:flutter/material.dart';

class IntroViewModel {
  final PageController textController = PageController();
  final PageController imageController = PageController();
  IntroViewModel._init();
  static IntroViewModel? _instance;
  static IntroViewModel get instance {
    _instance ??= IntroViewModel._init();
    return _instance!;
  }

  IntroViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }
}
