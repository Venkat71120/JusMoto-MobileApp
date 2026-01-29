import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/home_models/services_list_model.dart';
import 'package:car_service/services/service/favorite_services_service.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/components/custom_refresh_indicator.dart';
import '../../utils/service_card/service_card.dart';

class FavoriteServicesView extends StatelessWidget {
  const FavoriteServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.favoriteServices),
      ),
      body: Consumer<FavoriteServicesService>(builder: (context, fj, child) {
        return CustomRefreshIndicator(
          onRefresh: () async {},
          child: fj.favoriteList.isEmpty
              ? EmptyWidget(title: LocalKeys.noFavoritesFound)
              : Scrollbar(
                  child: CustomScrollView(
                  slivers: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: fj.favoriteList.values
                            .map((service) => SizedBox(
                                width: (context.width - 46) / 2,
                                child: FittedBox(
                                    child: ServiceCard(
                                        service:
                                            ServiceModel.fromJson(service)))))
                            .toList(),
                      ),
                    ).toSliver,
                  ],
                )),
        );
      }),
    );
  }
}
