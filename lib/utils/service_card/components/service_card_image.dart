import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/home_models/services_list_model.dart';
import 'package:car_service/services/service/favorite_services_service.dart';
import 'package:car_service/utils/components/marquee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customizations/colors.dart';
import '../../../helper/svg_assets.dart';
import '../../components/custom_network_image.dart';

class ServiceCardImage extends StatelessWidget {
  final String? imageUrl;
  final String? duration;
  final ServiceModel service;
  const ServiceCardImage({
    super.key,
    this.imageUrl,
    required this.service,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomNetworkImage(
          width: 188,
          height: 118,
          imageUrl: imageUrl.toString(),
          fit: BoxFit.cover,
          radius: 8,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<FavoriteServicesService>(builder: (context, fj, child) {
                final isFav = fj.isFavorite(service.id.toString());
                return GestureDetector(
                  onTap: () {
                    if (isFav) {
                      fj.deleteFromFavorite(service.id.toString());
                      return;
                    }
                    fj.addToFavorite(service.id.toString(), service.toJson());
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: 6.paddingAll,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.color.accentContrastColor.withOpacity(.4),
                    ),
                    child: (isFav ? SvgAssets.heartBold : SvgAssets.heart)
                        .toSVGSized(
                      18,
                      color: primaryColor,
                    ),
                  ),
                );
              }),
              SizedBox(),
              if (duration != null)
                Container(
                  constraints: BoxConstraints(maxWidth: 72),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44),
                    color: context.color.accentContrastColor,
                  ),
                  child: Row(
                    children: [
                      SvgAssets.clock.toSVGSized(14, color: primaryColor),
                      4.toWidth,
                      Expanded(
                        flex: 1,
                        child: Marquee(
                          child: Text(
                            duration!,
                            style: context.bodySmall,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
