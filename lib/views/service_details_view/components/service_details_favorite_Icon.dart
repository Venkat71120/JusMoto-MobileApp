import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/home_models/services_list_model.dart';
import 'package:car_service/services/home_services/service_details_service.dart';
import 'package:car_service/services/service/favorite_services_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customizations/colors.dart';

class ServiceDetailsFavoriteIcon extends StatelessWidget {
  final dynamic id;
  const ServiceDetailsFavoriteIcon({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceDetailsService>(builder: (context, jd, child) {
      if (jd.serviceDetailsModel(id).allServices == null) {
        return const SizedBox();
      }
      final serviceDetails = jd.serviceDetailsModel(id).allServices!;
      return Consumer<FavoriteServicesService>(builder: (context, fj, child) {
        final isFav = fj.isFavorite(id.toString());
        return GestureDetector(
          onTap: () {
            if (isFav) {
              fj.deleteFromFavorite(id.toString());
              return;
            }
            fj.addToFavorite(
                id.toString(),
                ServiceModel(
                  id: serviceDetails.id,
                  title: serviceDetails.title,
                  price: serviceDetails.price,
                  discountPrice: serviceDetails.discountPrice ?? 0,
                  category: serviceDetails.category,
                  unit: serviceDetails.unit,
                  image: serviceDetails.image,
                  view: serviceDetails.view,
                  averageRating: serviceDetails.averageRating,
                  soldCount: serviceDetails.soldCount,
                  totalReviews: serviceDetails.totalReviews,
                ).toJson());
          },
          child: Container(
            alignment: Alignment.center,
            padding: 6.paddingAll,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.color.accentContrastColor,
            ),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              size: 20,
              color: isFav ? primaryColor : context.color.tertiaryContrastColo,
            ),
          ),
        );
      });
    });
  }
}
