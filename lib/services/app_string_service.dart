import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../data/network/network_api_services.dart';
import '../helper/app_urls.dart';
import '../helper/constant_helper.dart';
import '../helper/local_keys.g.dart';

class AppStringService with ChangeNotifier {
  var translatedString = {};
  String getString(String s) {
    if (translatedString[s] != null && translatedString[s].isNotEmpty) {
      return translatedString[s];
    }
    return s;
  }

  translateStrings(BuildContext context, {bool forceChange = false}) async {
    bool shouldLoad = true;
    if (!sPref!.containsKey('lang_slug')) {
      sPref!.setString('langId', dProvider.languageSlug);
    } else if (sPref!.getString('langId') != sPref?.getString("lang_slug")) {
      sPref!.setString(
          'langId', sPref?.getString("lang_slug") ?? dProvider.languageSlug);
    } else if (sPref!.getString('langId') != dProvider.languageSlug) {
      sPref!.setString('langId', dProvider.languageSlug);
    } else {
      shouldLoad = false;
    }
    log(jsonEncode(LocalKeys.stringsMap));

    if (!shouldLoad && !forceChange) {
      final strings = sPref!.getString('translated_string');
      debugPrint("skipping translation".toString());
      translatedString = jsonDecode(strings ?? '{}');
      coreInit(context);
      return;
    }
    final data = {
      "slug": sPref?.getString("lang_slug"),
      "strings": jsonEncode(LocalKeys.stringsMap),
    };

    final responseData = await NetworkApiServices()
        .postApi(data, AppUrls.translationUrl, LocalKeys.translatingText);

    if (responseData != null) {
      debugPrint((responseData["strings"] is Map).toString());
      translatedString =
          responseData["strings"] is! Map ? {} : responseData["strings"];
      sPref?.setString("translated_string", jsonEncode(translatedString));
      coreInit(context);
      return true;
    } else {}
  }

  defaultTranslate(BuildContext context, {bool forceChange = false}) async {
    bool shouldLoad = true;
    debugPrint(
        (!sPref!.containsKey('langId') && (!sPref!.containsKey('lang_slug')))
            .toString());
    if (!sPref!.containsKey('langId') && (!sPref!.containsKey('lang_slug'))) {
      sPref!.setString('langId', dProvider.languageSlug);
    } else {
      shouldLoad = false;
    }

    if (!shouldLoad && !forceChange) {
      final strings = sPref!.getString('translated_string');
      debugPrint("skipping translation".toString());
      translatedString = jsonDecode(strings ?? '{}');
      coreInit(context);
      return;
    }
    final data = {
      "strings": jsonEncode(LocalKeys.stringsMap),
    };
    final responseData = await NetworkApiServices().postApi(
        data, AppUrls.defaultTranslationUrl, LocalKeys.translatingText);

    if (responseData != null) {
      debugPrint((responseData["strings"] is Map).toString());
      translatedString =
          responseData["strings"] is! Map ? {} : responseData["strings"];
      sPref?.setString("translated_string", jsonEncode(translatedString));
      coreInit(context);
      return true;
    } else {}
  }
}
