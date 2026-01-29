import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/home_services/service_details_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/views/service_by_category_view/service_by_category_view.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/home_services/home_slider_service.dart';
import '../../service_by_offer_view/service_by_offer_view.dart';
import '../../service_details_view/service_details_view.dart';
import 'slider_skeleton.dart';

class HomeSlider extends StatelessWidget {
  const HomeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final index = ValueNotifier(0);
    return Consumer<HomeSliderService>(
      builder: (context, hs, child) {
        return CustomFutureWidget(
          function: hs.sliderList == null ? hs.fetchHomeSlider() : null,
          shimmer: const SliderSkeleton(),
          child:
              (hs.sliderList ?? []).isEmpty
                  ? const SizedBox()
                  : Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: ((context.width - 24) / 328) * 128,
                          child: Swiper(
                            itemCount: hs.sliderList!.length,
                            autoplay: true,
                            itemHeight: context.width * 0.82,
                            onIndexChanged: (value) {
                              index.value = value;
                            },
                            itemBuilder: (context, index) {
                              final slider = hs.sliderList![index];
                              return GestureDetector(
                                onTap: () {
                                  if (slider.identity == null) return;
                                  switch (slider.type) {
                                    case "category":
                                      context.toPage(
                                        ServiceByCategoryView(
                                          catId: slider.identity,
                                        ),
                                      );
                                      break;
                                    case "service":
                                      context.toPage(
                                        ServiceDetailsView(id: slider.identity),
                                        then: (_) {
                                          Provider.of<ServiceDetailsService>(
                                            context,
                                            listen: false,
                                          ).remove(slider.identity);
                                        },
                                      );
                                      break;
                                    case "offer":
                                      context.toPage(
                                        ServiceByOfferView(
                                          offerId: slider.identity,
                                        ),
                                      );
                                      break;
                                    default:
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: CustomNetworkImage(
                                    width: context.width * 0.82,
                                    height: ((context.width - 24) / 307) * 150,
                                    radius: 12,
                                    imageUrl:
                                        "https://i.postimg.cc/sXhN3fjg/slider-car-service.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
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
