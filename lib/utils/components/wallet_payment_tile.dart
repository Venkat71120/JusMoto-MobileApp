import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

class WalletPaymentTile extends StatelessWidget {
  final bool isSelected;
  final num balance;
  final VoidCallback? onTap;
  final bool isLoading;

  const WalletPaymentTile({
    super.key,
    required this.isSelected,
    required this.balance,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      onTap: onTap,
      child: SquircleContainer(
        padding: 12.paddingAll,
        radius: 12,
        color:
            isSelected ? mutedPrimaryColor : context.color.accentContrastColor,
        // borderColor: isSelected
        //     ? primaryColor
        //     : context.color.primaryBorderColor,
        // borderWidth: isSelected ? 2 : 1,
        child: Row(
          children: [
            Container(
              padding: 10.paddingAll,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: primaryColor,
                size: 24,
              ),
            ),
            12.toWidth,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(balance.cur, style: context.bodyLarge?.bold),
                  4.toHeight,
                  Text(
                    LocalKeys.walletBalance,
                    style: context.bodySmall?.copyWith(
                      color: context.color.tertiaryContrastColo,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  isSelected
                      ? primaryColor
                      : context.color.tertiaryContrastColo,
              size: 24,
            ),
          ],
        ),
      ),
    );

    if (isLoading) {
      return content.shim;
    }
    return content;
  }
}
