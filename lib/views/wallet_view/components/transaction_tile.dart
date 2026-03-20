import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/wallet_models/wallet_model.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/views/wallet_view/components/transaction_details_sheet.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.isDeposit;
    final statusColor = _getStatusColor(context);

    return Padding(
      padding: 16.paddingH,
      child: GestureDetector(
        onTap: () => TransactionDetailsSheet.show(context, transaction),
        child: SquircleContainer(
          padding: 12.paddingAll,
          radius: 12,
          color: context.color.accentContrastColor,
          child: Row(
            children: [
              Container(
                padding: 10.paddingAll,
                decoration: BoxDecoration(
                  color: isDeposit
                      ? context.color.primarySuccessColor.withValues(alpha: 0.1)
                      : context.color.primaryWarningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isDeposit
                      ? context.color.primarySuccessColor
                      : context.color.primaryWarningColor,
                  size: 20,
                ),
              ),
              12.toWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ??
                          (isDeposit ? LocalKeys.walletDeposit : LocalKeys.payment),
                      style: context.bodyMedium?.bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.toHeight,
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            transaction.createdAt ?? "",
                            style: context.bodySmall?.copyWith(
                              color: context.color.tertiaryContrastColo,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        8.toWidth,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: context.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              8.toWidth,
              Text(
                "${isDeposit ? "+" : "-"}${transaction.amount.cur}",
                style: context.bodyLarge?.price.copyWith(
                  color: isDeposit
                      ? context.color.primarySuccessColor
                      : context.color.primaryWarningColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (transaction.status) {
      case 'completed':
        return context.color.primarySuccessColor;
      case 'pending':
        return context.color.primaryPendingColor;
      case 'failed':
        return context.color.primaryWarningColor;
      default:
        return context.color.tertiaryContrastColo;
    }
  }

  String _getStatusText() {
    switch (transaction.status) {
      case 'completed':
        return LocalKeys.complete;
      case 'pending':
        return LocalKeys.pending;
      case 'failed':
        return LocalKeys.paymentFailed;
      default:
        return transaction.status ?? "";
    }
  }
}
