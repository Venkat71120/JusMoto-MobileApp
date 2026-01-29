import 'package:badges/badges.dart' as badges;
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/views/cart_view/cart_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '../../../helper/svg_assets.dart';

class AppBarCart extends StatelessWidget {
  const AppBarCart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(builder: (context, cs, child) {
      return GestureDetector(
        onTap: () {
          context.toPage(const CartView());
        },
        child: Align(
          alignment: Alignment.center,
          child: badges.Badge(
            showBadge: cs.cartList.isNotEmpty,
            badgeContent: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 12),
              child: Text(
                cs.cartList.length.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle().copyWith(
                    color: context.color.accentContrastColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            child: Container(
              height: 40,
              width: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: context.color.accentContrastColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.color.mutedContrastColor,
                  )),
              child: SvgAssets.cart.toSVGSized(
                20,
                color: context.color.primaryContrastColor,
              ),
            ),
          ),
        ),
      );
    });
  }
}
