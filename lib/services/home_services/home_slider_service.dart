import 'dart:convert';

import 'package:car_service/helper/app_urls.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/slider_model.dart';

class HomeSliderService with ChangeNotifier {
  List<HomeSliderModel>? sliderList;

  initLocal() {
    final localData = sPref?.getString("sliders");
    if (localData == null) return;
    try {
      final tempData = SliderListModel.fromJson(jsonDecode(localData));
      if ((tempData.sliders ?? []).isNotEmpty) {
        sliderList = tempData.sliders;
        notifyListeners();
        fetchHomeSlider();
      }
    } catch (_) {
      fetchHomeSlider();
    }
  }

 fetchHomeSlider() async {
  final url = AppUrls.homeSliderListUrl;
  final responseData = await NetworkApiServices().getApi(url, LocalKeys.sliders);
  try {
    if (responseData != null) {
      final tempData = SliderListModel.fromJson(responseData);
      sliderList = tempData.sliders ?? [];
      sPref?.setString("sliders", jsonEncode(responseData));
    }
  } catch (e) {
    debugPrint("Slider parse error: $e");
  } finally {
    sliderList ??= [];
    notifyListeners();
  }
}

// Add this new method
Future<void> precacheSliderImages(BuildContext context) async {
  for (final slider in sliderList ?? []) {
    final url = slider.image?.trim() ?? "";
    if (url.isNotEmpty) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (_) {}
    }
  }
}
}