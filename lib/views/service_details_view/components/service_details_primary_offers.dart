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
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  runSpacing: 10,
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
                                10.toWidth,
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
