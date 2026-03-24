import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:car_service/views/cart_view/components/cart_tile_quantity_update_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../services/home_services/service_details_service.dart';
import '../../../utils/components/custom_network_image.dart';
import '../../../view_models/service_details_view_model/service_details_view_model.dart';
import '../../service_details_view/service_details_view.dart';

class CartTile extends StatelessWidget {
  final String? serviceTitle;
  final String? serviceImage;
  final String? serviceType;
  final dynamic serviceId;
  final num totalAmount;
  final num maxQuantity;
  final num quantity;
  final dynamic cartItem;
  const CartTile(
      {super.key,
      this.serviceTitle,
      this.serviceImage,
      this.serviceType,
      this.serviceId,
      required this.totalAmount,
      required this.maxQuantity,
      required this.quantity,
      this.cartItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final sdm = ServiceDetailsViewModel.instance;
        sdm.selectedTab.value = LocalKeys.overview;
        sdm.scrollController.addListener(() => sdm.onScroll(context));
        context.toPage(ServiceDetailsView(id: serviceId), then: (_) {
          Provider.of<ServiceDetailsService>(context, listen: false)
              .remove(serviceId);
          ServiceDetailsViewModel.instance.selectedTab.value =
              LocalKeys.overview;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomNetworkImage(
                height: 60,
                width: 60,
                radius: 10,
                fit: BoxFit.cover,
                imageUrl: serviceImage,
              ),
            ),
            12.toWidth,
            // Title + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceTitle ?? "---",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodySmall?.bold6.copyWith(
                      color: context.color.primaryContrastColor,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  4.toHeight,
                  Text(
                    totalAmount.cur,
                    style: context.bodySmall?.bold.price.copyWith(
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            10.toWidth,
            // Quantity / delete
            serviceType.toString() == "0"
                ? GestureDetector(
                    onTap: () {
                      Alerts().confirmationAlert(
                          context: context,
                          title: LocalKeys.deleteItemFromCart,
                          onConfirm: () async {
                            Provider.of<CartService>(context, listen: false)
                                .deleteFromCart(serviceId.toString());
                            context.pop;
                          },
                          buttonText: LocalKeys.yes,
                          description: LocalKeys.thisWillRemoveItemFromCart);
                    },
                    child: SvgAssets.trash.toSVGSized(20,
                        color: context.color.primaryWarningColor),
                  )
                : CartTileQuantityUpdateButtons(
                    quantity: quantity.toInt(),
                    onAdd: () {
                      Provider.of<CartService>(context, listen: false)
                          .updateToCart(serviceId.toString(),
                              cartItem["service"], quantity + 1);
                    },
                    onRemove: quantity == 1
                        ? () {
                            Alerts().confirmationAlert(
                                context: context,
                                title: LocalKeys.deleteItemFromCart,
                                onConfirm: () async {
                                  Provider.of<CartService>(context,
                                          listen: false)
                                      .deleteFromCart(serviceId.toString());
                                  context.pop;
                                },
                                buttonText: LocalKeys.yes,
                                description:
                                    LocalKeys.thisWillRemoveItemFromCart);
                          }
                        : () {
                            Provider.of<CartService>(context, listen: false)
                                .updateToCart(serviceId.toString(),
                                    cartItem["service"], quantity - 1);
                          }),
          ],
        ),
      ),
    );
  }
}
