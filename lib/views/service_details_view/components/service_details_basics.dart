import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';

import '../../../models/service/service_details_model.dart';
import '../../../utils/service_card/components/service_card_price.dart';
import '../../../utils/service_card/components/service_card_sub_info.dart';

class ServiceDetailsBasics extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  final dynamic id;
  const ServiceDetailsBasics(
      {super.key, required this.serviceDetails, required this.id});

  @override
  Widget build(BuildContext context) {
    final service = serviceDetails.allServices!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: context.color.accentContrastColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceCardSubInfo(
            avgRating: service.averageRating,
            soldCount: service.soldCount,
          ),
          4.toHeight,
          Text(
            service.title ?? "---",
            style: context.titleLarge?.bold,
          ),
          6.toHeight,
          ServiceCardPrice(
              price: service.serviceCar?.price ?? 0,
              discountPrice: service.serviceCar?.discountPrice ?? 0),
        ],
      ),
    );
  }
}
