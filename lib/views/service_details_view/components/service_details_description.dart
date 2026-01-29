import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../../customizations/colors.dart';
import '../../../helper/local_keys.g.dart';
import '../../../models/service/service_details_model.dart';
import 'after_booking_steps.dart';
import 'service_details_offers.dart';
import 'service_details_primary_offers.dart';

class ServiceDetailsDescription extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;

  const ServiceDetailsDescription({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReadMoreText(
          serviceDetails.allServices?.description ?? "---",
          trimMode: TrimMode.Line,
          trimLines: 3,
          colorClickableText: primaryColor,
          trimCollapsedText: LocalKeys.showMore,
          trimExpandedText: " ${LocalKeys.showLess}",
          style: context.bodyMedium,
        ),
        6.toHeight,
        ServiceDetailsPrimaryOffers(
            serviceAdditional:
                serviceDetails.allServices?.serviceAdditional ?? []),
        if ((serviceDetails.allServices?.serviceAdditional ?? []).isNotEmpty)
          ServiceDetailsOffers(
              offers: serviceDetails.allServices?.offers ?? []),
        if ((serviceDetails.allServices?.afterBookingSteps ?? []).isNotEmpty)
          AfterBookingSteps(
              steps: serviceDetails.allServices?.afterBookingSteps ?? []),
      ],
    );
  }
}
