import 'package:flutter/foundation.dart';
import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';

import '../../data/network/network_api_services.dart';
import '../../view_models/service_booking_view_model/service_booking_view_model.dart';

class CouponInfoService {
  fetchCouponInfo() async {
    final sbm = ServiceBookingViewModel.instance;
    final couponCode = sbm.couponController.text.trim();
    if (couponCode.isEmpty) {
      LocalKeys.enterCode.showToast();
      return false;
    }
    var url = "${AppUrls.couponInfoUrl}/$couponCode";

    try {
      final responseData = await NetworkApiServices()
          .getApi(url, LocalKeys.applyCoupon, headers: acceptJsonAuthHeader);

      if (responseData != null) {
        final model = CouponInfoModel.fromJson(responseData);
        final coupon = model.coupon;

        if (coupon != null) {
          // Expiry Check
          if (coupon.expireDate != null) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final expiryDate = DateTime(
                coupon.expireDate!.year, coupon.expireDate!.month, coupon.expireDate!.day);

            if (expiryDate.isBefore(today)) {
              LocalKeys.couponIsExpired.showToast();
              sbm.couponDiscount.value = null;
              return false;
            }
          }

          sbm.couponDiscount.value = model;
          LocalKeys.couponAppliedSuccessfully.showToast();
          return true;
        } else {
          "Invalid Coupon".showToast();
          return false;
        }
      }
    } catch (e) {
      debugPrint("fetchCouponInfo error: $e");
      "Error applying coupon".showToast();
    }
    return false;
  }
}

class CouponInfoModel {
  final Coupon? coupon;

  CouponInfoModel({
    this.coupon,
  });

  factory CouponInfoModel.fromJson(Map json) {
    // 1. Try to find the data container
    final data = json["data"] is Map ? json["data"] : (json.containsKey("code") || json.containsKey("discount") ? json : null);
    
    // 2. Try to find the coupon object inside data or data itself
    final couponMap = (data is Map && data.containsKey("coupon") && data["coupon"] is Map) 
        ? data["coupon"] 
        : (data is Map && (data.containsKey("code") || data.containsKey("discount")) ? data : null);
    
    return CouponInfoModel(
      coupon: couponMap == null ? null : Coupon.fromJson(Map<String, dynamic>.from(couponMap)),
    );
  }

  Map<String, dynamic> toJson() => {
        "coupon": coupon?.toJson(),
      };
}

class Coupon {
  final dynamic id;
  final String? title;
  final String? code;
  final num discount;
  final String? discountType;
  final DateTime? expireDate;
  final dynamic status;

  Coupon({
    this.id,
    this.title,
    this.code,
    required this.discount,
    this.discountType,
    this.expireDate,
    this.status,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json["id"],
        title: json["title"],
        code: json["code"],
        discount: (json["discount"] ?? 0).toString().tryToParse,
        discountType: json["discount_type"],
        expireDate: json["expire_date"] == null || json["expire_date"].toString().isEmpty
            ? null
            : DateTime.tryParse(json["expire_date"].toString()),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "code": code,
        "discount": discount,
        "discount_type": discountType,
        "expire_date":
            "${expireDate!.year.toString().padLeft(4, '0')}-${expireDate!.month.toString().padLeft(2, '0')}-${expireDate!.day.toString().padLeft(2, '0')}",
        "status": status,
      };
}
