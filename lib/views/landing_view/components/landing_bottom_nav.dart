import 'package:badges/badges.dart' as badges;
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../services/service/services_search_service.dart';
import '../../../services/theme_service.dart';
import '../../../view_models/filter_view_model/filter_view_model.dart';
import '../../../view_models/home_view_model/home_view_model.dart';
import '../../../view_models/landding_view_model/landding_view_model.dart';

class LandingNavBar extends StatelessWidget {
  const LandingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ov = LandingViewModel.instance;
    return Consumer<ThemeService>(
      builder: (context, ts, child) {
        return ValueListenableBuilder(
          valueListenable: ov.currentIndex,
          builder:
              (context, value, child) => Container(
                decoration: BoxDecoration(
                  color: context.color.accentContrastColor,
                ),
                height: 78,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    navBarItem(
                      context,
                      LocalKeys.home,
                      SvgAssets.home,
                      SvgAssets.homeBold,
                      0,
                      ov,
                    ),
                    navBarItem(
                      context,
                      LocalKeys.orders,
                      SvgAssets.list,
                      SvgAssets.list,
                      1,
                      ov,
                    ),
                    navBarItem(
                      context,
                      LocalKeys.store,
                      SvgAssets.store,
                      SvgAssets.storeBold,
                      2,
                      ov,
                    ),
                    navBarItem(
                      context,
                      LocalKeys.myCar,
                      SvgAssets.car,
                      SvgAssets.carBold,
                      3,
                      ov,
                    ),
                    navBarItem(
                      context,
                      LocalKeys.profile,
                      SvgAssets.user,
                      SvgAssets.userBold,
                      4,
                      ov,
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  navBarItem(
    BuildContext context,
    String label,
    String iconNormal,
    String iconBold,
    int index,
    ov, {
    badgeCount = 0,
  }) {
    final selected = index == ov.currentIndex.value;
    return InkWell(
      onTap: () {
        HomeViewModel.instance.appBarSize.value = 0;
        ov.setContext(context);
        ov.setNavIndex(index);
        if (index == 2) {
          FilterViewModel.dispose;
          final ss = Provider.of<ServicesSearchService>(context, listen: false);
          ss.resetFilters();
          ss.setSearchTitle("");
        }
        if (index == 0) {
          FilterViewModel.dispose;
        }
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
                  color:
                      selected
                          ? primaryColor
                          : context.color.secondaryContrastColor,
                ),
              ),
            ),
            8.toHeight,
            Text(
              label,
              style:
                  context.bodySmall
                      ?.copyWith(
                        color:
                            selected
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
