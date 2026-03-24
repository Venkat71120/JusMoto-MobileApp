import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/models/home_models/services_list_model.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:car_service/views/cart_view/components/cart_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/profile_services/profile_info_service.dart';
import '../../services/service/cart_service.dart';
import '../../view_models/sign_in_view_model/sign_in_view_model.dart';
import '../service_booking_address_schedule_view/service_booking_address_schedule_view.dart';
import '../sign_in_view/sign_in_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  num _getEffectivePrice(ServiceModel service) {
    final carDiscountPrice = service.serviceCar?.discountPrice ?? 0;
    final carPrice = service.serviceCar?.price ?? 0;

    if (carPrice > 0) {
      return (carDiscountPrice > 0 && carDiscountPrice < carPrice)
          ? carDiscountPrice
          : carPrice;
    }

    final discountPrice = service.discountPrice;
    final price = service.price;

    if (discountPrice > 0 && discountPrice < price) {
      return discountPrice;
    }

    return price;
  }

  @override
  Widget build(BuildContext context) {
    final sbm = ServiceBookingViewModel.instance;
    return Consumer<ProfileInfoService>(
      builder: (context, pi, child) {
        return Consumer<CartService>(
          builder: (context, cs, child) {
            return Scaffold(
              backgroundColor: context.color.backgroundColor,
              appBar: AppBar(
                leading: const NavigationPopIcon(),
                backgroundColor: context.color.backgroundColor,
                surfaceTintColor: context.color.backgroundColor,
                centerTitle: true,
                title: Text(
                  LocalKeys.cart,
                  style: context.titleMedium?.bold,
                ),
                actions: [
                  if (cs.cartList.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Alerts().confirmationAlert(
                          context: context,
                          title: LocalKeys.areYouSure,
                          buttonText: LocalKeys.clear,
                          onConfirm: () async {
                            cs.clearCart();
                            context.pop;
                          },
                        );
                      },
                      label: Text(
                        LocalKeys.clearCart,
                        style: TextStyle(color: primaryColor, fontSize: 13),
                      ),
                      icon:
                          SvgAssets.trash.toSVGSized(16, color: primaryColor),
                    ),
                ],
              ),
              body: cs.cartList.values.isEmpty
                  ? EmptyWidget(title: LocalKeys.noServiceAddedYet)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Cart Items Card ──
                          Container(
                            decoration: BoxDecoration(
                              color: context.color.accentContrastColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Card header
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 16, 16, 0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        color: primaryColor,
                                        size: 18,
                                      ),
                                      8.toWidth,
                                      Text(
                                        "${cs.cartList.length} ${cs.cartList.length == 1 ? 'Item' : 'Items'}",
                                        style:
                                            context.titleSmall?.bold.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                12.toHeight,
                                // Cart items
                                ...cs.cartList.values
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final cartItem = entry.value;
                                  final service = ServiceModel.fromJson(
                                    cartItem["service"],
                                  );
                                  final unitPrice =
                                      _getEffectivePrice(service);

                                  return Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        child: CartTile(
                                          totalAmount: unitPrice *
                                              cartItem["quantity"]
                                                  .toString()
                                                  .tryToParse,
                                          serviceTitle: service.title,
                                          serviceImage:
                                              service.serviceCar?.image ??
                                                  service.image,
                                          serviceId: service.id,
                                          cartItem: cartItem,
                                          maxQuantity:
                                              service.maxQuantity ??
                                                  index,
                                          quantity: cartItem["quantity"]
                                              .toString()
                                              .tryToParse,
                                          serviceType: service.type,
                                        ),
                                      ),
                                      if (index < cs.cartList.length - 1)
                                        Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: context
                                              .color.primaryBorderColor
                                              .withOpacity(0.5),
                                        ),
                                    ],
                                  );
                                }),
                                12.toHeight,
                              ],
                            ),
                          ),
                          16.toHeight,

                          // ── Requirements Text Box ──
                          Container(
                            decoration: BoxDecoration(
                              color: context.color.accentContrastColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note_rounded,
                                      color:
                                          context.color.tertiaryContrastColo,
                                      size: 18,
                                    ),
                                    8.toWidth,
                                    Text(
                                      "Any other requirements?",
                                      style:
                                          context.bodySmall?.bold6.copyWith(
                                        color: context
                                            .color.secondaryContrastColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                10.toHeight,
                                TextField(
                                  maxLines: 2,
                                  style: context.bodySmall?.copyWith(
                                      fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText:
                                        "E.g. specific parts, preferences...",
                                    hintStyle:
                                        context.bodySmall?.copyWith(
                                      color: context
                                          .color.tertiaryContrastColo,
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor:
                                        context.color.mutedContrastColor
                                            .withOpacity(0.5),
                                    contentPadding:
                                        const EdgeInsets.all(12),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          16.toHeight,

                          // ── Bill Summary Card ──
                          Container(
                            decoration: BoxDecoration(
                              color: context.color.accentContrastColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bill header
                                Text(
                                  "Bill Summary",
                                  style:
                                      context.titleSmall?.bold.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                12.toHeight,
                                // Dotted divider
                                _dottedDivider(context),
                                12.toHeight,
                                // Item-wise breakdown
                                ...cs.cartList.values
                                    .toList()
                                    .map((cartItem) {
                                  final service = ServiceModel.fromJson(
                                      cartItem["service"]);
                                  final unitPrice =
                                      _getEffectivePrice(service);
                                  final qty = cartItem["quantity"]
                                      .toString()
                                      .tryToParse;
                                  final itemTotal = unitPrice * qty;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${service.title ?? '---'} x$qty",
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: context.bodySmall
                                                ?.copyWith(
                                              color: context.color
                                                  .secondaryContrastColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          itemTotal.cur,
                                          style: context.bodySmall?.bold6
                                              .price.copyWith(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                8.toHeight,
                                _dottedDivider(context),
                                14.toHeight,
                                // Total row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        LocalKeys.total,
                                        style: context.titleSmall?.bold
                                            .copyWith(fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      cs.subTotal.cur,
                                      style: context.titleMedium?.bold
                                          .price.copyWith(
                                        color: primaryColor,
                                        fontSize: 17,
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
              // ── Compact Bottom Bar ──
              bottomNavigationBar: cs.cartList.values.isEmpty
                  ? const SizedBox()
                  : Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      decoration: BoxDecoration(
                        color: context.color.accentContrastColor,
                        border: Border(
                          top: BorderSide(
                            color: context.color.primaryBorderColor
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            // Left — price
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocalKeys.total,
                                  style: context.bodySmall?.copyWith(
                                    color: context
                                        .color.tertiaryContrastColo,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  cs.subTotal.cur,
                                  style:
                                      context.titleSmall?.bold.price.copyWith(
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Right — checkout button
                            Consumer<ProfileInfoService>(
                              builder: (context, pi, child) {
                                return SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (pi.profileInfoModel
                                              .userDetails ==
                                          null) {
                                        SignInViewModel.dispose;
                                        SignInViewModel.instance
                                            .initSavedInfo();
                                        context.toPage(
                                            const SignInView());
                                        return;
                                      }
                                      ServiceBookingViewModel.dispose;
                                      context.toPage(
                                          const ServiceBookingAddressScheduleView());
                                    },
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 24),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                      ),
                                    ),
                                    child: Text(
                                      pi.profileInfoModel
                                                  .userDetails ==
                                              null
                                          ? LocalKeys.signIn
                                          : LocalKeys.continueO,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _dottedDivider(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 4.0;
        final dashSpace = 4.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.color.primaryBorderColor,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
