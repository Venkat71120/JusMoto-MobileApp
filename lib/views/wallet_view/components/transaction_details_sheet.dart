import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/wallet_models/wallet_model.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

class TransactionDetailsSheet extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionDetailsSheet({
    super.key,
    required this.transaction,
  });

  static void show(BuildContext context, WalletTransaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.isDeposit;
    final statusColor = _getStatusColor(context);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        child: Padding(
          padding: 20.paddingAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.color.tertiaryContrastColo,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              20.toHeight,
              Center(
                child: Container(
                  padding: 16.paddingAll,
                  decoration: BoxDecoration(
                    color: isDeposit
                        ? context.color.primarySuccessColor.withValues(alpha: 0.1)
                        : context.color.primaryWarningColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isDeposit
                        ? context.color.primarySuccessColor
                        : context.color.primaryWarningColor,
                    size: 32,
                  ),
                ),
              ),
              16.toHeight,
              Center(
                child: Text(
                  "${isDeposit ? "+" : "-"}${transaction.amount.cur}",
                  style: context.headlineLarge?.copyWith(
                    color: isDeposit
                        ? context.color.primarySuccessColor
                        : context.color.primaryWarningColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              8.toHeight,
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: context.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              24.toHeight,
              SquircleContainer(
                padding: 16.paddingAll,
                radius: 12,
                color: context.color.accentContrastColor,
                child: Column(
                  children: [
                    if (transaction.invoiceNumber != null) ...[
                      _DetailRow(
                        label: LocalKeys.invoiceNumber,
                        value: "#${transaction.invoiceNumber}",
                      ),
                      const _DetailDivider(),
                    ],
                    _DetailRow(
                      label: LocalKeys.type,
                      value: _getTransactionTypeText(),
                    ),
                    if (transaction.paymentGateway != null) ...[
                      const _DetailDivider(),
                      _DetailRow(
                        label: LocalKeys.paymentMethod,
                        value: transaction.paymentGateway!.replaceAll('_', ' ').toUpperCase(),
                      ),
                    ],
                    if (transaction.description != null &&
                        transaction.description!.isNotEmpty) ...[
                      const _DetailDivider(),
                      _DetailRow(
                        label: LocalKeys.description,
                        value: transaction.description!,
                      ),
                    ],
                    if (transaction.referenceType != null) ...[
                      const _DetailDivider(),
                      _DetailRow(
                        label: LocalKeys.referenceType,
                        value: transaction.referenceType!,
                      ),
                    ],
                    if (transaction.createdAt != null) ...[
                      const _DetailDivider(),
                      _DetailRow(
                        label: LocalKeys.date,
                        value: transaction.createdAt!,
                      ),
                    ],
                  ],
                ),
              ),
              20.toHeight,
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

  String _getTransactionTypeText() {
    if (transaction.isDeposit) {
      return LocalKeys.walletDeposit;
    } else if (transaction.isPayment) {
      return LocalKeys.payment;
    }
    return transaction.transactionType ?? "";
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.bodyMedium?.copyWith(
              color: context.color.tertiaryContrastColo,
            ),
          ),
          8.toWidth,
          Flexible(
            child: Text(
              value,
              style: context.bodyMedium?.bold,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: context.color.primaryBorderColor,
      height: 1,
    );
  }
}
