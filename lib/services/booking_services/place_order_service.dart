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
import '../service/cart_service.dart';

class PlaceOrderService with ChangeNotifier {
  OrderResponseModel? _orderResponseModel;

  OrderResponseModel get orderResponseModel =>
      _orderResponseModel ?? OrderResponseModel();

  tryPlacingOrder(
      BuildContext context, services, gateway, File? file, coupon) async {
    var url = AppUrls.placeOrderUrl;
    final sbm = ServiceBookingViewModel.instance;

    final List itemsForNewApi = (services as List).map((item) {
      return {
        "service_id": (item["service_id"] ?? item["id"]).toString().tryToParse,
        "car_id": item["car_id"]?.toString().tryToParse,
        "variant_id": item["variant_id"]?.toString().tryToParse,
        "quantity": (item["quantity"] ?? item["qty"] ?? 1).toString().tryToParse,
        "addons": item["addons"] ?? [],
      };
    }).toList();

    // ✅ FIXED: delivery_mode — API only accepts "home" or "pickup", not "walkin"
    final deliveryMode = sbm.serviceMethod.value == DeliveryOption.OUTLET
        ? 'pickup'
        : 'home';

    final profile = Provider.of<ProfileInfoService>(context, listen: false);
    final selectedAddress = sbm.selectedAddress.value;
    
    final Map<String, dynamic> addressData = {
      "name": selectedAddress?.name ?? profile.profileInfoModel.userDetails?.fullName ?? "",
      "phone": selectedAddress?.phone ?? profile.profileInfoModel.userDetails?.phone ?? "",
      "email": profile.profileInfoModel.userDetails?.email ?? "",
      "address": sbm.addressController.text,
      "city": selectedAddress?.city ?? "",
      "state": selectedAddress?.state ?? "",
      "zip_code": selectedAddress?.zipCode ?? (selectedAddress?.postCode?.toString()) ?? "",
      "country": "India", // Defaulting to India as per example
    };

    final bool isManualWithFile =
        gateway == "manual_payment" && file != null;

    if (isManualWithFile) {
      // ── Multipart path (only when attaching a payment screenshot) ──────────
      // Multipart fields must all be strings, so we JSON-encode nested objects
      final Map<String, String> fields = {
        'items': jsonEncode(itemsForNewApi),
        'date': DateFormat("yyyy-MM-dd").format(sbm.selectedDate.value!),
        'schedule': sbm.selectedTime.value!.format(context),
        'order_note': sbm.descriptionController.text,
        'delivery_mode': deliveryMode,
        'coupon_code': coupon.toString(),
        'address': jsonEncode(addressData),
      };

      if (sbm.selectedOutlet.value?.id != null) {
        fields['outlet_id'] = sbm.selectedOutlet.value!.id.toString();
      }

      log('Multipart fields: ${jsonEncode(fields)}');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $getToken',
      });

      final responseData = await NetworkApiServices().postWithFileApi(
        request,
        LocalKeys.payAndConfirmOrder,
        timeoutSeconds: 60,
      );
      if (responseData != null) {
        log('Place order (multipart) response: ${jsonEncode(responseData)}');
        _orderResponseModel = OrderResponseModel.fromJson(responseData);
        _enrichItemsFromCart(context);
        return true;
      }
    } else {
      // ── JSON POST path (all other gateways) ─────────────────────────────────
      final Map<String, dynamic> body = {
        'items': itemsForNewApi,
        'address': addressData,
        'delivery_mode': deliveryMode,
        'coupon_code': coupon.toString(),
        'date': DateFormat("yyyy-MM-dd").format(sbm.selectedDate.value!),
        'schedule': sbm.selectedTime.value!.format(context), // "morning" or time slot
        'order_note': sbm.descriptionController.text,
      };

      if (sbm.selectedOutlet.value?.id != null) {
        body['outlet_id'] = sbm.selectedOutlet.value!.id.toString().tryToParse;
      }

      log('JSON body: ${jsonEncode(body)}');

      final responseData = await NetworkApiServices().postApi(
        body,
        url,
        LocalKeys.payAndConfirmOrder,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 120,
      );

      if (responseData != null) {
        log('Place order response: ${jsonEncode(responseData)}');
        _orderResponseModel = OrderResponseModel.fromJson(responseData);
        _enrichItemsFromCart(context);
        return true;
      }
    }
  }

  /// Fill missing title/image in order items using cart data,
  /// since the place-order API doesn't return them.
  void _enrichItemsFromCart(BuildContext context) {
    final items = _orderResponseModel?.orderDetails?.items;
    if (items == null || items.isEmpty) return;

    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      final cart = cartService.cartList;

      for (final item in items) {
        final serviceId = item.serviceId?.toString();
        if (serviceId == null) continue;

        // Find matching cart entry by service_id
        final cartEntry = cart[serviceId];
        if (cartEntry == null) continue;

        final service = cartEntry["service"];
        if (service == null) continue;

        // Fill missing image
        if (item.image == null || item.image!.isEmpty) {
          final cartImage = service["image"]?.toString() ??
              service["service_car"]?["image"]?.toString();
          if (cartImage != null && cartImage.isNotEmpty) {
            item.image = cartImage;
          }
        }

        // Fill missing title
        if (item.itemTitle == null || item.itemTitle!.isEmpty) {
          final cartTitle = service["title"]?.toString();
          if (cartTitle != null && cartTitle.isNotEmpty) {
            item.itemTitle = cartTitle;
          }
        }
      }
    } catch (e) {
      log('Error enriching items from cart: $e');
    }
  }

  /// Step 2: Initiate Payment
  initiatePayment(dynamic orderId, String gateway) async {
    final url = AppUrls.initiatePaymentUrl;
    final Map<String, dynamic> data = {
      "order_id": orderId.toString().tryToParse,
      "payment_method": gateway,
    };

    log('Initiate Payment payload: ${jsonEncode(data)}');

    final responseData = await NetworkApiServices().postApi(
      data,
      url,
      LocalKeys.paymentGateway,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      return responseData;
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