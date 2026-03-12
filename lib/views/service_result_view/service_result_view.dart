import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/service/services_search_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/view_models/service_result_view_model/service_result_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/components/empty_widget.dart';
import 'components/service_result_search_bar.dart';
import 'components/service_result_skeleton.dart';
import 'components/service_tile.dart';

class ServiceResultView extends StatelessWidget {
  static const routeName = "service_result_view";
  const ServiceResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final srm = ServiceResultViewModel.instance;
    final ssProvider =
        Provider.of<ServicesSearchService>(context, listen: false);
    srm.scrollController.addListener(() {
      srm.tryToLoadMore(context);
    });
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.results),
      ),
      backgroundColor: context.color.accentContrastColor,
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await ssProvider.fetchHomeFeaturedServices(refreshing: true);
        },
        child: Consumer<ServicesSearchService>(builder: (context, ss, child) {
          return Scrollbar(
            controller: srm.scrollController,
            child: CustomScrollView(
              controller: srm.scrollController,
              physics: ss.isLoading
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverAppBar(
                  floating: true,
                  snap: true,
                  leadingWidth: 0,
                  leading: SizedBox(),
                  title: ResultViwSearchBar(),
                ),
                if (ss.isLoading && ss.searchResultModel.allServices.isEmpty)
                  const ServiceResultSkeleton().toSliver,
                if (ss.searchResultModel.allServices.isEmpty)
                  SizedBox(
                          height: context.height * .8,
                          child: EmptyWidget(title: LocalKeys.serviceNotFound))
                      .toSliver,
                if (ss.searchResultModel.allServices.isNotEmpty)
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      final service = ss.searchResultModel.allServices[index];
                      return ServiceTile(service: service);
                    },
                    separatorBuilder: (context, index) => Divider(
                      color: context.color.primaryBorderColor,
                      height: 2,
                    ).hp20,
                    itemCount: ss.searchResultModel.allServices.length,
                  ),
                if (ss.nextPage != null &&
                    !ss.nexLoadingFailed &&
                    !ss.isLoading)
                  SliverList.list(children: const [
                    ScrollPreloader(
                      loading: false,
                    ),
                  ]),
              ],
            ),
          );
        }),
      ),
    );
  }
}
