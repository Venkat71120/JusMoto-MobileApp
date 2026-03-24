import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/payment/payment_gateway_service.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/info_tile.dart';
import 'package:car_service/utils/components/info_tile_skeleton.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:car_service/views/payment_views/payment_gateways.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../customizations/colors.dart';
import '../../services/booking_services/tax_info_service.dart';
import '../../utils/components/custom_future_widget.dart';
import '../sign_up_view/components/accepted_agreement.dart';

class BookingPaymentChooseView extends StatelessWidget {
  final bool payAgain;
  const BookingPaymentChooseView({super.key, this.payAgain = false});

  @override
  Widget build(BuildContext context) {
    final sbm = ServiceBookingViewModel.instance;
    final csProvider = Provider.of<CartService>(context, listen: false);
    return ChangeNotifierProvider(
      create: (context) => PaymentGatewayService(),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: AppBar(
          leading: NavigationPopIcon(backgroundColor: Colors.transparent),
          title: Text(LocalKeys.payment),
          backgroundColor: context.color.backgroundColor,
          centerTitle: true,
          elevation: 0,
        ),
        body: Consumer<PaymentGatewayService>(
          builder: (context, pg, child) {
            return CustomRefreshIndicator(
              onRefresh: () async {
                await pg.fetchGateways(refresh: true);
                await sbm.walletSelectorKey.currentState?.refresh();
              },
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Payment Method Selection ──
                      Text(
                        LocalKeys.choosePaymentMethod,
                        style: context.titleLarge?.bold,
                      ),
                      16.toHeight,
                      ValueListenableBuilder(
                        valueListenable: sbm.useWallet,
                        builder: (context, useWallet, child) {
                          return PaymentGateways(
                            gatewayNotifier: sbm.selectedGateway,
                            attachmentNotifier: sbm.manualPaymentImage,
                            cardController: sbm.aCardController,
                            secretCodeController: sbm.authCodeController,
                            zUsernameController: sbm.zUsernameController,
                            expireDateNotifier: sbm.authNetExpireDate,
                            usernameController: TextEditingController(),
                            onGatewaySelected: () {
                              sbm.useWallet.value = false;
                            },
                          );
                        },
                      ),

                      24.toHeight,

                      // ── Bill-style Price Card ──
                      SquircleContainer(
                        width: double.infinity,
                        radius: 16,
                        color: context.color.accentContrastColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.receipt_long_rounded,
                                      size: 20, color: primaryColor),
                                  8.toWidth,
                                  Text(
                                    "Order Bill",
                                    style: context.titleSmall?.bold6.copyWith(
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tear line
                            _buildTearLine(context),

                            // Price items
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: sbm.taxNotifier,
                                    builder: (context, value, child) {
                                      return ValueListenableBuilder(
                                        valueListenable: sbm.couponDiscount,
                                        builder: (context, value, child) =>
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!payAgain) ...[
                                              InfoTile(
                                                title: LocalKeys.subtotal,
                                                value:
                                                    csProvider.subTotal.cur,
                                              ),
                                              12.toHeight,
                                              InfoTile(
                                                title: LocalKeys.discount,
                                                value:
                                                    "- ${sbm.getCouponAmount(context).cur}",
                                                valueColor: sbm
                                                            .getCouponAmount(
                                                                context) >
                                                        0
                                                    ? context.color
                                                        .primarySuccessColor
                                                    : null,
                                              ),
                                              if (sbm.getCouponAmount(
                                                      context) >
                                                  0)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0,
                                                          top: 4.0),
                                                  child: Text(
                                                    "Awesome! You saved ${sbm.getCouponAmount(context).cur}",
                                                    style: context.labelSmall
                                                        ?.price.copyWith(
                                                      color: context.color
                                                          .primarySuccessColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              12.toHeight,
                                              CustomFutureWidget(
                                                function: sbm.taxCalculated
                                                    ? null
                                                    : TaxInfoService()
                                                        .fetchTaxInfo(),
                                                shimmer: InfoTileSkeleton(),
                                                child: Column(
                                                  children: [
                                                    InfoTile(
                                                      title: LocalKeys
                                                          .deliveryCharge,
                                                      value: sbm
                                                          .getCalculatedDelivery(
                                                              context)
                                                          .cur,
                                                    ),
                                                    12.toHeight,
                                                    InfoTile(
                                                      title:
                                                          LocalKeys.taxInfo,
                                                      value: sbm
                                                          .getCalculatedTax(
                                                              context)
                                                          .cur,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              12.toHeight,
                                            ],
                                            Divider(
                                              color: context
                                                  .color.primaryBorderColor,
                                              height: 16,
                                            ),
                                            8.toHeight,
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    LocalKeys.total,
                                                    style: context
                                                        .titleMedium?.bold,
                                                  ),
                                                ),
                                                Text(
                                                  (payAgain
                                                          ? sbm.payAgainAmount
                                                          : sbm.totalAmount(
                                                              context))
                                                      .cur,
                                                  style: context
                                                      .titleMedium?.bold
                                                      .price.copyWith(
                                                    color: primaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Coupon section
                            if (!payAgain) ...[
                              _buildTearLine(context),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Have a coupon?",
                                      style: context.bodySmall?.bold5,
                                    ),
                                    10.toHeight,
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller:
                                                sbm.couponController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  LocalKeys.enterCode,
                                              contentPadding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                            ),
                                            onFieldSubmitted: (value) {
                                              sbm.tryGettingCouponInfo(
                                                  context);
                                            },
                                          ),
                                        ),
                                        12.toWidth,
                                        Expanded(
                                          flex: 1,
                                          child:
                                              ValueListenableBuilder(
                                            valueListenable:
                                                sbm.couponLoading,
                                            builder: (context, value,
                                                    child) =>
                                                CustomButton(
                                              onPressed: () {
                                                context.unFocus;
                                                sbm.tryGettingCouponInfo(
                                                    context);
                                              },
                                              btText:
                                                  LocalKeys.applyCoupon,
                                              isLoading: value,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      20.toHeight,
                      const AcceptedAgreement(),
                      16.toHeight,

                      // ── Pay Button ──
                      ValueListenableBuilder(
                        valueListenable: sbm.isLoading,
                        builder: (context, value, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              onPressed: () {
                                context.unFocus;
                                final sbm =
                                    ServiceBookingViewModel.instance;
                                if (payAgain) {
                                  sbm.tryPayAgain(context);
                                  return;
                                }
                                sbm.tryPlacingCartOrder(context);
                              },
                              btText: payAgain
                                  ? LocalKeys.payNow
                                  : LocalKeys.payAndConfirmOrder,
                              isLoading: value,
                            ),
                          );
                        },
                      ),
                      24.toHeight,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTearLine(BuildContext context) {
    return Row(
      children: List.generate(
        150,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index.isEven
                ? context.color.primaryBorderColor
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
