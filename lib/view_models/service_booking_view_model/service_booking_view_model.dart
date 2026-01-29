import 'dart:io';

import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/models/address_models/address_model.dart';
import 'package:car_service/services/booking_services/booking_addons_service.dart';
import 'package:car_service/services/booking_services/place_order_service.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/services/wallet_services/wallet_service.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:car_service/utils/components/wallet_payment_selector.dart';
import 'package:car_service/view_models/service_booking_view_model/payment_methode_navigator_helper.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:car_service/views/order_details_view/order_details_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app_static_values.dart';
import '../../models/outlet_model.dart';
import '../../models/payment_gateway_model.dart';
import '../../models/schedule_list_model.dart';
import '../../models/service/admin_staff_list_model.dart';
import '../../models/service/service_details_model.dart';
import '../../services/booking_services/coupon_info_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../views/order_summery_view/order_summery_view.dart';
import '../order_list_view_model/order_status_enums.dart';

class ServiceBookingViewModel {
  final ValueNotifier<DateTime?> selectedDate = ValueNotifier(null);
  final ValueNotifier<TimeOfDay?> selectedTime = ValueNotifier(null);
  final ValueNotifier<Schedule?> selectedSchedule = ValueNotifier(null);
  final ValueNotifier<Address?> selectedAddress = ValueNotifier(null);
  final ValueNotifier<LatLng?> selectedLatLng = ValueNotifier(null);
  final ValueNotifier<Staff?> selectedStaff = ValueNotifier(null);
  final ValueNotifier<Outlet?> selectedOutlet = ValueNotifier(null);
  final ValueNotifier<ServiceDetails?> selectedService = ValueNotifier(null);
  final ValueNotifier<Map> addons = ValueNotifier({});
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> paymentLoading = ValueNotifier(false);
  final ValueNotifier<bool> couponLoading = ValueNotifier(false);
  final ValueNotifier<DeliveryOption> serviceMethod =
      ValueNotifier(DeliveryOption.PICKUP);
  final ValueNotifier<File?> manualPaymentImage = ValueNotifier(null);
  final TextEditingController addressController = TextEditingController();

  dynamic _orderDetailsId;
  num _payAgainAmount = 0;
  num get payAgainAmount => _payAgainAmount;
  final ValueNotifier<num> taxNotifier = ValueNotifier(0);
  final ValueNotifier<num> deliveryNotifier = ValueNotifier(0);
  final ValueNotifier<CouponInfoModel?> couponDiscount = ValueNotifier(null);
  num get tax => taxNotifier.value;
  num get deliveryCharge => deliveryNotifier.value;
  String _taxType = "percentage";
  String _deliveryType = "percentage";
  String get taxType => _taxType;
  String get deliveryType => _deliveryType;
  bool taxCalculated = false;
  bool deliver = false;

  setTax(num taxAmount, taxType, deliveryAmount, deliveryType) {
    taxNotifier.value = taxAmount;
    deliveryNotifier.value = deliveryAmount;
    _taxType = taxType ?? "percentage";
    _deliveryType = deliveryType ?? "flat";

    taxCalculated = true;
  }

  num getCalculatedTax(BuildContext context) {
    if (taxType == "fixed") {
      return tax;
    }

    final subtotalAmount =
        Provider.of<CartService>(context, listen: false).subTotal;
    final cpAmount = getCouponAmount(context);
    num ct = (tax / 100) * (subtotalAmount - cpAmount);
    return ct;
  }

  num getCalculatedDelivery(BuildContext context) {
    if (deliveryType == "flat") {
      return deliveryCharge;
    }

    final totalQuantity =
        Provider.of<CartService>(context, listen: false).totalQuantity;

    return (totalQuantity) * deliveryCharge;
  }

  num getCouponAmount(BuildContext context) {
    if ((couponDiscount.value?.coupon?.discount ?? 0) <= 0) return 0;
    if (couponDiscount.value?.coupon?.discountType != "percentage") {
      return couponDiscount.value?.coupon?.discount ?? 0;
    }
    num tempAmount = 0;
    final subtotalAmount =
        Provider.of<CartService>(context, listen: false).subTotal;
    tempAmount =
        (couponDiscount.value!.coupon!.discount / 100) * (subtotalAmount);

    return tempAmount;
  }

  get orderDetailsId => _orderDetailsId;

  bool fromCart = false;

  bool orderFromCart = true;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController couponController = TextEditingController();

  ValueNotifier dateScheduleType = ValueNotifier(SelectingScheduleType.date);

  TextEditingController aCardController = TextEditingController();
  TextEditingController zUsernameController = TextEditingController();
  TextEditingController authCodeController = TextEditingController();
  ValueNotifier<Gateway?> selectedGateway = ValueNotifier(null);
  ValueNotifier<DateTime?> authNetExpireDate = ValueNotifier(null);
  ValueNotifier<bool> useWallet = ValueNotifier(false);
  final walletSelectorKey = GlobalKey<WalletPaymentSelectorState>();

  num totalAmount(BuildContext context) {
    num subTotal = 0;
    try {
      final subtotalAmount =
          Provider.of<CartService>(context, listen: false).subTotal;
      final dvAmount = getCalculatedDelivery(context);
      final txtAmount = getCalculatedTax(context);
      final cpAmount = getCouponAmount(context);
      subTotal = subtotalAmount + dvAmount + txtAmount - cpAmount;
    } catch (e) {}
    return subTotal;
  }

  bool get serviceBookingAddonViewValidate {
    if (selectedSchedule.value == null) {
      LocalKeys.selectASchedule.showToast();
      return false;
    } else if (selectedAddress.value == null) {
      LocalKeys.selectAddress.showToast();
      return false;
    }
    return true;
  }

  ServiceBookingViewModel._init();
  static ServiceBookingViewModel? _instance;
  static ServiceBookingViewModel get instance {
    _instance ??= ServiceBookingViewModel._init();
    return _instance!;
  }

  ServiceBookingViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  bool get validateAddressSchedule {
    bool inValid = false;
    if (serviceMethod.value == DeliveryOption.PICKUP &&
        addressController.text.trim().isEmpty) {
      LocalKeys.enterAddress.showToast();
      return true;
    } else if (serviceMethod.value == DeliveryOption.OUTLET &&
        selectedOutlet.value == null) {
      LocalKeys.selectOutlet.showToast();
      return true;
    }
    if (selectedDate.value == null || selectedTime.value == null) {
      LocalKeys.selectASchedule.showToast();
      return true;
    }

    return inValid;
  }

  void setAddons(BuildContext context) {
    addons.value =
        Provider.of<BookingAddonsService>(context, listen: false).addons;
  }

  tryAddingCart(BuildContext context) async {
    final cProvider = Provider.of<CartService>(context, listen: false);

    cProvider.addToCart(
      selectedService.value?.id?.toString() ?? "",
      selectedService.value?.toMinimizedJson(),
    );
  }

  tryUpdateCart(BuildContext context) async {
    final cProvider = Provider.of<CartService>(context, listen: false);
  }

  tryRemoveCart(BuildContext context) async {
    final cProvider = Provider.of<CartService>(context, listen: false);

    cProvider.deleteFromCart(
      selectedService.value?.id?.toString() ?? "",
    );
    context.pop;
  }

  initCartItem(cartItem) {
    fromCart = true;
    selectedService.value = ServiceDetails.fromJson(cartItem["service"]);
    selectedAddress.value = Address.fromJson(cartItem["address"]);
    selectedDate.value = DateTime.tryParse(cartItem["date"].toString());
    selectedSchedule.value = Schedule.fromJson(cartItem["schedule"]);
    try {
      selectedStaff.value = Staff.fromJson(cartItem["staff"]);
    } catch (e) {}
    addons.value = cartItem["addons"];
    debugPrint(cartItem["addons"].toString());
    descriptionController.text = cartItem["note"];
  }

  setInstantBooking() {
    orderFromCart = false;
  }

  void tryPlacingCartOrder(BuildContext context) async {
    final po = Provider.of<PlaceOrderService>(context, listen: false);
    final cs = Provider.of<CartService>(context, listen: false);
    final ws = Provider.of<WalletService>(context, listen: false);

    // Determine the payment gateway
    final String paymentGateway;
    if (useWallet.value) {
      paymentGateway = "wallet";
      // Validate wallet balance
      final orderTotal = totalAmount(context);
      if (ws.walletBalance.availableBalance < orderTotal) {
        LocalKeys.insufficientWalletBalance.showToast();
        return;
      }
    } else if (selectedGateway.value != null) {
      paymentGateway = selectedGateway.value!.name ?? "";
    } else {
      LocalKeys.choosePaymentMethod.showToast();
      return;
    }

    if (selectedGateway.value?.name == "manual_payment" &&
        manualPaymentImage.value == null) {
      LocalKeys.selectPaymentInfo.showToast();
      debugPrint(getToken.toString());
      return;
    }
    var result;
    isLoading.value = true;
    if (orderFromCart) {
      final services = cs.servicesForOrder;
      result = await po.tryPlacingOrder(
        context,
        services,
        paymentGateway,
        manualPaymentImage.value,
        couponController.text,
      );
    } else {
      final services = [
        {
          "service_id": selectedService.value?.id,
          "staff_id": selectedStaff.value?.id,
          "location_id": selectedAddress.value?.id,
          "date": DateFormat("yyyy-MM-dd").format(selectedDate.value!),
          "schedule": selectedSchedule.value?.value,
          "order_note": descriptionController.text,
        }
      ];
      final addOns = [];
      for (var a in addons.value.values.toList()) {
        try {
          addOns.add({
            "addon_service_id": a["addon_service_id"],
            "service_id": a["service_id"],
            "quantity": a["quantity"]
          });
        } catch (e) {}
      }
      result = await po.tryPlacingOrder(
        context,
        services,
        paymentGateway,
        manualPaymentImage.value,
        couponController.text,
      );
    }

    // Handle wallet payment success - no external payment needed
    if (result == true && useWallet.value) {
      // Refresh wallet balance after payment
      ws.refresh();
      context.toPage(const OrderSummeryView());
    } else if (result == true &&
        ["manual_payment", "cash_on_delivery", "cod"].contains(paymentGateway)) {
      context.toPage(const OrderSummeryView());
    } else if (result == true) {
      final po = Provider.of<PlaceOrderService>(context, listen: false);
      final piProvider =
          Provider.of<ProfileInfoService>(context, listen: false);
      startPayment(
        context,
        selectedGateway: selectedGateway.value!,
        authNetCard: aCardController.text,
        authcCode: aCardController.text,
        zUsername: zUsernameController.text,
        authNetED: authNetExpireDate.value,
        orderId: po.orderResponseModel.orderDetails?.id,
        amount: po.orderResponseModel.orderDetails?.total,
        userEmail: piProvider.profileInfoModel.userDetails?.email,
        userPhone: piProvider.profileInfoModel.userDetails?.phone,
        userName: piProvider.profileInfoModel.userDetails?.firstName,
        onSuccess: () {
          context.toPage(OrderSummeryView(
            updateFunction: (cxt) async {
              try {
                paymentLoading.value = true;
                final result =
                    await Provider.of<PlaceOrderService>(cxt, listen: false)
                        .updatePayment(cxt);
                if (result != true) {
                  cxt.snackBar(
                    LocalKeys.paymentUpdateFailed,
                    buttonText: LocalKeys.retry,
                    onTap: () async {
                      paymentLoading.value = true;

                      await Provider.of<PlaceOrderService>(cxt, listen: false)
                          .updatePayment(cxt);

                      paymentLoading.value = false;
                    },
                  );
                }
              } catch (e) {
                debugPrint(e.toString());
              } finally {
                paymentLoading.value = false;
              }
            },
          ));
        },
        onFailed: () {
          context.toPage(const OrderSummeryView());
        },
      );
    }

    if (orderFromCart && result == true) {
      cs.clearCart();
    }
    isLoading.value = false;
  }

  tryPayAgain(BuildContext context) async {
    if (selectedGateway.value?.name == null) {
      LocalKeys.choosePaymentMethod.showToast();
      return;
    }
    final piProvider = Provider.of<ProfileInfoService>(context, listen: false);
    startPayment(
      context,
      selectedGateway: selectedGateway.value!,
      authNetCard: aCardController.text,
      authcCode: aCardController.text,
      zUsername: zUsernameController.text,
      authNetED: authNetExpireDate.value,
      orderId: orderDetailsId,
      amount: payAgainAmount,
      userEmail: piProvider.profileInfoModel.userDetails?.email,
      userPhone: piProvider.profileInfoModel.userDetails?.phone,
      userName: piProvider.profileInfoModel.userDetails?.firstName,
      onSuccess: () async {
        Alerts().showLoading(context: context);
        try {
          paymentLoading.value = true;
          final result =
              await Provider.of<PlaceOrderService>(context, listen: false)
                  .updatePayment(context, id: orderDetailsId);
          context.pop;
          if (result != true) {
            debugPrint(orderDetailsId.toString());
            context.snackBar(
              LocalKeys.paymentUpdateFailed,
              buttonText: LocalKeys.retry,
              onTap: () async {
                paymentLoading.value = true;

                await Provider.of<PlaceOrderService>(context, listen: false)
                    .updatePayment(context, id: orderDetailsId);

                paymentLoading.value = false;
              },
            );
          } else {
            await Alerts().showInfoDialogue(
                context: context,
                title: LocalKeys.paymentSuccess,
                description: LocalKeys.paymentProcessedSuccessfully,
                infoAsset: SvgAssets.addFilled
                    .toSVGSized(60, color: context.color.primarySuccessColor));
            context.toUntilPage(const LandingView());
            context.toPage(OrderDetailsView(
              orderId: orderDetailsId,
            ));
          }
        } catch (e) {
          debugPrint(e.toString());
        } finally {
          paymentLoading.value = false;
        }
      },
      onFailed: () {
        LocalKeys.paymentUpdateFailed.showToast();
        context.pop;
        context.pop;
      },
    );
  }

  void setPayableAmount(num amount, dynamic id) {
    _payAgainAmount = amount;
    _orderDetailsId = id;
  }

  void tryGettingCouponInfo(BuildContext context) async {
    couponLoading.value = true;
    await CouponInfoService().fetchCouponInfo();
    couponLoading.value = false;
  }
}

EnumValues get serviceDeliveryOptions => EnumValues({
      LocalKeys.visitOutlet: DeliveryOption.OUTLET,
      LocalKeys.pickupAndDelivery: DeliveryOption.PICKUP,
    });

enum SelectingScheduleType { date, schedule }
