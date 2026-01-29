import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';
import '../../../models/home_models/services_list_model.dart';
import '../../../utils/service_card/service_card.dart';

class RelatedServiceList extends StatelessWidget {
  final List<ServiceModel> relatedServices;
  const RelatedServiceList({super.key, required this.relatedServices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            LocalKeys.relatedServices,
            style: context.titleMedium?.bold,
          ),
        ),
        16.toHeight,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 16,
            children: relatedServices
                .map((e) => ServiceCard(
                      service: e,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
