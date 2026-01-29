import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/payment/payment_gateway_service.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/wallet_view_model/wallet_view_model.dart';
import 'package:car_service/views/payment_views/payment_gateways.dart';
import 'package:car_service/views/sign_up_view/components/accepted_agreement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WalletDepositView extends StatelessWidget {
  const WalletDepositView({super.key});

  @override
  Widget build(BuildContext context) {
    final wvm = WalletViewModel.instance;

    return ChangeNotifierProvider(
      create: (context) => PaymentGatewayService(),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: AppBar(
          leading: const NavigationPopIcon(
            backgroundColor: Colors.transparent,
          ),
          title: Text(LocalKeys.addMoney),
          backgroundColor: context.color.backgroundColor,
          centerTitle: true,
        ),
        body: Consumer<PaymentGatewayService>(
          builder: (context, pg, child) {
            return CustomRefreshIndicator(
              onRefresh: () async {
                await pg.fetchGateways(refresh: true);
              },
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: 24.paddingH,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalKeys.enterAmount,
                        style: context.headlineLarge?.bold,
                      ),
                      16.toHeight,
                      TextFormField(
                        controller: wvm.amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: LocalKeys.enterAmount,
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                      ),
                      24.toHeight,
                      Text(
                        LocalKeys.choosePaymentMethod,
                        style: context.headlineSmall?.bold,
                      ),
                      16.toHeight,
                      PaymentGateways(
                        gatewayNotifier: wvm.selectedGateway,
                        attachmentNotifier: wvm.manualPaymentImage,
                        cardController: wvm.aCardController,
                        secretCodeController: wvm.authCodeController,
                        zUsernameController: wvm.zUsernameController,
                        expireDateNotifier: wvm.authNetExpireDate,
                        usernameController: TextEditingController(),
                      ),
                      24.toHeight,
                      const AcceptedAgreement(),
                      12.toHeight,
                      ValueListenableBuilder(
                        valueListenable: wvm.isLoading,
                        builder: (context, value, child) {
                          return CustomButton(
                            onPressed: () {
                              context.unFocus;
                              wvm.tryDeposit(context);
                            },
                            btText: LocalKeys.addMoney,
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
