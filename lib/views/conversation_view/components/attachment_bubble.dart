import 'dart:io';

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';

class AttachmentBubble extends StatelessWidget {
  final file;
  final senderFromWeb;
  const AttachmentBubble({super.key, this.file, this.senderFromWeb});

  @override
  Widget build(BuildContext context) {
    bool isImage = false;
    bool isFile = false;
    bool isPdf = false;
    var filePath = "";
    if (file is File) {
      isFile = true;
    } else if (file is String && isImageUrl(file)) {
      isImage = true;
      filePath = "$file";
    } else if (file is String && file.toString().endsWith(".pdf")) {
      isPdf = true;
      debugPrint(file.toString());
      debugPrint("will show pdf ${!(isFile || isImage || file is! String)}"
          .toString());
      filePath = "$file";
    }
    return !(isFile || isImage || isPdf)
        ? const SizedBox()
        : InkWell(
            onTap: () async {
              if (isPdf) {
                final Uri launchUri = Uri(
                  scheme: 'https',
                  path: filePath.replaceAll("https://", ""),
                );
                await urlLauncher.launchUrl(launchUri);
              }
            },
            child: isPdf
                ? SquircleContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(top: 8),
                    color: senderFromWeb
                        ? context.color.accentContrastColor
                        : primaryColor,
                    constraints: BoxConstraints(maxWidth: context.width / 1.7),
                    radius: 12,
                    child: FittedBox(
                      child: Row(
                        children: [
                          SvgAssets.download.toSVGSized(18,
                              color: senderFromWeb
                                  ? primaryColor
                                  : context.color.accentContrastColor),
                          6.toWidth,
                          Text(
                            LocalKeys.downloadAttachment,
                            textAlign: senderFromWeb ? null : TextAlign.end,
                            style: context.titleMedium?.copyWith(
                                fontSize: 14,
                                color: senderFromWeb
                                    ? primaryColor
                                    : context.color.accentContrastColor),
                          ),
                        ],
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.width / 1.7),
                    child: CustomNetworkImage(
                      imageUrl: filePath,
                      radius: 12,
                      fit: BoxFit.fitWidth,
                      loadingHeight: (context.width / 1.7) * .5,
                      loadingWidth: context.width / 1.7,
                      color: mutedPrimaryColor,
                      errorWidget: SquircleContainer(
                          height: 200,
                          width: 200,
                          color: mutedPrimaryColor,
                          radius: 12,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: context.color.tertiaryContrastColo,
                          )),
                    ),
                  ),
          );
  }

  bool isImageUrl(String url) {
    return url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.gif');
  }

  bool isImageFile(String path) {
    return path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png') ||
        path.toLowerCase().endsWith('.gif');
  }
}
