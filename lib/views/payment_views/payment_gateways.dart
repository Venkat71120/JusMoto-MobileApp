import 'dart:io';

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/attachment_select.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '/helper/svg_assets.dart';
import '../../models/payment_gateway_model.dart';
import '../../services/payment/payment_gateway_service.dart';
import 'components/auth_net_card_infos.dart';

class PaymentGateways extends StatelessWidget {
  final ValueNotifier<Gateway?> gatewayNotifier;
  final ValueNotifier<File?> attachmentNotifier;
  final TextEditingController cardController;
  final TextEditingController usernameController;
  final TextEditingController secretCodeController;
  final TextEditingController zUsernameController;
  final ValueNotifier<DateTime?> expireDateNotifier;
  final VoidCallback? onGatewaySelected;
  const PaymentGateways({
    super.key,
    required this.gatewayNotifier,
    required this.attachmentNotifier,
    required this.cardController,
    required this.usernameController,
    required this.secretCodeController,
    required this.zUsernameController,
    required this.expireDateNotifier,
    this.onGatewaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentGatewayService>(builder: (context, pg, child) {
      return FutureBuilder(
          future: pg.shouldAutoFetch ? pg.fetchGateways() : null,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const CustomPreloader();
            }
            return ValueListenableBuilder(
              valueListenable: gatewayNotifier,
              builder: (context, value, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: pg.gatewayList
                          .map((e) => GestureDetector(
                                onTap: () {
                                  gatewayNotifier.value = e;
                                  onGatewaySelected?.call();
                                  debugPrint(e.toJson().toString());
                                },
                                child: SquircleContainer(
                                  radius: 10,
                                  color: value?.name == e.name
                                      ? mutedPrimaryColor
                                      : context.color.accentContrastColor,
                                  padding: const EdgeInsets.all(6),
                                  child: ClipRRect(
                                    child: e.image.toString().endsWith(".svg")
                                        ? SvgPicture.network(e.image.toString())
                                        : (e.name == "cash_on_delivery"
                                            ? SquircleContainer(
                                                height: 42,
                                                width:
                                                    (context.width / 4.3) - 12,
                                                radius: 10,
                                                child: Image.asset(
                                                  "assets/images/cod.png",
                                                ),
                                              )
                                            : CustomNetworkImage(
                                                height: 42,
                                                width:
                                                    (context.width / 4.3) - 12,
                                                radius: 10,
                                                imageUrl: e.image.toString(),
                                                errorWidget: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgAssets.gallery
                                                        .toSVGSized(18),
                                                  ],
                                                ),
                                              )),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    if (gatewayNotifier.value?.name == "manual_payment") ...[
                      if (gatewayNotifier
                              .value?.credentials?.description?.isNotEmpty ??
                          false) ...[
                        12.toHeight,
                        SquircleContainer(
                          width: double.infinity,
                          padding: 12.paddingAll,
                          color: context.color.mutedContrastColor,
                          radius: 16,
                          child: HtmlWidget(
                            gatewayNotifier.value!.credentials!.description!,
                          ),
                        )
                      ],
                      12.toHeight,
                      AttachmentSelect(attachmentNotifier: attachmentNotifier),
                    ],
                    if (gatewayNotifier.value?.name == "authorize_dot_net") ...[
                      12.toHeight,
                      AuthCardInfos(
                          cardController: cardController,
                          usernameController: usernameController,
                          secretCodeController: secretCodeController,
                          expireDateNotifier: expireDateNotifier),
                    ],
                    if (gatewayNotifier.value?.name == "zitopay") ...[
                      12.toHeight,
                      FieldWithLabel(
                        label: LocalKeys.username,
                        hintText: LocalKeys.enterUsername,
                        controller: zUsernameController,
                      ),
                    ],
                  ]),
            );
          });
    });
  }
}
