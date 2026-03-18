// ─────────────────────────────────────────────────────────────────────────────
// UPDATED: FranchiseLandingNavBar.dart
// Change index 2 from "Reports" → "Services" (support agent icon)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:badges/badges.dart' as badges;
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/view_models/Franchise_landing_view_model/FranchiseLandingViewModel.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_tickets_service.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../services/theme_service.dart';

class FranchiseLandingNavBar extends StatelessWidget {
  const FranchiseLandingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FranchiseLandingViewModel.instance;
    return ValueListenableBuilder(
      valueListenable: fvm.currentIndex,
      builder: (context, value, child) => Container(
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
        ),
        height: 78,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBarItem(
              context,
              LocalKeys.home,
              SvgAssets.home,
              SvgAssets.homeBold,
              0,
              fvm,
            ),
            Consumer<FranchiseDashboardService>(
              builder: (context, ds, _) => _navBarItem(
                context,
                LocalKeys.orders,
                SvgAssets.list,
                SvgAssets.list,
                1,
                fvm,
                badgeCount: ds.orderCounts.pending + ds.orderCounts.active,
              ),
            ),
            Consumer<FranchiseTicketsService>(
              builder: (context, ts, _) {
                if (ts.shouldAutoFetch) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => ts.fetchAll());
                }
                return _navBarItem(
                  context,
                  'Services',
                  SvgAssets.store,
                  SvgAssets.storeBold,
                  2,
                  fvm,
                  badgeCount: ts.statistics.open,
                );
              },
            ),
            _navBarItem(
              context,
              LocalKeys.profile,
              SvgAssets.user,
              SvgAssets.userBold,
              3,
              fvm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navBarItem(
    BuildContext context,
    String label,
    String iconNormal,
    String iconBold,
    int index,
    FranchiseLandingViewModel fvm, {
    int badgeCount = 0,
  }) {
    final selected = index == fvm.currentIndex.value;
    return InkWell(
      onTap: () {
        fvm.setContext(context);
        fvm.setNavIndex(index);
      },
      child: SquircleContainer(
        alignment: Alignment.center,
        color: Colors.transparent,
        radius: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: badges.Badge(
                showBadge: (badgeCount > 0 && !selected),
                position: badges.BadgePosition.topEnd(),
                badgeContent: Text(
                  '$badgeCount',
                  style: const TextStyle().copyWith(
                    color: context.color.accentContrastColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: (selected ? iconBold : iconNormal).toSVGSized(
                  24,
                  color: selected
                      ? primaryColor
                      : context.color.secondaryContrastColor,
                ),
              ),
            ),
            8.toHeight,
            Text(
              label,
              style: context.bodySmall
                  ?.copyWith(
                    color: selected
                        ? primaryColor
                        : context.color.secondaryContrastColor,
                  )
                  .bold5,
            ),
          ],
        ),
      ),
    );
  }
}