import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/payment/payment_gateway_service.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/info_tile.dart';
import 'package:car_service/utils/components/info_tile_skeleton.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/wallet_payment_selector.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:car_service/views/payment_views/payment_gateways.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  padding: 24.paddingH,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalKeys.choosePaymentMethod,
                        style: context.headlineLarge?.bold,
                      ),
                      24.toHeight,
                      // Other Payment Gateways
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
                              // Deselect wallet when other gateway is selected
                              sbm.useWallet.value = false;
                            },
                          );
                        },
                      ),
                      16.toHeight,
                      // Wallet Payment Option
                      WalletPaymentSelector(
                        key: sbm.walletSelectorKey,
                        useWalletNotifier: sbm.useWallet,
                        onWalletSelected: () {
                          // Deselect other gateway when wallet is selected
                          if (sbm.useWallet.value) {
                            sbm.selectedGateway.value = null;
                          }
                        },
                      ),
                      16.toHeight,
                      SquircleContainer(
                        padding: 12.paddingAll,
                        radius: 8,
                        color: context.color.accentContrastColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: sbm.taxNotifier,
                              builder: (context, value, child) {
                                return SizedBox(
                                  child: ValueListenableBuilder(
                                    valueListenable: sbm.couponDiscount,
                                    builder:
                                        (context, value, child) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!payAgain) ...[
                                              InfoTile(
                                                title: LocalKeys.subtotal,
                                                value: csProvider.subTotal.cur,
                                              ),
                                              12.toHeight,
                                              InfoTile(
                                                title: LocalKeys.discount,
                                                value:
                                                    "- ${sbm.getCouponAmount(context).cur}",
                                              ),
                                              12.toHeight,
                                              CustomFutureWidget(
                                                function:
                                                    sbm.taxCalculated
                                                        ? null
                                                        : TaxInfoService()
                                                            .fetchTaxInfo(),
                                                shimmer: InfoTileSkeleton(),
                                                child: Column(
                                                  children: [
                                                    InfoTile(
                                                      title:
                                                          LocalKeys
                                                              .deliveryCharge,
                                                      value:
                                                          sbm
                                                              .getCalculatedDelivery(
                                                                context,
                                                              )
                                                              .cur,
                                                    ),
                                                    12.toHeight,
                                                    InfoTile(
                                                      title: LocalKeys.taxInfo,
                                                      value:
                                                          sbm
                                                              .getCalculatedTax(
                                                                context,
                                                              )
                                                              .cur,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              12.toHeight,
                                            ],
                                            InfoTile(
                                              title: LocalKeys.total,
                                              value:
                                                  (payAgain
                                                          ? sbm.payAgainAmount
                                                          : (sbm.totalAmount(
                                                            context,
                                                          )))
                                                      .cur,
                                            ),
                                          ],
                                        ),
                                  ),
                                );
                              },
                            ),
                            if (!payAgain) ...[
                              12.toHeight,
                              const SizedBox().divider,
                              12.toHeight,
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: sbm.couponController,
                                      decoration: InputDecoration(
                                        hintText: LocalKeys.enterCode,
                                      ),
                                      onFieldSubmitted: (value) {
                                        sbm.tryGettingCouponInfo(context);
                                      },
                                    ),
                                  ),
                                  12.toWidth,
                                  Expanded(
                                    flex: 1,
                                    child: ValueListenableBuilder(
                                      valueListenable: sbm.couponLoading,
                                      builder:
                                          (context, value, child) =>
                                              CustomButton(
                                                onPressed: () {
                                                  context.unFocus;
                                                  sbm.tryGettingCouponInfo(
                                                    context,
                                                  );
                                                },
                                                btText: LocalKeys.applyCoupon,
                                                isLoading: value,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      24.toHeight,
                      const AcceptedAgreement(),
                      12.toHeight,
                      ValueListenableBuilder(
                        valueListenable: sbm.isLoading,
                        builder: (context, value, child) {
                          return CustomButton(
                            onPressed: () {
                              context.unFocus;
                              final sbm = ServiceBookingViewModel.instance;
                              if (payAgain) {
                                sbm.tryPayAgain(context);
                                return;
                              }
                              sbm.tryPlacingCartOrder(context);
                            },
                            btText:
                                payAgain
                                    ? LocalKeys.payNow
                                    : LocalKeys.payAndConfirmOrder,
                            isLoading: value,
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
}
