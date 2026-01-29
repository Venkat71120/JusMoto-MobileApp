import 'dart:io';

import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  const ImageView(this.imageUrl, {super.key, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const NavigationPopIcon(),
        ),
        body: Center(
          child: Hero(
            tag: heroTag ?? "none",
            child: PhotoView(
              backgroundDecoration:
                  const BoxDecoration(color: Colors.transparent),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.5,
              loadingBuilder:
                  (BuildContext context, ImageChunkEvent? loadingProgress) {
                return LottieBuilder.asset(
                    "assets/animations/image_loader.json");
              },
              errorBuilder: (context, exception, stackTrace) {
                return Text(LocalKeys.file);
              },
              imageProvider: imageUrl.contains('http')
                  ? NetworkImage(imageUrl) as ImageProvider<Object>?
                  : FileImage(File(imageUrl)),
            ),
          ),
        ));
  }
}
