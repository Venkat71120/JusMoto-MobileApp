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
                  // Gradient overlay at bottom for better visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.45),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Image counter pill
                  if (galleryImages.length > 1)
                    Positioned(
                      bottom: 14,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${ind + 1}/${galleryImages.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Dot indicators
                  if (galleryImages.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(galleryImages.length, (i) {
                          final isActive = i == ind;
                          return GestureDetector(
                            onTap: () {
                              index.value = i;
                              swipeController.move(i);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: isActive ? 24 : 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? primaryColor
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
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
