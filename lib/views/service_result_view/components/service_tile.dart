import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/service_card/components/service_card_price.dart';
import 'package:car_service/utils/service_card/components/service_card_sub_info.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/home_models/services_list_model.dart';
import '../../../services/home_services/service_details_service.dart';
import '../../service_details_view/service_details_view.dart';

class ServiceTile extends StatelessWidget {
  final ServiceModel service;
  const ServiceTile({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final sdm = ServiceDetailsViewModel.instance;
        sdm.selectedTab.value = LocalKeys.overview;
        sdm.scrollController.addListener(() => sdm.onScroll(context));
        context.toPage(ServiceDetailsView(id: service.id), then: (_) {
          Provider.of<ServiceDetailsService>(context, listen: false)
              .remove(service.id);
          ServiceDetailsViewModel.instance.selectedTab.value =
              LocalKeys.overview;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomNetworkImage(
              height: 64,
              width: 64,
              radius: 10,
              fit: BoxFit.cover,
              imageUrl: service.image,
            ),
            12.toWidth,
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title ?? "---",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.titleSmall?.bold,
                  ),
                  ServiceCardSubInfo(
                    avgRating: service.avgRating,
                    soldCount: service.soldCount,
                  ),
                  4.toHeight,
                  ServiceCardPrice(
                    price: service.price,
                    discountPrice: service.discountPrice,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
