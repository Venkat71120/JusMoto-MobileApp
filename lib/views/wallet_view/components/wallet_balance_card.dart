import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  final num balance;
  final VoidCallback onAddMoney;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 16.paddingH,
      child: Container(
        width: double.infinity,
        padding: 20.paddingAll,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: 8.paddingAll,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgAssets.creditCard.toSVGSized(
                    24,
                    color: Colors.white,
                  ),
                ),
                12.toWidth,
                Text(
                  LocalKeys.availableBalance,
                  style: context.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            16.toHeight,
            Text(
              balance.cur,
              style: context.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            20.toHeight,
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: onAddMoney,
                btText: LocalKeys.addMoney,
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
