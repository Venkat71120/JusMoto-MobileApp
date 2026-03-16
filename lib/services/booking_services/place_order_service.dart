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

    // ✅ FIXED: Build items as a proper List, not a JSON string
    // Also move variant_id inside each item, not at top level
    final variantId = sPref?.getString("vId");
    final List itemsWithVariant = (services as List).map((item) {
      final Map<String, dynamic> mapped = {
        "id": item["id"] ?? item["service_id"],
        "qty": item["qty"] ?? item["quantity"] ?? 1,
      };
      if (variantId != null && variantId.isNotEmpty) {
        mapped["variant_id"] = int.tryParse(variantId);
      }
      if (item["car_id"] != null) mapped["car_id"] = item["car_id"];
      if (item["addons"] != null) mapped["addons"] = item["addons"];
      return mapped;
    }).toList();

    // ✅ FIXED: delivery_mode — API only accepts "home" or "pickup", not "walkin"
    final deliveryMode = sbm.serviceMethod.value == DeliveryOption.OUTLET
        ? 'pickup'
        : 'home';

    // ✅ FIXED: Build address object (renamed from "location"), not JSON string
    Map<String, dynamic>? addressData;
    if (sbm.serviceMethod.value != DeliveryOption.OUTLET) {
      final profile = Provider.of<ProfileInfoService>(context, listen: false);
      final selectedAddress = sbm.selectedAddress.value;
      addressData = {
        "address": sbm.addressController.text,
        "phone": selectedAddress?.phone ?? profile.profileInfoModel.userDetails?.phone ?? "",
        "emergency_phone": selectedAddress?.emergencyPhone,
        "latitude": sbm.selectedLatLng.value?.latitude,
        "longitude": sbm.selectedLatLng.value?.longitude,
        "type": 0,
      };
    }

    final bool isManualWithFile =
        gateway == "manual_payment" && file != null;

    if (isManualWithFile) {
      // ── Multipart path (only when attaching a payment screenshot) ──────────
      // Multipart fields must all be strings, so we JSON-encode nested objects
      final Map<String, String> fields = {
        'items': jsonEncode(itemsWithVariant),   // encoded once, intentionally
        'date': DateFormat("yyyy-MM-dd").format(sbm.selectedDate.value!),
        'time': sbm.selectedTime.value!.format(context),
        'order_note': sbm.descriptionController.text,
        'delivery_mode': deliveryMode,
        'selected_payment_gateway': gateway.toString(),
        'coupon_code': coupon.toString(),
      };

      if (sbm.serviceMethod.value == DeliveryOption.OUTLET) {
        fields['outlet_id'] =
            sbm.selectedOutlet.value?.id?.toString() ?? "";
      }
      if (sbm.selectedStaff.value != null) {
        fields['staff_id'] =
            sbm.selectedStaff.value?.id?.toString() ?? "";
      }
      if (addressData != null) {
        fields['address'] = jsonEncode(addressData); // encoded once
      }

      log('Multipart fields: ${jsonEncode(fields)}');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $getToken',
      });

      final responseData = await NetworkApiServices()
          .postWithFileApi(request, LocalKeys.payAndConfirmOrder);
      if (responseData != null) {
        _orderResponseModel = OrderResponseModel.fromJson(responseData);
        return true;
      }
    } else {
      // ── JSON POST path (all other gateways) ─────────────────────────────────
      // ✅ FIXED: items is a real List here — no jsonEncode wrapping
      final Map<String, dynamic> body = {
        'items': itemsWithVariant,
        'date': DateFormat("yyyy-MM-dd").format(sbm.selectedDate.value!),
        'time': sbm.selectedTime.value!.format(context),
        'order_note': sbm.descriptionController.text,
        'delivery_mode': deliveryMode,
        'selected_payment_gateway': gateway.toString(),
        'coupon_code': coupon.toString(),
      };

      if (sbm.serviceMethod.value == DeliveryOption.OUTLET) {
        body['outlet_id'] = sbm.selectedOutlet.value?.id;
      }
      if (sbm.selectedStaff.value != null) {
        body['staff_id'] = sbm.selectedStaff.value?.id;
      }
      if (addressData != null) {
        // ✅ FIXED: key is "address", value is a Map object (not a string)
        body['address'] = addressData;
      }

      log('JSON body: ${jsonEncode(body)}');

      final responseData = await NetworkApiServices().postApi(
        body,
        url,
        LocalKeys.payAndConfirmOrder,
        headers: commonAuthHeader,
      );

      if (responseData != null) {
        _orderResponseModel = OrderResponseModel.fromJson(responseData);
        return true;
      }
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