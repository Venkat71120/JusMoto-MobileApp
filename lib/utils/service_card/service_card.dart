import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/home_models/services_list_model.dart';
import 'package:car_service/services/home_services/service_details_service.dart';
import 'package:car_service/utils/service_card/components/service_card_image.dart';
import 'package:car_service/utils/service_card/components/service_card_price.dart';
import 'package:car_service/utils/service_card/components/service_card_sub_info.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:car_service/views/service_details_view/service_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../../services/service/cart_service.dart';
import '../components/custom_squircle_widget.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: If a car variant is selected, use its price; otherwise fall back
    // to the service's own price. Old API always had serviceCar set; new API
    // only sets it when a variant is selected, so we must not default to 0.
    final displayPrice =
        service.serviceCar?.price ?? service.price;
    final displayDiscountPrice =
        service.serviceCar?.discountPrice ?? service.discountPrice;

    return GestureDetector(
      onTap: () {
        final sdm = ServiceDetailsViewModel.instance;
        sdm.selectedTab.value = LocalKeys.overview;
        sdm.scrollController.addListener(() => sdm.onScroll(context));
        context.toPage(
          ServiceDetailsView(id: service.id),
          then: (_) {
            Provider.of<ServiceDetailsService>(
              context,
              listen: false,
            ).remove(service.id);
            ServiceDetailsViewModel.instance.selectedTab.value =
                LocalKeys.overview;
          },
        );
      },
      child: SquircleContainer(
        width: 188,
        height: 260,
        padding: const EdgeInsets.all(8),
        radius: 12,
        color: context.color.accentContrastColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceCardImage(
                  // ✅ FIX: Same pattern for image — fall back to service image
                  imageUrl: service.serviceCar?.image ?? service.image,
                  service: service,
                  duration: service.duration,
                ),
                12.toHeight,
                Text(
                  service.title ?? "---",
                  style: context.titleSmall?.bold6,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                4.toHeight,
                ServiceCardSubInfo(
                  avgRating: service.avgRating,
                  soldCount: service.soldCount,
                ),
                12.toHeight,
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ServiceCardPrice(
                    // ✅ FIXED: Use resolved prices instead of serviceCar directly
                    price: displayPrice,
                    discountPrice: displayDiscountPrice,
                  ),
                ),
                Consumer<CartService>(
                  builder: (context, cartService, child) {
                    final isAdded = cartService.cartList.containsKey(
                      service.id.toString(),
                    );
                    final currentQty =
                        cartService.cartList[service.id
                            .toString()]?["quantity"] ??
                        0;
                    final preventMultiCart =
                        (isAdded && service.type.toString() == "0");
                    return GestureDetector(
                      onTap: () {
                        if (preventMultiCart) return;
                        if (isAdded) {
                          cartService.updateToCart(
                            service.id.toString(),
                            service,
                            (currentQty ?? 1) + 1,
                          );
                          LocalKeys.updatedSuccessfully.showToast();
                          return;
                        }
                        cartService.addToCart(
                          service.id.toString(),
                          service.toMinimizedJson(),
                        );
                      },
                      child: SquircleContainer(
                        radius: 8,
                        color: preventMultiCart
                            ? context.color.accentContrastColor
                            : context.color.primaryContrastColor,
                        borderColor: preventMultiCart
                            ? context.color.primaryBorderColor
                            : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: Row(
                          children: [
                            SvgAssets.cart.toSVGSized(
                              20,
                              color: preventMultiCart
                                  ? context.color.primaryContrastColor
                                  : context.color.accentContrastColor,
                            ),
                            4.toWidth,
                            Text(
                              preventMultiCart
                                  ? LocalKeys.added
                                  : LocalKeys.add,
                              style: context.titleSmall?.bold.copyWith(
                                color: preventMultiCart
                                    ? context.color.primaryContrastColor
                                    : context.color.accentContrastColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}