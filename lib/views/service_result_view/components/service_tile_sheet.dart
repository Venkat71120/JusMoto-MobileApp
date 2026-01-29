import 'dart:math';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/views/service_result_view/components/service_tile.dart';
import 'package:flutter/material.dart';

import '../../../models/home_models/services_list_model.dart';

class ServiceTileSheet extends StatelessWidget {
  final List<ServiceModel> serviceList;
  const ServiceTileSheet({super.key, required this.serviceList});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: 16.paddingV,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: context.color.mutedContrastColor,
                    ),
                  ),
                ),
              ),
              Wrap(
                children: serviceList
                    .map((service) => ServiceTile(
                          service: service,
                        ).divider)
                    .toList(),
              ),
              20.toHeight,
            ],
          ),
        ),
        if (serviceList.length > 3)
          Positioned(
            bottom: 32,
            right: 0,
            child: GestureDetector(
              onTap: () {
                context.pop;
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                margin: const EdgeInsets.symmetric(vertical: 26),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    color: context.color.accentContrastColor,
                    border:
                        Border.all(color: context.color.primaryBorderColor)),
                child: Transform.rotate(
                    angle: context.dProvider.textDirectionRight ? pi : 0,
                    child: const Icon(Icons.chevron_left_outlined)),
              ),
            ),
          ),
      ],
    );
  }
}
