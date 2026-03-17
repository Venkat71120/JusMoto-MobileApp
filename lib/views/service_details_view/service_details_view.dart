import 'dart:io';

import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/services/booking_services/booking_addons_service.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:car_service/views/cart_view/cart_view.dart';
import 'package:car_service/views/service_details_view/components/related_service_list.dart';
import 'package:car_service/views/service_details_view/components/service_details_faq_tab.dart';
import 'package:car_service/views/service_details_view/components/service_details_review_tab.dart';
import 'package:car_service/views/service_details_view/components/service_details_security.dart';
import 'package:car_service/views/service_details_view/components/service_details_tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../services/home_services/service_details_service.dart';
import '../../utils/components/custom_button.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../utils/components/custom_refresh_indicator.dart';
import '../../view_models/service_booking_view_model/service_booking_view_model.dart';
import 'components/service_details_basics.dart';
import 'components/service_details_cancellation_policy.dart';
import 'components/service_details_favorite_Icon.dart';
import 'components/service_details_images.dart';
import 'components/service_details_skeleton.dart';
import 'components/service_details_tabs_titles.dart';

class ServiceDetailsView extends StatelessWidget {
  final dynamic id;
  const ServiceDetailsView({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    final sdProvider = Provider.of<ServiceDetailsService>(
      context,
      listen: false,
    );
    final sdm = ServiceDetailsViewModel.instance;
    sdm.listenToScroll(context);
    return Scaffold(
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await sdProvider.fetchServiceDetails(id);
        },
        child: CustomFutureWidget(
          function:
              sdProvider.shouldAutoFetch(id)
                  ? sdProvider.fetchServiceDetails(id)
                  : null,
          shimmer: const ServiceDetailsSkeleton(),
          child: Consumer<ServiceDetailsService>(
            builder: (context, sd, child) {
              final serviceDetails = sd.serviceDetailsModel(id);
              if (serviceDetails.allServices == null) {
                return Scaffold(
                  appBar: AppBar(
                    leading: NavigationPopIcon(
                      backgroundColor: context.color.accentContrastColor,
                    ),
                    backgroundColor: context.color.backgroundColor,
                  ),
                  body: EmptyWidget(
                    title: LocalKeys.serviceNotFound,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                );
              }
              return CustomScrollView(
                controller: sdm.scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: color.backgroundColor,
                    surfaceTintColor: color.backgroundColor,
                    pinned: true,
                    titleSpacing: 0,
                    leading: NavigationPopIcon(
                      backgroundColor: context.color.accentContrastColor,
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ServiceDetailsFavoriteIcon(id: id),
                      ),
                    ],
                    expandedHeight: 250,
                    flexibleSpace: ServiceDetailsImages(
                      serviceDetails: sd.serviceDetailsModel(id),
                    ),
                  ),
                  ServiceDetailsBasics(
                    serviceDetails: sd.serviceDetailsModel(id),
                    id: id,
                  ).toSliver,
                  8.toHeight.toSliver,
                  SliverAppBar(
                    titleSpacing: 0,
                    pinned: true,
                    primary: false,
                    leadingWidth: 0,
                    backgroundColor: context.color.accentContrastColor,
                    leading: SizedBox(),
                    title: ServiceDetailsTabsTitles(
                      serviceDetails: sd.serviceDetailsModel(id),
                    ),
                    flexibleSpace: SizedBox(),
                  ),
                  ServiceDetailsTabs(
                    key: sdm.sectionKeys[LocalKeys.overview],
                    serviceDetails: sd.serviceDetailsModel(id),
                  ).toSliver,
                  16.toHeight.toSliver,
                  ServiceDetailsReviewTab(
                    key: sdm.sectionKeys[LocalKeys.reviews],
                    serviceDetails: sd.serviceDetailsModel(id),
                  ).toSliver,
                  16.toHeight.toSliver,
                  if (serviceDetails
                          .allServices
                          ?.admin
                          ?.serviceArea
                          ?.latitude !=
                      null) ...[
                    16.toHeight.toSliver,
                  ],
                  ServiceDetailsFaqTab(
                    key: sdm.sectionKeys[LocalKeys.faq],
                    serviceDetails: sd.serviceDetailsModel(id),
                  ).toSliver,
                  if ((sd.serviceDetailsModel(id).relatedServices ?? [])
                      .isNotEmpty) ...[
                    16.toHeight.toSliver,
                    RelatedServiceList(
                      key: sdm.sectionKeys[LocalKeys.relatedServices],
                      relatedServices:
                          sd.serviceDetailsModel(id).relatedServices!,
                    ).toSliver,
                  ],
                  if (1 == 2) ...[
                    8.toHeight.toSliver,
                    const ServiceDetailsSecurity().toSliver,
                    8.toHeight.toSliver,
                    const ServiceDetailsCancellationPolicy().toSliver,
                  ],
                  92.toHeight.toSliver,
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<CartService>(
        builder: (context, cs, child) {
          return Consumer<ServiceDetailsService>(
            builder: (context, sd, child) {
              return sd.serviceDetailsModel(id).allServices == null
                  ? const SizedBox()
                  : Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: Platform.isIOS ? 0 : 16,
                    ),
                    child: Row(
                      children: [
                        if (1 == 2)
                          Expanded(
                            flex: 1,
                            child: CustomButton(
                              onPressed: () {
                                ServiceBookingViewModel.dispose;
                                final svm = ServiceBookingViewModel.instance;
                                svm.selectedService.value =
                                    sd.serviceDetailsModel(id).allServices!;
                                Provider.of<BookingAddonsService>(
                                  context,
                                  listen: false,
                                ).reset();
                              },
                              btText:
                                  cs.cartList.containsKey(id.toString())
                                      ? LocalKeys.viewCart
                                      : LocalKeys.addToCart,
                            ),
                          ),
                        Expanded(
                          flex: 1,
                          child: Consumer<CartService>(
                            builder: (context, cartService, child) {
                              final isAdded = cartService.cartList.containsKey(
                                id.toString(),
                              );
                              if (isAdded) {
                                return CustomButton(
                                  onPressed: () {
                                    context.toPage(CartView());
                                  },
                                  btText: LocalKeys.added,
                                  backgroundColor: context.color.accentContrastColor,
                                  foregroundColor: context.color.primaryContrastColor,
                                  borderColor: context.color.primaryBorderColor,
                                );
                              }
                              return CustomButton(
                                onPressed: () {
                                  cartService.addToCart(
                                    id.toString(),
                                    sd
                                        .serviceDetailsModel(id)
                                        .allServices!
                                        .toMinimizedJson(),
                                  );
                                },
                                btText: LocalKeys.addToCart,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
            },
          );
        },
      ),
    );
  }
}
