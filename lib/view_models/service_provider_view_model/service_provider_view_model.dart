import 'package:flutter/material.dart';

import '../../helper/local_keys.g.dart';
import '../order_list_view_model/order_status_enums.dart';

class ServiceProviderViewModel {
  ScrollController scrollController = ScrollController();

  ValueNotifier<ServiceProviderTabsTypes> selectedTab =
      ValueNotifier(ServiceProviderTabsTypes.about);
  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  ValueNotifier selectedFAQ = ValueNotifier(null);

  ServiceProviderViewModel._init();
  static ServiceProviderViewModel? _instance;
  static ServiceProviderViewModel get instance {
    _instance ??= ServiceProviderViewModel._init();
    return _instance!;
  }

  ServiceProviderViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }
}

enum ServiceProviderTabsTypes { about, services, reviews }

final serviceProviderTabs = EnumValues({
  LocalKeys.about: ServiceProviderTabsTypes.about,
  LocalKeys.services: ServiceProviderTabsTypes.services,
  LocalKeys.reviews: ServiceProviderTabsTypes.reviews,
});
