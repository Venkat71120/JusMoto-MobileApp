import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/wallet_services/wallet_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:car_service/view_models/wallet_view_model/wallet_view_model.dart';
import 'package:car_service/views/wallet_view/components/transaction_tile.dart';
import 'package:car_service/views/wallet_view/components/wallet_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'wallet_deposit_view.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final wvm = WalletViewModel.instance;
    wvm.scrollController.addListener(() {
      wvm.tryToLoadMore(context);
    });

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: Text(LocalKeys.wallet),
        centerTitle: true,
        backgroundColor: context.color.backgroundColor,
      ),
      body: Consumer<WalletService>(
        builder: (context, ws, child) {
          return CustomRefreshIndicator(
            onRefresh: () async {
              await ws.fetchWalletBalance();
              await ws.fetchTransactions();
            },
            child: CustomFutureWidget(
              function:
                  ws.shouldAutoFetch
                      ? Future.wait([
                        ws.fetchWalletBalance(),
                        ws.fetchTransactions(),
                      ])
                      : null,
              shimmer: const _WalletShimmer(),
              child: CustomScrollView(
                controller: wvm.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  16.toHeight.toSliver,
                  WalletBalanceCard(
                    balance: ws.walletBalance.availableBalance,
                    onAddMoney: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WalletDepositView(),
                          settings: const RouteSettings(name: 'WalletDepositView'),
                        ),
                      );
                    },
                  ).toSliver,
                  24.toHeight.toSliver,
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: 16.paddingH,
                      child: Text(
                        LocalKeys.transactionHistory,
                        style: context.headlineSmall?.bold,
                      ),
                    ),
                  ),
                  12.toHeight.toSliver,
                  if (ws.transactionList.transactions.isEmpty)
                    EmptyWidget(title: LocalKeys.noTransactionsFound).toSliver
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        final transaction =
                            ws.transactionList.transactions[index];
                        return TransactionTile(transaction: transaction);
                      },
                      separatorBuilder: (context, index) => 8.toHeight,
                      itemCount: ws.transactionList.transactions.length,
                    ),
                  16.toHeight.toSliver,
                  if (ws.nextPage != null && !ws.nexLoadingFailed)
                    ScrollPreloader(loading: ws.nextPageLoading).toSliver,
                  24.toHeight.toSliver,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

class _WalletShimmer extends StatelessWidget {
  const _WalletShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.toHeight,
        Padding(
          padding: 16.paddingH,
          child: TextSkeleton(
            height: 150,
            width: double.infinity,
            radius: 16,
            color: context.color.accentContrastColor,
          ),
        ),
        24.toHeight,
        Padding(
          padding: 16.paddingH,
          child: Column(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextSkeleton(
                  height: 70,
                  width: double.infinity,
                  radius: 12,
                  color: context.color.accentContrastColor,
                ),
              ),
            ),
          ),
        ),
      ],
    ).shim;
  }
}
