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
    // 1. Safe access to avoid crashes if data hasn't loaded yet
    final service = serviceDetails.allServices;

    if (service == null) {
      return const SizedBox.shrink(); // Or a loading shimmer
    }

    // 2. Determine which price to show (Car-specific price OR general service price)
    final displayPrice = service.serviceCar?.price != 0 
        ? service.serviceCar?.price 
        : service.price;

    final displayDiscount = service.serviceCar?.discountPrice != null 
        ? service.serviceCar?.discountPrice 
        : service.discountPrice;

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
          // 3. Use the fallback prices we calculated above
          ServiceCardPrice(
              price: displayPrice ?? 0,
              discountPrice: displayDiscount ?? 0),
        ],
      ),
    );
  }
}