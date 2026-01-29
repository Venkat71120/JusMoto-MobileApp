import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:car_service/customization.dart';
import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app_static_values.dart';
import '../../data/network/network_api_services.dart';
import '../../models/order_models/order_response_model.dart';
import '../profile_services/profile_info_service.dart';

class PlaceOrderService with ChangeNotifier {
  OrderResponseModel? _orderResponseModel;

  OrderResponseModel get orderResponseModel =>
      _orderResponseModel ?? OrderResponseModel();

  tryPlacingOrder(
      BuildContext context, services, gateway, File? file, coupon) async {
    var url = AppUrls.placeOrderUrl;
    final sbm = ServiceBookingViewModel.instance;

    var data = {
      'items': jsonEncode(services),
      'car_variant': sPref?.getString("vId") ?? "",
      'date': DateFormat("yyyy-MM-dd").format(sbm.selectedDate.value!),
      'time': sbm.selectedTime.value!.format(context),
      'order_note': sbm.descriptionController.text,
      'delivery_mode': sbm.serviceMethod.value == DeliveryOption.OUTLET
          ? 'walkin'
          : 'pickup',
      'outlet_id': sbm.serviceMethod.value == DeliveryOption.OUTLET
          ? sbm.selectedOutlet.value?.id?.toString() ?? ""
          : "",
      'selected_payment_gateway': gateway.toString(),
      'coupon_code': coupon.toString(),
    };
    if (sbm.serviceMethod.value != DeliveryOption.OUTLET) {
      final locData = {
        "state_id": sbm.selectedAddress.value?.stateId,
        "city_id": sbm.selectedAddress.value?.cityId,
        "area_id": sbm.selectedAddress.value?.areaId,
        "phone": sbm.selectedAddress.value?.phone,
        "emergency_phone": sbm.selectedAddress.value?.emergencyPhone,
        "post_code": sbm.selectedAddress.value?.stateId,
        "address": sbm.addressController.text,
        "latitude": sbm.selectedLatLng.value?.latitude,
        "longitude": sbm.selectedLatLng.value?.longitude,
      };
      data["location"] = jsonEncode(locData);
    }
    if (sbm.selectedStaff.value != null) {
      data["staff_id"] = sbm.selectedStaff.value?.id?.toString() ?? "2";
    }
    log(jsonEncode(data));
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll(data);

    if (gateway == "manual_payment" && file != null) {
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
    }
    log(jsonEncode(data));
    request.headers.addAll(acceptJsonAuthHeader);
    final responseData = await NetworkApiServices()
        .postWithFileApi(request, LocalKeys.payAndConfirmOrder);
    if (responseData != null) {
      _orderResponseModel = OrderResponseModel.fromJson(responseData);
      return true;
    }
  }

  updatePayment(BuildContext context, {dynamic id}) async {
    var url = AppUrls.orderPaymentUpdateUrl;
    if ((orderResponseModel.orderDetails?.id ?? id) == null) {
      LocalKeys.orderNotFound.showToast();
      return;
    }
    final pi = Provider.of<ProfileInfoService>(context, listen: false);
    var data = {
      'order_id': (id ?? orderResponseModel.orderDetails!.id).toString()
    };
    debugPrint(data.toString());
    debugPrint(pi.profileInfoModel.userDetails?.email.toString());
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $getToken',
      "X-HMAC": (pi.profileInfoModel.userDetails?.email ?? "")
          .toHmac(secret: paymentUpdateKey),
    };
    debugPrint(headers.toString());
    final responseData = await NetworkApiServices()
        .postApi(data, url, LocalKeys.payAndConfirmOrder, headers: headers);

    if (responseData != null) {
      _orderResponseModel?.orderDetails?.paymentStatus = "1";
      notifyListeners();
      return true;
    }
  }
}

/* services dummy

{
    "all_services": [
        {
            "service_id": "17",
            "staff_id": "1",
            "location_id": 1,
            "date": "2024-08-30",
            "schedule": "10:00AM - 1:00PM",
            "order_note": "Test Order notes data"
        },
        {
            "service_id": "20",
            "staff_id": "4",
            "location_id": 3,
            "date": "2024-08-30",
            "schedule": "10:00AM - 1:00PM",
            "order_note": "Test Order notes data"
        }
    ]
}

*/
