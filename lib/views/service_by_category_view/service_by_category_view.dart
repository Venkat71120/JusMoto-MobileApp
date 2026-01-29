import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/view_models/service_result_view_model/service_result_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/service/service_by_category_service.dart';
import '../../utils/components/empty_widget.dart';
import '../../utils/service_card/service_card.dart';
import '../home_view/components/service_card_skeleton.dart';

class ServiceByCategoryView extends StatelessWidget {
  final dynamic catId;
  final String? catName;

  const ServiceByCategoryView({super.key, required this.catId, this.catName});

  @override
  Widget build(BuildContext context) {
    final srm = ServiceResultViewModel.instance;
    final ssProvider = Provider.of<ServiceByCategoryService>(
      context,
      listen: false,
    );
    srm.scrollController.addListener(() {
      srm.tryToLoadMore(context);
    });
    return Scaffold(
      appBar: AppBar(leading: const NavigationPopIcon()),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await ssProvider.fetchServices(refreshing: true, catId: catId);
        },
        child: Consumer<ServiceByCategoryService>(
          builder: (context, sc, child) {
            return CustomFutureWidget(
              function:
                  sc.shouldAutoFetch(catId)
                      ? sc.fetchServices(catId: catId)
                      : null,
              shimmer:
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(
                        8,
                        (index) => ServiceCardSkeleton(
                          width: (context.width - 46) / 2,
                        ),
                      ),
                    ),
                  ).shim,
              child: Scrollbar(
                controller: srm.scrollController,
                child: CustomScrollView(
                  controller: srm.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (sc.serviceByCategoryModel.allServices.isEmpty)
                      SizedBox(
                        height: context.height * .8,
                        child: EmptyWidget(title: LocalKeys.serviceNotFound),
                      ).toSliver,
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        final leftIndex = index * 2;
                        final rightIndex = leftIndex + 1;
                        final services = sc.serviceByCategoryModel.allServices;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                rightIndex < services.length
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                            children: [
                              if (leftIndex < services.length)
                                SizedBox(
                                  width: (context.width - 46) / 2,
                                  child: ServiceCard(
                                    service: services[leftIndex],
                                  ),
                                ),
                              const SizedBox(width: 12),
                              if (rightIndex < services.length)
                                SizedBox(
                                  width: (context.width - 46) / 2,
                                  child: ServiceCard(
                                    service: services[rightIndex],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => 12.toHeight,
                      itemCount:
                          (sc.serviceByCategoryModel.allServices.length / 2)
                              .ceil(),
                    ),
                    if (sc.nextPage != null && !sc.nexLoadingFailed)
                      ScrollPreloader(loading: sc.nextPageLoading).toSliver,
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
