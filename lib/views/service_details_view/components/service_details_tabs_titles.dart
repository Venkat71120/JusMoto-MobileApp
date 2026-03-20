import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/service/service_details_model.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:flutter/material.dart';

class ServiceDetailsTabsTitles extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  const ServiceDetailsTabsTitles({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    final sdm = ServiceDetailsViewModel.instance;
    return ValueListenableBuilder(
      valueListenable: sdm.selectedTab,
      builder: (context, tab, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.color.mutedContrastColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: ((serviceDetails.relatedServices ?? []).isNotEmpty
                    ? sdm.sectionKeys
                    : sdm.sectionKeysWithoutRS)
                .keys
                .map((e) {
              final isSelected = e == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isSelected) return;
                    sdm.scrollToSection(e);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.color.accentContrastColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        e,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: context.bodySmall?.copyWith(
                          color: isSelected
                              ? primaryColor
                              : context.color.tertiaryContrastColo,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class SliverHeaderDelegateComponent extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  const SliverHeaderDelegateComponent({required this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final sdm = ServiceDetailsViewModel.instance;
    final appBarSize = expandedHeight - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SizedBox(
        height: expandedHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder(
              valueListenable: sdm.selectedTab,
              builder: (context, tab, child) {
                return Container(
                  margin: 24.paddingH,
                  color: context.color.accentContrastColor,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: context.color.primaryBorderColor))),
                  child: Row(
                    children: ServiceDetailsTabsTypes.values.map((e) {
                      final isSelected = e == tab;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 4,
                        ))),
                        child: Text(
                          serviceDetailsTabs.reverse[e] ?? "---",
                          style: context.titleSmall?.copyWith(
                              color: isSelected ? primaryColor : null),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            PositionedDirectional(
              start: 0.0,
              end: 0.0,
              top: appBarSize > 0 ? appBarSize : 0,
              bottom: -100,
              child: Opacity(
                opacity: percent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30 * percent),
                  child: const Card(
                    elevation: 20.0,
                    child: Center(
                      child: Text("Widget"),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
