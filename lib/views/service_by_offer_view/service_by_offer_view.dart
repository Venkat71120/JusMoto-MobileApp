import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/view_models/service_offer_view_model/service_offer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/svg_assets.dart';
import '../../services/service/service_by_offer_service.dart';
import '../../utils/components/empty_widget.dart';
import '../service_result_view/components/service_result_skeleton.dart';
import '../service_result_view/components/service_tile.dart';
import '../service_result_view/service_list_map_view.dart';

class ServiceByOfferView extends StatelessWidget {
  final dynamic offerId;
  final String? catName;

  const ServiceByOfferView({super.key, required this.offerId, this.catName});

  @override
  Widget build(BuildContext context) {
    final srm = ServiceOfferViewModel.instance;
    final ssProvider = Provider.of<ServiceByOfferService>(
      context,
      listen: false,
    );
    srm.scrollController.addListener(() {
      srm.tryToLoadMore(context);
    });
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        actions: [
          Consumer<ServiceByOfferService>(
            builder: (context, ss, child) {
              if (ss.serviceByOfferModel.allServices.isEmpty) {
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: SvgAssets.map.toSVGSized(
                    22,
                    color: context.color.secondaryContrastColor,
                  ),
                  onPressed: () {
                    context.toPage(
                      ServiceListMapView(
                        serviceList: ss.serviceByOfferModel.allServices,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: context.color.accentContrastColor,
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await ssProvider.fetchServices(refreshing: true, offerId: offerId);
        },
        child: Consumer<ServiceByOfferService>(
          builder: (context, sc, child) {
            return CustomFutureWidget(
              function:
                  sc.shouldAutoFetch(offerId)
                      ? sc.fetchServices(offerId: offerId)
                      : null,
              shimmer: const ServiceResultSkeleton(),
              child: Scrollbar(
                controller: srm.scrollController,
                child: CustomScrollView(
                  controller: srm.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (sc.serviceByOfferModel.allServices.isEmpty)
                      SizedBox(
                        height: context.height * .8,
                        child: EmptyWidget(title: LocalKeys.serviceNotFound),
                      ).toSliver,
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        final service =
                            sc.serviceByOfferModel.allServices[index];
                        return ServiceTile(service: service);
                      },
                      separatorBuilder:
                          (context, index) =>
                              Divider(
                                color: context.color.primaryBorderColor,
                                height: 2,
                              ).hp20,
                      itemCount: sc.serviceByOfferModel.allServices.length,
                    ),
                    if (sc.nextPage != null && !sc.nexLoadingFailed)
                      SliverList.list(
                        children: const [ScrollPreloader(loading: false)],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
