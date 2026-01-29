import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/refund_list_view_model/refund_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/order_services/refund_list_service.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/custom_refresh_indicator.dart';
import '../../utils/components/empty_widget.dart';
import '../../utils/components/scrolling_preloader.dart';
import 'components/refund_list_tile.dart';

class RefundListView extends StatelessWidget {
  const RefundListView({super.key});

  @override
  Widget build(BuildContext context) {
    final rmProvider = Provider.of<RefundListService>(context, listen: false);
    final rlm = RefundListViewModel.instance;
    rlm.scrollController.addListener(() {
      rlm.tryToLoadMore(context);
    });
    return Scaffold(
      appBar: AppBar(
        leading: NavigationPopIcon(backgroundColor: Colors.transparent),
        title: Text(LocalKeys.refunds),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await rmProvider.fetchRefundList();
        },
        child: Scrollbar(
          controller: rlm.scrollController,
          child: CustomFutureWidget(
            function: rmProvider.shouldAutoFetch
                ? rmProvider.fetchRefundList()
                : null,
            shimmer: const CustomPreloader(),
            child: Consumer<RefundListService>(builder: (context, nl, child) {
              return (nl.notificationListModel.clientAllRefundList ?? [])
                      .isEmpty
                  ? EmptyWidget(title: LocalKeys.na)
                  : CustomScrollView(
                      controller: rlm.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverList.separated(
                          itemBuilder: (context, index) {
                            final refundModel = nl.notificationListModel
                                .clientAllRefundList![index];
                            return RefundListTile(refundModel: refundModel);
                          },
                          separatorBuilder: (context, index) => 12.toHeight,
                          itemCount: nl.notificationListModel
                              .clientAllRefundList!.length,
                        ),
                        16.toHeight.toSliver,
                        if (nl.nextPage != null && !nl.nexLoadingFailed)
                          ScrollPreloader(loading: nl.nextPageLoading).toSliver,
                        16.toHeight.toSliver,
                      ],
                    );
            }),
          ),
        ),
      ),
    );
  }
}
