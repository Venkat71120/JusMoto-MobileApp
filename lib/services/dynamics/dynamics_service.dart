import 'package:car_service/helper/constant_helper.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';

class DynamicsService with ChangeNotifier {
  LanguageListModel? _languageListModel;
  LanguageListModel get languageListModel =>
      _languageListModel ?? LanguageListModel();

  bool get shouldAutoFetch => _languageListModel == null;
  bool onceRebuilt = false;

  bool _noConnection = false;

  String languageSlug = 'en_GB';

  bool currencyRight = false;
  bool textDirectionRight = false;
  String currencySymbol = "\₹";
  String currencyCode = "USD";
  get noConnection => _noConnection;
  Locale _appLocal = const Locale("en", "GB");

  get appLocal => _appLocal;

  setNoConnection(value) {
    if (value == noConnection) {
      return;
    }
    _noConnection = value;
    notifyListeners();
  }

  String? get localLang {
    final localSlug = sPref?.getString("lang_slug");
    try {
      if (localSlug != null) {
        return languageListModel.language
            ?.firstWhere((l) => l.slug == localSlug)
            .name;
      } else {
        final defaultLang = languageListModel.language
            ?.firstWhere((l) => l.languageDefault.toString() == "1");
        sPref?.setString("lang_slug", defaultLang?.slug ?? "");
        return defaultLang?.name;
      }
    } catch (e) {
      return null;
    }
  }

  String? get localSlug {
    final lSlug = sPref?.getString("lang_slug");
    try {
      if (lSlug != null) {
        return lSlug;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  setLocalSlug() {}

  getColors() async {
    if (onceRebuilt) return;
    onceRebuilt = true;
    final responseData = await NetworkApiServices().getApi(
        AppUrls.currencyLanguageUrl, null,
        headers: acceptJsonAuthHeader);
    if (responseData != null) {
      currencyRight = responseData["currency"]["position"] == "right";
      currencySymbol = responseData["currency"]["symbol"] ?? "\$";
      currencyCode = responseData["currency"]["code"] ?? "USD";

      final lSlug = sPref?.getString("lang_slug");
      final tDirection = sPref?.getBool("rtl");

      if (lSlug == null) {
        await getLangList();
      } else {
        languageSlug = lSlug;
        textDirectionRight = tDirection ?? false;
      }
    }
    notifyListeners();
  }

  getLangList() async {
    final responseData = await NetworkApiServices()
        .getApi(AppUrls.languageListUrl, null, headers: acceptJsonAuthHeader);
    if (responseData != null) {
      final tempData = LanguageListModel.fromJson(responseData);
      _languageListModel = tempData;
      final lSlug = sPref?.getString("lang_slug");
      if (lSlug != null) {
        return;
      }

      try {
        for (var lang in _languageListModel?.language ?? []) {
          if (lang.languageDefault == "1") {
            debugPrint(responseData.toString());
            debugPrint(lang.direction.toString());
            debugPrint(lang.slug.toString());
            languageSlug = lang.slug ?? "";
            textDirectionRight = lang.direction != "ltr";
            languageSlug = lang.slug ?? "";
            break;
          }
        }
        setLangSlug(languageSlug, textDirectionRight, setLocally: true);
      } catch (e) {}
    }
    _languageListModel ??= LanguageListModel();
    notifyListeners();
  }

  setLangSlug(String slug, bool direction, {bool setLocally = false}) {
    if (languageSlug.length > 2) {
      final slugItems = slug.split("_");
      _appLocal =
          Locale(slugItems.firstOrNull ?? "", slugItems.lastOrNull ?? "");
    } else {
      _appLocal = Locale(slug);
    }
    textDirectionRight = direction;
    if (setLocally) {
      sPref?.setString("lang_slug", slug);
      sPref?.setString("langId", slug);
      sPref?.setBool("rtl", direction);
    }
    notifyListeners();
  }
}

class LanguageListModel {
  final List<Language>? language;

  LanguageListModel({
    this.language,
  });

  factory LanguageListModel.fromJson(Map json) => LanguageListModel(
        language: json["language"] == null
            ? []
            : List<Language>.from(
                json["language"]!.map((x) => Language.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "language": language == null
            ? []
            : List<dynamic>.from(language!.map((x) => x.toJson())),
      };
}

class Language {
  final dynamic id;
  final String? name;
  final String? slug;
  final String? direction;
  final dynamic status;
  final String? languageDefault;

  Language({
    this.id,
    this.name,
    this.slug,
    this.direction,
    this.status,
    this.languageDefault,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        direction: json["direction"].toString(),
        status: json["status"].toString(),
        languageDefault: json["default"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "default": languageDefault,
      };
}
