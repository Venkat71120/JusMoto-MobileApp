import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/service/service_details_model.dart';

class ServiceDetailsPrimaryOffers extends StatelessWidget {
  final List<ServiceAdditional> serviceAdditional;
  const ServiceDetailsPrimaryOffers(
      {super.key, required this.serviceAdditional});

  @override
  Widget build(BuildContext context) {
    return serviceAdditional.isEmpty
        ? const SizedBox()
        : Container(
            margin: const EdgeInsets.only(top: 8),
            color: context.color.accentContrastColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  runSpacing: 8,
                  children: serviceAdditional.map((e) {
                    final showDesc = ValueNotifier(false);
                    return ValueListenableBuilder(
                        valueListenable: showDesc,
                        builder: (context, show, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CustomNetworkImage(
                                  imageUrl: e.image,
                                  userPreloader: false,
                                  height: 20,
                                  width: 20,
                                  errorWidget: Icon(
                                    dProvider.textDirectionRight
                                        ? Icons.arrow_circle_left_outlined
                                        : Icons.arrow_circle_right_outlined,
                                    color: primaryColor,
                                    size: 22,
                                  ),
                                ),
                                8.toWidth,
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    e.title ?? "",
                                    style: context.bodySmall,
                                  ),
                                ),
                              ]),
                            ],
                          );
                        });
                  }).toList(),
                ),
              ],
            ),
          );
  }
}
