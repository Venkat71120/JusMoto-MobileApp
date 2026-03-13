import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';

class UserSelectedCarModel {
  final dynamic id;
  final dynamic userId;
  final dynamic brandId;
  final dynamic carId;
  final dynamic variantId;
  final String? registrationNumber;
  final dynamic isDefault;
  final dynamic status;
  final String? brandName;   // ✅ from nested "brand"
  final String? carName;     // ✅ from nested "car"
  final String? carImage;    // ✅ from nested "car"

  UserSelectedCarModel({
    this.id,
    this.userId,
    this.brandId,
    this.carId,
    this.variantId,
    this.registrationNumber,
    this.isDefault,
    this.status,
    this.brandName,
    this.carName,
    this.carImage,
  });

  factory UserSelectedCarModel.fromJson(Map<String, dynamic> json) =>
      UserSelectedCarModel(
        id: json["id"],
        userId: json["user_id"],
        brandId: json["brand_id"],
        carId: json["car_id"],
        variantId: json["variant_id"],
        registrationNumber: json["registration_number"]?.toString(),
        isDefault: json["is_default"],
        status: json["status"],
        brandName: json["brand"]?["name"],       // ✅ nested
        carName: json["car"]?["name"],           // ✅ nested
        carImage: json["car"]?["image"],         // ✅ nested
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "brand_id": brandId,
        "car_id": carId,
        "variant_id": variantId,
        "registration_number": registrationNumber,
        "is_default": isDefault,
        "status": status,
      };
}

class UserSelectedCarListModel {
  final List<UserSelectedCarModel>? cars;

  UserSelectedCarListModel({this.cars});

  factory UserSelectedCarListModel.fromJson(dynamic json) {
    if (json == null) return UserSelectedCarListModel(cars: []);
    if (json is List) {
      return UserSelectedCarListModel(
          cars: List<UserSelectedCarModel>.from(
              json.map((x) => UserSelectedCarModel.fromJson(x))));
    } else if (json is Map && json["data"] != null) {
       return UserSelectedCarListModel(
          cars: List<UserSelectedCarModel>.from(
              json["data"].map((x) => UserSelectedCarModel.fromJson(x))));
    }
    return UserSelectedCarListModel(cars: []);
  }
}

class UserCarsService with ChangeNotifier {
  UserSelectedCarListModel? _userCarsModel;
  UserSelectedCarListModel get userCarsModel =>
      _userCarsModel ?? UserSelectedCarListModel(cars: []);
  var token = "";

  bool isLoading = false;

  fetchUserCars() async {
    token = getToken;
    if (token.isInvalid) return;
    
    isLoading = true;
    notifyListeners();

    final url = AppUrls.userCarsUrl;
    final responseData = await NetworkApiServices()
        .getApi(url, "User Cars", headers: commonAuthHeader);

    if (responseData != null) {
      _userCarsModel = UserSelectedCarListModel.fromJson(responseData);
    } else {
      _userCarsModel = UserSelectedCarListModel(cars: []);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addUserCar({
    dynamic brandId,
    dynamic carId,
    dynamic variantId,
    String? registrationNumber,
    bool isDefault = true,
  }) async {
    token = getToken;
    if (token.isInvalid) return false;

    final url = AppUrls.userCarsUrl;
    
    Map<String, dynamic> data = {
      "brand_id": brandId.toString(),
      "car_id": carId.toString(),
      "variant_id": variantId.toString(),
      "is_default": isDefault ? "1" : "0",
    };
    
    if (registrationNumber != null && registrationNumber.isNotEmpty) {
      data["registration_number"] = registrationNumber.toString();
    }

    final responseData = await NetworkApiServices()
        .postApi(data, url, "Add User Car", headers: commonAuthHeader);

    if (responseData != null && responseData['success'] == true) {
      fetchUserCars();
      return true;
    }
    return false;
  }

  Future<bool> updateUserCar({
    required dynamic id,
    dynamic brandId,
    dynamic carId,
    dynamic variantId,
    String? registrationNumber,
    bool isDefault = true,
  }) async {
    token = getToken;
    if (token.isInvalid) return false;

    final url = "${AppUrls.userCarsUrl}/$id";
    
    Map<String, dynamic> data = {
      "brand_id": brandId.toString(),
      "car_id": carId.toString(),
      "variant_id": variantId.toString(),
      "is_default": isDefault ? "1" : "0",
    };
    
    if (registrationNumber != null && registrationNumber.isNotEmpty) {
      data["registration_number"] = registrationNumber.toString();
    }

    final responseData = await NetworkApiServices()
        .putApi(data, url, "Update User Car", headers: commonAuthHeader);

    if (responseData != null && responseData['success'] == true) {
      fetchUserCars();
      return true;
    }
    return false;
  }

  Future<bool> deleteUserCar({required dynamic id}) async {
    token = getToken;
    if (token.isInvalid) return false;

    final url = "${AppUrls.userCarsUrl}/$id";
    
    final responseData = await NetworkApiServices()
        .deleteApi(url, "Delete User Car", headers: commonAuthHeader);

    if (responseData != null && responseData['success'] == true) {
      fetchUserCars();
      return true;
    }
    return false;
  }

  Future<bool> setDefaultCar({required dynamic id}) async {
    token = getToken;
    if (token.isInvalid) return false;

    final url = "${AppUrls.userCarsUrl}/$id/default";
    
    final responseData = await NetworkApiServices()
        .putApi({}, url, "Set Default Car", headers: commonAuthHeader);

    if (responseData != null) {
      fetchUserCars();
      return true;
    }
    return false;
  }
}
