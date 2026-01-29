import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/order_models/order_response_model.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/views/submit_review_view/submit_review_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/home_services/service_details_service.dart';
import '../../../utils/components/custom_network_image.dart';
import '../../../view_models/service_details_view_model/service_details_view_model.dart';
import '../../../view_models/submit_review_view_model/submit_review_view_model.dart';
import '../../service_details_view/service_details_view.dart';

class OrderDetailsItemTile extends StatelessWidget {
  final OrderItem orderItem;
  const OrderDetailsItemTile({super.key, required this.orderItem});

  @override
  Widget build(BuildContext context) {
    final odProvider = Provider.of<OrderDetailsService>(context, listen: false);
    return GestureDetector(
      onTap: () {
        final sdm = ServiceDetailsViewModel.instance;
        sdm.selectedTab.value = LocalKeys.overview;
        sdm.scrollController.addListener(() => sdm.onScroll(context));
        context.toPage(
          ServiceDetailsView(id: orderItem.serviceId),
          then: (_) {
            Provider.of<ServiceDetailsService>(
              context,
              listen: false,
            ).remove(orderItem.serviceId);
            ServiceDetailsViewModel.instance.selectedTab.value =
                LocalKeys.overview;
          },
        );
      },
      child: SquircleContainer(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(8),
        color: context.color.accentContrastColor,
        radius: 8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomNetworkImage(
              height: 72,
              width: 100,
              radius: 6,
              fit: BoxFit.cover,
              imageUrl: orderItem.image,
            ),
            12.toWidth,
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderItem.itemTitle ?? "---",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.titleMedium?.bold,
                  ),
                  4.toHeight,
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: RichText(
                          text: TextSpan(
                            text: null,
                            style: context.titleSmall?.bold,
                            children: [
                              TextSpan(
                                text:
                                    " ${LocalKeys.quantity}: ${(orderItem.qty)}",
                                style: context.titleSmall?.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "",
                          style: context.titleSmall?.bold,
                          children: [
                            TextSpan(
                              text: (orderItem.price * orderItem.qty).cur,
                              style: context.titleSmall?.bold.copyWith(
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if ((orderItem.reviewsAll?.isEmpty ?? true) &&
                      ["2", "complete"].contains(
                        odProvider.orderDetailsModel.orderDetails?.status
                            .toString(),
                      ))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            SubmitReviewViewModel.dispose;
                            final srm = SubmitReviewViewModel.instance;
                            srm.orderItemNotifier.value = orderItem;
                            context.toPage(
                              SubmitReviewView(orderItem: orderItem),
                            );
                          },
                          child: Text(
                            LocalKeys.submitReview,
                            style: context.titleSmall?.bold.copyWith(
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
