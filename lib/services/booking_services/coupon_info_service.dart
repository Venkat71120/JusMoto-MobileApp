import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';

import '../../data/network/network_api_services.dart';
import '../../view_models/service_booking_view_model/service_booking_view_model.dart';

class CouponInfoService {
  fetchCouponInfo() async {
    final sbm = ServiceBookingViewModel.instance;
    var url = "${AppUrls.couponInfoUrl}/${sbm.couponController.text}";

    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.applyCoupon, headers: acceptJsonAuthHeader);

    if (responseData != null) {
      sbm.couponDiscount.value = CouponInfoModel.fromJson(responseData);
      if (sbm.couponDiscount.value != null) {
        LocalKeys.couponAppliedSuccessfully.showToast();
      }
      return true;
    }
  }
}

class CouponInfoModel {
  final Coupon? coupon;

  CouponInfoModel({
    this.coupon,
  });

  factory CouponInfoModel.fromJson(Map json) => CouponInfoModel(
        coupon: json["coupon"] == null ? null : Coupon.fromJson(json["coupon"]),
      );

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
        discount: json["discount"].toString().tryToParse,
        discountType: json["discount_type"],
        expireDate: DateTime.tryParse(json["expire_date"].toString()),
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
