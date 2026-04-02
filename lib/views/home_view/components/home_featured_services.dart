import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/service_card/service_card.dart';
import 'package:car_service/views/custom_service_view/custom_service_view.dart';
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
          child: Padding(
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
                            children: [
                              ...hc.homeFeaturedServicesModel.allServices
                                  .map((e) => ServiceCard(service: e)),
                              _CustomServiceCard(),
                            ],
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

class _CustomServiceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.toPage(const CustomServiceView());
      },
      child: SquircleContainer(
        width: 188,
        height: 260,
        padding: const EdgeInsets.all(8),
        radius: 12,
        color: context.color.accentContrastColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SquircleContainer(
              width: 64,
              height: 64,
              radius: 32,
              color: context.color.primaryContrastColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.build_outlined,
                size: 32,
                color: context.color.primaryContrastColor,
              ),
            ),
            16.toHeight,
            Text(
              "Custom Service",
              style: context.titleSmall?.bold6.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            8.toHeight,
            Text(
              "Need something specific?\nGet a custom quote",
              style: context.bodySmall?.copyWith(
                color: context.color.mutedContrastColor,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            12.toHeight,
            SquircleContainer(
              radius: 8,
              color: context.color.primaryContrastColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Text(
                "Get Quote",
                style: context.labelSmall?.bold.copyWith(
                  color: context.color.accentContrastColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
