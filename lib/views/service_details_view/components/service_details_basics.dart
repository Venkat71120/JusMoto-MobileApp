import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../models/service/service_details_model.dart';

class ServiceDetailsBasics extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  final dynamic id;
  const ServiceDetailsBasics(
      {super.key, required this.serviceDetails, required this.id});

  @override
  Widget build(BuildContext context) {
    final service = serviceDetails.allServices;

    if (service == null) {
      return const SizedBox.shrink();
    }

    final displayPrice = service.serviceCar?.price ?? service.price;
    final displayDiscount =
        service.serviceCar?.discountPrice ?? service.discountPrice;
    final hasDiscount =
        (displayDiscount ?? 0) > 0 && displayDiscount != displayPrice;
    final discountPercent = hasDiscount && (displayPrice ?? 0) > 0
        ? (((displayPrice! - displayDiscount!) / displayPrice) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating & sold badge row
          Row(
            children: [
              if (service.averageRating > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFF3E0),
                        const Color(0xFFFFE0B2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.orange.shade700,
                        size: 18,
                      ),
                      4.toWidth,
                      Text(
                        service.averageRating.toStringAsFixed(1),
                        style: context.bodySmall?.bold6.copyWith(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              if (service.averageRating > 0 && service.soldCount > 0)
                10.toWidth,
              if (service.soldCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.color.mutedContrastColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                      4.toWidth,
                      Text(
                        "${_formatNumber(service.soldCount)} sold",
                        style: context.bodySmall?.bold5.copyWith(
                          color: context.color.primaryContrastColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          16.toHeight,
          // Title
          Text(
            service.title ?? "---",
            style: context.headlineMedium?.bold.copyWith(
              height: 1.3,
              fontSize: 22,
              letterSpacing: -0.3,
            ),
          ),
          14.toHeight,
          // Price row — clean inline
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hasDiscount
                    ? (displayDiscount ?? 0).cur
                    : (displayPrice ?? 0).cur,
                style: context.titleLarge?.bold.price.copyWith(
                  color: primaryColor,
                  fontSize: 20,
                ),
              ),
              if (hasDiscount) ...[
                10.toWidth,
                Text(
                  (displayPrice ?? 0).cur,
                  style: context.bodySmall?.price.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: context.color.tertiaryContrastColo,
                    color: context.color.tertiaryContrastColo,
                    fontSize: 14,
                  ),
                ),
                10.toWidth,
                if (discountPercent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "$discountPercent% OFF",
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(num number) {
    if (number >= 1000 && number < 1000000) {
      return "${(number / 1000).toStringAsFixed(1)}k";
    } else if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    }
    return number.toString();
  }
}
