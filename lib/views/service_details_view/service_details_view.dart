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

import '../../customizations/colors.dart';
import '../../helper/local_keys.g.dart';
import '../../services/home_services/service_details_service.dart';
import '../../utils/components/custom_button.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../utils/components/custom_refresh_indicator.dart';
import '../../view_models/service_booking_view_model/service_booking_view_model.dart';
import 'components/service_details_brand_selection.dart';
import 'components/service_details_basics.dart';
import 'components/service_details_cancellation_policy.dart';
import 'components/service_details_favorite_Icon.dart';
import 'components/service_details_images.dart';
import 'components/service_details_skeleton.dart';
import 'components/service_details_tabs_titles.dart';
import '../create_ticekt_view/create_ticket_view.dart';
import '../../view_models/create_ticket_view_model/create_ticket_view_model.dart';

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
      backgroundColor: context.color.backgroundColor,
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
                    expandedHeight: 300,
                    flexibleSpace: ServiceDetailsImages(
                      serviceDetails: sd.serviceDetailsModel(id),
                    ),
                  ),
                  ServiceDetailsBasics(
                    serviceDetails: sd.serviceDetailsModel(id),
                    id: id,
                  ).toSliver,
                  16.toHeight.toSliver,
                  const ServiceDetailsBrandSelection().toSliver,
                  SliverToBoxAdapter(
                    child: Container(
                      height: 12,
                      color: context.color.backgroundColor,
                    ),
                  ),
                  SliverAppBar(
                    titleSpacing: 0,
                    pinned: true,
                    primary: false,
                    leadingWidth: 0,
                    toolbarHeight: 56,
                    backgroundColor: context.color.backgroundColor,
                    leading: SizedBox(),
                    title: ServiceDetailsTabsTitles(
                      serviceDetails: sd.serviceDetailsModel(id),
                    ),
                    flexibleSpace: SizedBox(),
                  ),
                  SliverToBoxAdapter(
                    child: Container(height: 8),
                  ),
                  // Overview section in card
                  SliverToBoxAdapter(
                    child: Container(
                      key: sdm.sectionKeys[LocalKeys.overview],
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.color.accentContrastColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ServiceDetailsTabs(
                        serviceDetails: sd.serviceDetailsModel(id),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: 16.toHeight),
                  // Reviews section in card
                  SliverToBoxAdapter(
                    child: Container(
                      key: sdm.sectionKeys[LocalKeys.reviews],
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: context.color.accentContrastColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ServiceDetailsReviewTab(
                        serviceDetails: sd.serviceDetailsModel(id),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: 16.toHeight),
                  if (serviceDetails
                          .allServices
                          ?.admin
                          ?.serviceArea
                          ?.latitude !=
                      null) ...[
                    SliverToBoxAdapter(child: 8.toHeight),
                  ],
                  // FAQ section in card
                  SliverToBoxAdapter(
                    child: Container(
                      key: sdm.sectionKeys[LocalKeys.faq],
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: context.color.accentContrastColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ServiceDetailsFaqTab(
                        serviceDetails: sd.serviceDetailsModel(id),
                      ),
                    ),
                  ),
                  if ((sd.serviceDetailsModel(id).relatedServices ?? [])
                      .isNotEmpty) ...[
                    SliverToBoxAdapter(child: 16.toHeight),
                    SliverToBoxAdapter(
                      child: Container(
                        key: sdm.sectionKeys[LocalKeys.relatedServices],
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: context.color.accentContrastColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: RelatedServiceList(
                          relatedServices:
                              sd.serviceDetailsModel(id).relatedServices!,
                        ),
                      ),
                    ),
                  ],
                  if (1 == 2) ...[
                    8.toHeight.toSliver,
                    const ServiceDetailsSecurity().toSliver,
                    8.toHeight.toSliver,
                    const ServiceDetailsCancellationPolicy().toSliver,
                  ],
                  SliverToBoxAdapter(child: 110.toHeight),
                ],
              );
            },
          ),
        ),
      ),
      // Bottom add to cart button
      bottomNavigationBar: Consumer<CartService>(
        builder: (context, cartService, child) {
          return Consumer<ServiceDetailsService>(
            builder: (context, sd, child) {
              if (sd.serviceDetailsModel(id).allServices == null) {
                return const SizedBox.shrink();
              }
              final isAdded =
                  cartService.cartList.containsKey(id.toString());
              return Container(
                padding: EdgeInsets.fromLTRB(
                    20, 10, 20, Platform.isIOS ? 26 : 14),
                color: context.color.accentContrastColor,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            if (sdm.selectedBrand.value == null) {
                              "Please select a brand first".showToast();
                              return;
                            }
                            final serviceName = sd.serviceDetailsModel(id).allServices?.title ?? "Service";
                            final brandName = sdm.selectedBrand.value?.name ?? "Unknown Brand";
                            
                            final ctm = CreateTicketViewModel.instance;
                            ctm.titleController.text = "Quote Request: $serviceName";
                            ctm.descriptionController.text = "I would like to get a quote for $serviceName for my $brandName vehicle.";
                            
                            context.toPage(const CreateTicketView());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.color.secondaryContrastColor,
                            foregroundColor: context.color.accentContrastColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Get Quote",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    12.toWidth,
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: isAdded
                            ? ElevatedButton.icon(
                                onPressed: () =>
                                    context.toPage(CartView()),
                                icon: const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18),
                                label: Text(
                                  LocalKeys.added,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      context.color.mutedContrastColor,
                                  foregroundColor:
                                      context.color.primaryContrastColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  cartService.addToCart(
                                    id.toString(),
                                    sd
                                        .serviceDetailsModel(id)
                                        .allServices!
                                        .toMinimizedJson(),
                                  );
                                },
                                icon: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    size: 18),
                                label: Text(
                                  LocalKeys.addToCart,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                              ),
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
