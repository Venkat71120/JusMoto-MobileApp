import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/landding_view_model/landding_view_model.dart';
import 'package:car_service/views/support_ticket_view/support_ticket_view.dart';
import 'package:flutter/material.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final lvm = LandingViewModel.instance;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.toHeight,
        FieldLabel(label: "Quick Actions").hp20,
        12.toHeight,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionItem(
              icon: SvgAssets.calendar,
              label: LocalKeys.bookService,
              onTap: () => lvm.setNavIndex(2),
            ),
            _QuickActionItem(
              icon: SvgAssets.list,
              label: LocalKeys.orders,
              onTap: () => lvm.setNavIndex(1),
            ),
            // _QuickActionItem(
            //   icon: SvgAssets.search,
            //   label: "Traffic Challan",
            //   onTap: () {
            //     final fvm = FilterViewModel.instance;
            //     fvm.searchController.text = "Challan";
            //     Provider.of<ServicesSearchService>(context, listen: false)
            //         .setSearchTitle("Challan");
            //     lvm.setNavIndex(2);
            //   },
            // ),
            _QuickActionItem(
              icon: SvgAssets.car,
              label: LocalKeys.myCar,
              onTap: () => lvm.setNavIndex(3),
            ),
            _QuickActionItem(
              icon: SvgAssets.ticket,
              label: "Support",
              onTap: () => context.toPage(const SupportTicketView()),
            ),
          ],
        ).hp20,
        12.toHeight,
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SquircleContainer(
            height: 60,
            width: 60,
            radius: 16,
            color: context.color.accentContrastColor,
            borderColor: context.color.primaryBorderColor,
            child: Center(
              child: icon.toSVGSized(
                28,
                color: primaryColor,
              ),
            ),
          ),
          8.toHeight,
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.color.secondaryContrastColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
