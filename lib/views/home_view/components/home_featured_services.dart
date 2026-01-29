import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/service_card/service_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/home_services/home_featured_services_service.dart';
import 'services_horizontal_skeleton.dart';

class HomeFeaturedServices extends StatelessWidget {
  const HomeFeaturedServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeFeaturedServicesService>(
      builder: (context, hc, child) {
        return CustomFutureWidget(
          function: hc.shouldAutoFetch ? hc.fetchHomeFeaturedServices() : null,
          shimmer: const ServicesHorizontalSkeleton(),
          child:
              hc.homeFeaturedServicesModel.allServices.isEmpty
                  ? const SizedBox()
                  : Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            LocalKeys.featured,
                            style: context.titleMedium?.bold,
                          ),
                        ),
                        12.toHeight,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 12,
                            children:
                                hc.homeFeaturedServicesModel.allServices
                                    .map((e) => ServiceCard(service: e))
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
