import 'package:car_service/services/wallet_services/wallet_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/wallet_payment_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletPaymentSelector extends StatefulWidget {
  final ValueNotifier<bool> useWalletNotifier;
  final VoidCallback? onWalletSelected;

  const WalletPaymentSelector({
    super.key,
    required this.useWalletNotifier,
    this.onWalletSelected,
  });

  @override
  State<WalletPaymentSelector> createState() => WalletPaymentSelectorState();
}

class WalletPaymentSelectorState extends State<WalletPaymentSelector> {
  late Future<void> _walletBalanceFuture;

  @override
  void initState() {
    super.initState();
    final walletService = Provider.of<WalletService>(context, listen: false);
    _walletBalanceFuture = walletService.fetchWalletBalance();
  }

  Future<void> refresh() async {
    final walletService = Provider.of<WalletService>(context, listen: false);
    await walletService.fetchWalletBalance();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureWidget(
      function: _walletBalanceFuture,
      shimmer: const WalletPaymentTile(
        isSelected: false,
        balance: 0,
        isLoading: true,
      ),
      child: Consumer<WalletService>(
        builder: (context, ws, child) {
          return ValueListenableBuilder(
            valueListenable: widget.useWalletNotifier,
            builder: (context, useWallet, child) {
              return WalletPaymentTile(
                isSelected: useWallet,
                balance: ws.walletBalance.availableBalance,
                onTap: () {
                  widget.useWalletNotifier.value =
                      !widget.useWalletNotifier.value;
                  widget.onWalletSelected?.call();
                },
              );
            },
          );
        },
      ),
    );
  }
}
