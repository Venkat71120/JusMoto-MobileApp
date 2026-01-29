import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../helper/image_assets.dart';

class CustomNetworkImage extends StatelessWidget {
  final double? radius;
  final double? height;
  final double? width;
  final double? loadingHeight;
  final double? loadingWidth;
  final String? name;
  final BoxFit? fit;
  final String? imageUrl;
  final String? filePath;
  final bool userPreloader;
  final bool carPlaceholder;
  final Widget? errorWidget;
  final Color? color;
  const CustomNetworkImage({
    super.key,
    this.radius,
    this.height,
    this.width,
    this.fit,
    this.name,
    this.color,
    this.filePath,
    this.imageUrl,
    this.errorWidget,
    this.loadingHeight,
    this.loadingWidth,
    this.userPreloader = false,
    this.carPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final plImage = Container(
      color: color,
      padding: loadingHeight == null ? null : const EdgeInsets.all(12),
      height: (loadingHeight),
      width: (loadingWidth),
      alignment: Alignment.center,
      child: Container(
        height: (loadingHeight ?? height ?? 1) / 2,
        width: (loadingWidth ?? width ?? 1) / 2,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ImageAssets.loadingImage.toAsset, opacity: .5)),
      ),
    );
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: radius == null
          ? const BoxDecoration()
          : ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: radius!,
                  cornerSmoothing: 0.5,
                ),
              ),
            ),
      child: filePath != null
          ? Image.file(
              File(filePath!),
              fit: fit,
            )
          : 1 == 1
              ? CachedNetworkImage(
                  imageUrl: imageUrl ?? "",
                  fit: fit,
                  errorWidget: (context, url, error) {
                    if ((name ?? "").length >= 2) {
                      return errorWidget ??
                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: color ?? primaryColor,
                            alignment: Alignment.center,
                            child: Text(
                              name!.substring(0, 2).toUpperCase(),
                              style: context.titleMedium?.copyWith(
                                  color: context.color.accentContrastColor,
                                  fontSize: (height ?? 40) / 2.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                    }
                    if (userPreloader) {
                      return ImageAssets.avatar.toAImage();
                    } else if (carPlaceholder) {
                      return Container(
                        color: color,
                        padding: loadingHeight == null
                            ? null
                            : const EdgeInsets.all(12),
                        height: (loadingHeight),
                        width: (loadingWidth),
                        alignment: Alignment.center,
                        child: Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: ImageAssets.carPlaceholder.toAsset,
                                  opacity: .3)),
                        ),
                      );
                    }
                    return errorWidget ?? plImage;
                  },
                  placeholder: (context, url) {
                    if (userPreloader) {
                      return ImageAssets.avatar.toAImage();
                    } else if (carPlaceholder) {
                      return Container(
                        color: color,
                        padding: loadingHeight == null
                            ? null
                            : const EdgeInsets.all(12),
                        height: (loadingHeight),
                        width: (loadingWidth),
                        alignment: Alignment.center,
                        child: Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: ImageAssets.carPlaceholder.toAsset,
                                  opacity: .3)),
                        ),
                      );
                    } else {
                      return LottieBuilder.asset(
                          "assets/animations/image_loader.json");
                    }
                  },
                  cacheManager: customCacheManager,
                )
              : Image.network(
                  imageUrl ?? '',
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    if ((name ?? "").isNotEmpty) {
                      return errorWidget ??
                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: color ?? primaryColor,
                            alignment: Alignment.center,
                            child: Text(
                              name!.substring(0, 2).toUpperCase(),
                              style: context.titleMedium?.copyWith(
                                  color: context.color.accentContrastColor,
                                  fontSize: (height ?? 40) / 2.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                    }
                    return userPreloader
                        ? ImageAssets.avatar.toAImage()
                        : plImage;
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (!((loadingProgress?.expectedTotalBytes) ==
                            loadingProgress?.cumulativeBytesLoaded) ||
                        loadingProgress != null) {
                      return userPreloader
                          ? ImageAssets.avatar.toAImage()
                          : plImage;
                    }
                    return child;
                  },
                ),
    );
  }
}
