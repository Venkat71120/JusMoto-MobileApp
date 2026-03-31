import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/view_models/Admin_landing_view_model/AdminLandingViewModel.dart';
import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '../../../helper/svg_assets.dart';

class AdminLandingNavBar extends StatelessWidget {
  const AdminLandingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final avm = AdminLandingViewModel.instance;
    return ValueListenableBuilder(
      valueListenable: avm.currentIndex,
      builder: (context, value, child) => Container(
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
        ),
        height: 78,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBarItem(context, 'Home', SvgAssets.home, SvgAssets.homeBold, 0, avm),
            _navBarItem(context, 'Orders', SvgAssets.list, SvgAssets.list, 1, avm),
            _navBarItem(context, 'Tickets', SvgAssets.ticket, SvgAssets.ticket, 2, avm),
            _navBarItem(context, 'Users', SvgAssets.user, SvgAssets.userBold, 3, avm),
            _navBarItem(context, 'Profile', SvgAssets.user, SvgAssets.userBold, 4, avm),
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
    AdminLandingViewModel avm,
  ) {
    final selected = index == avm.currentIndex.value;
    return InkWell(
      onTap: () {
        avm.setContext(context);
        avm.setNavIndex(index);
      },
      child: SquircleContainer(
        alignment: Alignment.center,
        color: Colors.transparent,
        radius: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (selected ? iconBold : iconNormal).toSVGSized(
              24,
              color: selected
                  ? primaryColor
                  : context.color.secondaryContrastColor,
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
