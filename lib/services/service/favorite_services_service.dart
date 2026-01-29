import 'dart:convert';

import 'package:car_service/models/home_models/services_list_model.dart';
import 'package:flutter/material.dart';

import '../../helper/db_helper.dart';

class FavoriteServicesService with ChangeNotifier {
  final Map _favoriteService = {};

  Map get favoriteList {
    return Map.from(_favoriteService);
  }

  List<ServiceModel> get services => List<ServiceModel>.from(
      _favoriteService.values.toList().map((x) => ServiceModel.fromJson(x)));

  addToFavorite(String id, data) async {
    await DbHelper.insert('favorite', {
      'serviceId': id,
      'data': jsonEncode(data),
    });
    _favoriteService.putIfAbsent(id, () => data);
    notifyListeners();
  }

  deleteFromFavorite(String id) async {
    await DbHelper.deleteDbSI('favorite', id);
    _favoriteService.remove(id);
    notifyListeners();
  }

  toggleFavorite(String id, data) {
    if (_favoriteService.containsKey(id)) {
      deleteFromFavorite(id);
    } else {
      addToFavorite(id, data);
    }
  }

  bool isFavorite(String id) {
    return _favoriteService.containsKey(id);
  }

  fetchFavorites() async {
    final dbData = await DbHelper.fetchDb('favorite');

    if (dbData.isEmpty) {
      return;
    }
    for (var element in dbData) {
      final data = jsonDecode(element['data']);
      if (data != null) {
        _favoriteService.putIfAbsent(element['serviceId'], () => data);
      }
    }

    notifyListeners();
  }
}
