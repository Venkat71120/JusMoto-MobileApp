import 'package:car_service/helper/extension/context_extension.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../customizations/colors.dart';
import '../../../models/service/service_details_model.dart';
import '../../../utils/components/custom_network_image.dart';
import '../../../utils/components/custom_squircle_widget.dart';
import '../../../utils/components/image_view.dart';
import '../../../view_models/service_details_view_model/service_details_view_model.dart';

class ServiceDetailsImages extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  const ServiceDetailsImages({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> index = ValueNotifier(0);
    final SwiperController swipeController = SwiperController();
    final galleryImages = serviceDetails.allServices?.galleryImages ?? [];
    final sdm = ServiceDetailsViewModel.instance;
    return ValueListenableBuilder(
      valueListenable: index,
      builder: (context, ind, child) {
        return ValueListenableBuilder(
          valueListenable: sdm.showVideo,
          builder: (context, showVid, child) {
            if ((serviceDetails.allServices?.videoId ?? "").isNotEmpty &&
                showVid) {
              final controller = YoutubePlayerController.fromVideoId(
                videoId: serviceDetails.allServices!.videoId!,
                autoPlay: false,
                params: const YoutubePlayerParams(
                  showControls: false,
                  showFullscreenButton: true,
                  strictRelatedVideos: true,
                  loop: true,
                  enableCaption: false,
                  showVideoAnnotations: false,
                ),
              );
              return SizedBox(
                width: double.infinity,
                child: YoutubePlayer(
                  controller: controller,
                  enableFullScreenOnVerticalDrag: false,
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  Swiper(
                    itemCount: galleryImages.isEmpty ? 1 : galleryImages.length,
                    autoplay: false,
                    controller: swipeController,
                    onIndexChanged: (value) {
                      index.value = value;
                    },
                    onTap: (im) {
                      context.toPage(ImageView(galleryImages[im]));
                    },
                    itemBuilder: (context, i) {
                      final image =
                          galleryImages.isEmpty
                              ? [serviceDetails.allServices?.image ?? ""][i]
                              : galleryImages[i];
                      return GestureDetector(
                        onTap: () {
                          context.toPage(
                            ImageView(image, heroTag: i.toString()),
                          );
                        },
                        child: Hero(
                          tag: i.toString(),
                          child: CustomNetworkImage(
                            width: double.infinity,
                            imageUrl: image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      if (galleryImages.isEmpty &&
                          (serviceDetails.allServices?.serviceCar?.image ??
                                  serviceDetails.allServices?.image) !=
                              null) {
                        context.toPage(
                          ImageView(
                            (serviceDetails.allServices?.serviceCar?.image ??
                                serviceDetails.allServices!.image)!,
                          ),
                        );
                        return;
                      }
                      context.toPage(ImageView(galleryImages[ind]));
                    },
                    child: Container(width: double.infinity),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 6,
                        children: List.generate(galleryImages.length, (i) {
                          return GestureDetector(
                            onTap: () {
                              index.value = i;
                              swipeController.move(i);
                            },
                            child: SquircleContainer(
                              height: 60,
                              width: 80,
                              radius: 12,
                              borderColor: i == ind ? primaryColor : null,
                              borderWidth: 4,
                              child: CustomNetworkImage(
                                height: 60,
                                width: 80,
                                radius: 12,
                                imageUrl: galleryImages[i],
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
