import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/local_keys.g.dart';
import '../services/order_services/refund_manage_service.dart';
import '../utils/components/custom_future_widget.dart';
import '../utils/components/custom_preloader.dart';
import '../utils/components/custom_refresh_indicator.dart';
import '../utils/components/empty_widget.dart';
import '../view_models/refund_list_view_model/refund_list_view_model.dart';
import 'components/refund_details_basic_info.dart';

class RefundDetailsView extends StatelessWidget {
  final dynamic refundId;
  const RefundDetailsView({super.key, required this.refundId});

  @override
  Widget build(BuildContext context) {
    final rmProvider = Provider.of<RefundManageService>(context, listen: false);
    final rlm = RefundListViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: NavigationPopIcon(backgroundColor: Colors.transparent),
      ),
      body: CustomRefreshIndicator(
        refreshKey: rlm.refreshKey,
        onRefresh: () async {
          await rmProvider.fetchRefundDetails(id: refundId);
        },
        child: Scrollbar(
          controller: rlm.dScrollController,
          child: CustomFutureWidget(
            function:
                rmProvider.shouldAutoFetch(refundId)
                    ? rmProvider.fetchRefundDetails(id: refundId)
                    : null,
            shimmer: const CustomPreloader(),
            child: Consumer<RefundManageService>(
              builder: (context, rm, child) {
                if (rm.refundDetailsModel.refundDetails == null) {
                  return EmptyWidget(title: LocalKeys.na);
                } else {
                  final refundDetails = rm.refundDetailsModel.refundDetails!;
                  return CustomScrollView(
                    controller: rlm.dScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      RefundDetailsBasicInfo(
                        refundDetails: refundDetails,
                      ).toSliver,
                      12.toHeight.toSliver,
                      // RefundDetailsPaymentInfo(refundDetails: refundDetails)
                      //     .toSliver
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
