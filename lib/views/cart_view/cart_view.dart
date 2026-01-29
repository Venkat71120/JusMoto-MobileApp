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
import 'package:car_service/views/cart_view/components/cart_price_infos.dart';
import 'package:car_service/views/cart_view/components/cart_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/profile_services/profile_info_service.dart';
import '../../services/service/cart_service.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final sbm = ServiceBookingViewModel.instance;
    return Consumer<ProfileInfoService>(
      builder: (context, pi, child) {
        return Consumer<CartService>(
          builder: (context, cs, child) {
            return Scaffold(
              appBar: AppBar(
                leading: const NavigationPopIcon(),
                backgroundColor: context.color.backgroundColor,
                centerTitle: true,
                title: Text(LocalKeys.cart),
                actions: [
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
                    label: Text(LocalKeys.clearCart),
                    icon: SvgAssets.trash.toSVGSized(18, color: primaryColor),
                  ),
                ],
              ),
              body:
                  cs.cartList.values.isEmpty
                      ? EmptyWidget(title: LocalKeys.noServiceAddedYet)
                      : CustomScrollView(
                        slivers: [
                          8.toHeight.toSliver,
                          SliverList.separated(
                            itemBuilder: (context, index) {
                              final cartItem =
                                  cs.cartList.values.toList()[index];
                              final service = ServiceModel.fromJson(
                                cartItem["service"],
                              );
                              return CartTile(
                                totalAmount:
                                    ((service.serviceCar?.discountPrice ?? 0) >
                                                0
                                            ? service.serviceCar!.discountPrice!
                                            : service.serviceCar?.price)
                                        .toString()
                                        .tryToParse *
                                    cartItem["quantity"].toString().tryToParse,
                                serviceTitle: service.title,
                                serviceImage:
                                    service.serviceCar?.image ?? service.image,
                                serviceId: service.id,
                                cartItem: cartItem,
                                maxQuantity: service.maxQuantity ?? index,
                                quantity:
                                    cartItem["quantity"].toString().tryToParse,
                                serviceType: service.type,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return 8.toHeight;
                            },
                            itemCount: cs.cartList.length,
                          ),
                          8.toHeight.toSliver,
                        ],
                      ).hp20,
              bottomNavigationBar:
                  cs.cartList.values.isEmpty
                      ? const SizedBox()
                      : CartPriceInfos(cs: cs),
            );
          },
        );
      },
    );
  }
}
