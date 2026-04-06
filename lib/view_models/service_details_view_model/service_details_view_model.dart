import 'package:flutter/material.dart';
import '../../models/car_models/brand_list_model.dart';
import '../../helper/local_keys.g.dart';
import '../order_list_view_model/order_status_enums.dart';

class ServiceDetailsViewModel {
  ScrollController scrollController = ScrollController();

  final ValueNotifier<bool> showTabs = ValueNotifier(false);

  ValueNotifier<String> selectedTab = ValueNotifier(LocalKeys.overview);
  ValueNotifier selectedFAQ = ValueNotifier(null);
  final ValueNotifier<bool> showVideo = ValueNotifier(true);
  final ValueNotifier<BrandModel?> selectedBrand = ValueNotifier(null);

  ServiceDetailsViewModel._init();
  static ServiceDetailsViewModel? _instance;
  static ServiceDetailsViewModel get instance {
    _instance ??= ServiceDetailsViewModel._init();
    return _instance!;
  }

  ServiceDetailsViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void scrollToSection(String tab) {
    final keyContext = sectionKeys[tab]!.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      selectedTab.value = tab;
    }
  }

  void onScroll(BuildContext context) {
    try {
      double screenHeight = MediaQuery.of(context).size.height;
      double scrollOffset = scrollController.offset;

      String newSelectedTab = "";
      double minOffsetDifference = double.infinity;

      for (var entry in sectionKeys.entries) {
        final keyContext = entry.value.currentContext;
        if (keyContext != null) {
          final renderBox = keyContext.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero).dy;

          double sectionHeight = renderBox.size.height;
          double bottomPosition = position + sectionHeight;

          // Check if section is fully visible
          bool fullyVisible = position >= 0 && bottomPosition <= screenHeight;

          if (fullyVisible) {
            newSelectedTab = entry.key;
            break; // Prioritise fully visible sections
          }

          // Find closest section to top
          double offsetDifference = (position - 0).abs();
          if (offsetDifference < minOffsetDifference) {
            minOffsetDifference = offsetDifference;
            newSelectedTab = entry.key;
          }
        }
      }

      // Update only if it actually changes
      if (selectedTab.value != newSelectedTab) {
        selectedTab.value = newSelectedTab;
      }
    } catch (e) {}
  }

  final sectionKeys = {
    LocalKeys.overview: GlobalKey(debugLabel: LocalKeys.overview),
    LocalKeys.reviews: GlobalKey(debugLabel: LocalKeys.reviews),
    LocalKeys.faq: GlobalKey(debugLabel: LocalKeys.faq),
    LocalKeys.relatedServices: GlobalKey(debugLabel: LocalKeys.relatedServices),
  };
  final sectionKeysWithoutRS = {
    LocalKeys.overview: GlobalKey(debugLabel: LocalKeys.overview),
    LocalKeys.reviews: GlobalKey(debugLabel: LocalKeys.reviews),
    LocalKeys.faq: GlobalKey(debugLabel: LocalKeys.faq),
  };
  bool alreadyScrolling = false;
  void listenToScroll(BuildContext context) {
    if (alreadyScrolling) return;
    scrollController.addListener(() {
      alreadyScrolling = true;
      onScroll(context);
    });
  }
}

enum ServiceDetailsTabsTypes { overview, faq, reviews, addons, staffs }

EnumValues get serviceDetailsTabs => EnumValues({
  LocalKeys.overview: ServiceDetailsTabsTypes.overview,
  LocalKeys.faq: ServiceDetailsTabsTypes.faq,
  LocalKeys.addons: ServiceDetailsTabsTypes.addons,
  LocalKeys.reviews: ServiceDetailsTabsTypes.reviews,
  LocalKeys.staffs: ServiceDetailsTabsTypes.staffs,
});
