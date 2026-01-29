import 'package:flutter/material.dart';

class ChangeLanguageViewModel {
  ValueNotifier<String?> selectedLang = ValueNotifier(null);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  ChangeLanguageViewModel._init();
  static ChangeLanguageViewModel? _instance;
  static ChangeLanguageViewModel get instance {
    _instance ??= ChangeLanguageViewModel._init();
    return _instance!;
  }

  ChangeLanguageViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }
}
