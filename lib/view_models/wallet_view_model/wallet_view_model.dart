import 'dart:io';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/main.dart';
import 'package:car_service/models/payment_gateway_model.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/services/wallet_services/wallet_service.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:car_service/view_models/service_booking_view_model/payment_methode_navigator_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletViewModel {
  final ScrollController scrollController = ScrollController();
  final TextEditingController amountController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<Gateway?> selectedGateway = ValueNotifier(null);
  final ValueNotifier<File?> manualPaymentImage = ValueNotifier(null);
  final TextEditingController aCardController = TextEditingController();
  final TextEditingController authCodeController = TextEditingController();
  final TextEditingController zUsernameController = TextEditingController();
  final ValueNotifier<DateTime?> authNetExpireDate = ValueNotifier(null);

  WalletViewModel._init();
  static WalletViewModel? _instance;
  static WalletViewModel get instance {
    _instance ??= WalletViewModel._init();
    return _instance!;
  }

  static bool get dispose {
    _instance?.amountController.dispose();
    _instance?.scrollController.dispose();
    _instance?.aCardController.dispose();
    _instance?.authCodeController.dispose();
    _instance?.zUsernameController.dispose();
    _instance = null;
    return true;
  }

  void tryToLoadMore(BuildContext context) {
    try {
      final walletService = Provider.of<WalletService>(context, listen: false);
      final nextPage = walletService.nextPage;
      final nextPageLoading = walletService.nextPageLoading;

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          walletService.fetchNextPage();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> tryDeposit(BuildContext context) async {
    final amount = amountController.text.trim();
    if (amount.isEmpty || amount.tryToParse <= 0) {
      LocalKeys.invalidAmount.showToast();
      return;
    }

    if (selectedGateway.value == null) {
      LocalKeys.choosePaymentMethod.showToast();
      return;
    }

    if (selectedGateway.value?.name == "manual_payment" &&
        manualPaymentImage.value == null) {
      LocalKeys.selectPaymentInfo.showToast();
      return;
    }

    isLoading.value = true;

    final walletService = Provider.of<WalletService>(context, listen: false);
    final piProvider = Provider.of<ProfileInfoService>(context, listen: false);
    final userEmail = piProvider.profileInfoModel.userDetails?.email;

    final result = await walletService.createDeposit(
      amount: amount,
      paymentGateway: selectedGateway.value?.name ?? "",
      attachment: manualPaymentImage.value,
    );

    if (result != null) {
      if ([
        "manual_payment",
        "cash_on_delivery",
        "cod",
      ].contains(selectedGateway.value?.name)) {
        await _showDepositSuccess(context, isPending: true);
        isLoading.value = false;
        _resetForm();
        await walletService.refresh();
        context.pop;
      } else {
        final transactionId = result.depositDetails?.id;
        debugPrint("=== Starting payment ===");
        debugPrint("Transaction ID: $transactionId");
        debugPrint("Amount: ${result.depositDetails?.amount}");
        debugPrint("Gateway: ${selectedGateway.value?.name}");

        await startPayment(
          context,
          selectedGateway: selectedGateway.value!,
          authNetCard: aCardController.text,
          authcCode: authCodeController.text,
          zUsername: zUsernameController.text,
          authNetED: authNetExpireDate.value,
          orderId: transactionId,
          amount: result.depositDetails?.amount,
          userEmail: userEmail,
          userPhone: piProvider.profileInfoModel.userDetails?.phone,
          userName: piProvider.profileInfoModel.userDetails?.firstName,
          onSuccess: () async {
            debugPrint("=== Payment Success Callback ===");
            final currentContext = navigatorKey.currentContext;

            // Show loading dialog to prevent user interaction
            if (currentContext != null) {
              Alerts().showLoading(context: currentContext);
            }

            if (transactionId != null) {
              debugPrint("Calling updateDepositPayment...");
              if (currentContext != null) {
                await walletService.updateDepositPayment(
                  currentContext,
                  transactionId: transactionId,
                  amount: result.depositDetails?.amount,
                );
              } else {
                debugPrint("Context is null, just refreshing...");
                await walletService.refresh();
              }
            } else {
              debugPrint("Transaction ID is null, just refreshing...");
              await walletService.refresh();
            }

            // Dismiss loading dialog before navigation
            if (currentContext != null) {
              Navigator.of(currentContext, rootNavigator: true).pop();
            }

            _resetForm();
            LocalKeys.depositSuccess.showToast();
            // Navigate to wallet view
            _navigateToWallet();
            isLoading.value = false;
          },
          onFailed: () {
            isLoading.value = false;
            debugPrint("=== Payment Failed Callback ===");
            LocalKeys.paymentFailed.showToast();
            // Navigate to landing then push wallet view
            _navigateToWallet();
          },
        );
      }
    } else {
      isLoading.value = false;
    }
  }

  Future<void> _showDepositSuccess(
    BuildContext context, {
    bool isPending = false,
  }) async {
    await Alerts().showInfoDialogue(
      context: context,
      title: isPending ? LocalKeys.depositPending : LocalKeys.depositSuccess,
      description:
          isPending ? LocalKeys.depositPending : LocalKeys.depositSuccess,
      infoAsset: SvgAssets.addFilled.toSVGSized(
        60,
        color: context.color.primarySuccessColor,
      ),
    );
  }

  void _resetForm() {
    amountController.clear();
    selectedGateway.value = null;
    manualPaymentImage.value = null;
    aCardController.clear();
    authCodeController.clear();
    zUsernameController.clear();
    authNetExpireDate.value = null;
  }

  void _navigateToWallet() {
    // Pop all routes until we reach WalletDepositView, then pop it too
    navigatorKey.currentState?.popUntil((route) {
      return route.settings.name == 'WalletDepositView' || route.isFirst;
    });
    // Pop the deposit view to go back to wallet
    navigatorKey.currentState?.pop();
  }
}
