import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/home_services/service_details_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/views/service_by_category_view/service_by_category_view.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';

import '../../../services/home_services/home_slider_service.dart';
import '../../service_by_offer_view/service_by_offer_view.dart';
import '../../service_details_view/service_details_view.dart';
import 'slider_skeleton.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  bool _precached = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeSliderService>(
      builder: (context, hs, child) {
        return CustomFutureWidget(
          function: hs.sliderList == null ? hs.fetchHomeSlider() : null,
          shimmer: const SliderSkeleton(),
          child: (hs.sliderList ?? []).isEmpty
              ? const SizedBox()
              : _buildSwiper(context, hs),
        );
      },
    );
  }

  Widget _buildSwiper(BuildContext context, HomeSliderService hs) {
    // Precache once when list is ready
    if (!_precached) {
      _precached = true;
      hs.precacheSliderImages(context);
    }

    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: ((context.width - 24) / 328) * 128,
        child: Swiper(
          itemCount: hs.sliderList!.length,
          autoplay: true,
          autoplayDelay: 5000,
          onIndexChanged: (value) {},
          itemBuilder: (context, index) {
            final slider = hs.sliderList![index];
            final imageUrl = slider.image?.trim() ?? "";

            return GestureDetector(
              onTap: () {
                if (slider.identity == null) return;
                switch (slider.type) {
                  case "category":
                    context.toPage(ServiceByCategoryView(catId: slider.identity));
                    break;
                  case "service":
                    context.toPage(
                      ServiceDetailsView(id: slider.identity),
                      then: (_) {
                        Provider.of<ServiceDetailsService>(context, listen: false)
                            .remove(slider.identity);
                      },
                    );
                    break;
                  case "offer":
                    context.toPage(ServiceByOfferView(offerId: slider.identity));
                    break;
                  default:
                    break;
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isEmpty
                      ? _errorPlaceholder()
                      : Image(
                          // ✅ Uses Flutter's internal image cache — no re-fetch
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            // ✅ If already in cache, shows instantly (frame != null immediately)
                            if (wasSynchronouslyLoaded || frame != null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }
}