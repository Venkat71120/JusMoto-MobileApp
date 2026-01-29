import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/category_model.dart';
import 'package:flutter/material.dart';

import '../data/network/network_api_services.dart';

class FilterCategoryListService with ChangeNotifier {
  List<Category> categoryList = [
    Category(
        id: 1,
        name: "Cleaning",
        image: "https://i.postimg.cc/26DdXVL9/image.png"),
    Category(
        id: 2,
        name: "Plumbing",
        image: "https://i.postimg.cc/XJ5HrpTn/Plumbing.png"),
    Category(
        id: 3,
        name: "Painting",
        image: "https://i.postimg.cc/CKXrMjrv/Brush.png"),
    Category(
        id: 4,
        name: "Laundry",
        image: "https://i.postimg.cc/6Qy1NHc2/Laundry.png"),
    Category(
        id: 6,
        name: "Shifting",
        image: "https://i.postimg.cc/529Rs9Fm/Truck.png"),
    Category(
        id: 7,
        name: "Electrical",
        image: "https://i.postimg.cc/VLWh9056/Group.png"),
    Category(
        id: 8,
        name: "Home Repair",
        image: "https://i.postimg.cc/26DdXVL9/image.png"),
  ];

  fetchFetchCategory() async {
    var url = AppUrls.areaUrl;

    final responseData =
        await NetworkApiServices().getApi(url, LocalKeys.category);

    if (responseData != null) {
      return true;
    }
  }
}
