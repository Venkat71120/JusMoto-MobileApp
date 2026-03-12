import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/service/services_search_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/view_models/product_list_view_model/product_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/components/empty_widget.dart';
import '../../utils/service_card/service_card.dart';
import '../../view_models/filter_view_model/filter_view_model.dart';
import '../home_view/components/app_bar_cart.dart';
import '../home_view/components/service_card_skeleton.dart';
import '../service_result_view/components/service_result_skeleton.dart';
import 'components/product_search_bar.dart';

class ProductsListView extends StatelessWidget {
  static const routeName = "service_result_view";
  const ProductsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final plm = ProductListViewModel.instance;
    final fvm = FilterViewModel.instance;
    final ssProvider = Provider.of<ServicesSearchService>(
      context,
      listen: false,
    );
    plm.scrollController.addListener(() {
      plm.tryToLoadMore(context);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalKeys.store),
        actions: [12.toWidth, const AppBarCart(), 20.toWidth],
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await ssProvider.fetchHomeFeaturedServices(refreshing: true);
        },
        child: Consumer<ServicesSearchService>(
          builder: (context, ss, child) {
            return Scrollbar(
              controller: plm.scrollController,
              child: CustomFutureWidget(
                function:
                    ss.shouldAutoFetch ? ss.fetchHomeFeaturedServices() : null,
                isLoading: ss.isLoading,
                shimmer: const ServiceResultSkeleton(),
                child: CustomScrollView(
                  controller: plm.scrollController,
                  physics:
                      ss.isLoading
                          ? const NeverScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),

                  slivers: [
                    const SliverAppBar(
                      floating: true,
                      snap: true,
                      leadingWidth: 0,
                      leading: SizedBox(),
                      title: ProductSearchBar(),
                    ),
                    if (ss.isLoading && ss.searchResultModel.allServices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child:
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: List.generate(
                                8,
                                (index) => ServiceCardSkeleton(
                                  width: (context.width - 46) / 2,
                                ),
                              ),
                            ).shim,
                      ).toSliver,
                    if (ss.searchResultModel.allServices.isEmpty)
                      SizedBox(
                        height: context.height * .8,
                        child: EmptyWidget(title: LocalKeys.serviceNotFound),
                      ).toSliver,
                    if (ss.searchResultModel.allServices.isNotEmpty)
                      SliverList.separated(
                        itemBuilder: (context, index) {
                          final leftIndex = index * 2;
                          final rightIndex = leftIndex + 1;
                          final services = ss.searchResultModel.allServices;
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
                            (ss.searchResultModel.allServices.length / 2)
                                .ceil(),
                      ),
                    if (ss.nextPage != null &&
                        !ss.nexLoadingFailed &&
                        !ss.isLoading)
                      ScrollPreloader(loading: ss.nextPageLoading).toSliver,
                    16.toHeight.toSliver,
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
