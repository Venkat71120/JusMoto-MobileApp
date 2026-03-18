import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../../helper/local_keys.g.dart';

class TicketAttachmentBubble extends StatelessWidget {
  final String? file;
  final bool senderFromWeb;
  const TicketAttachmentBubble({
    super.key,
    this.file,
    this.senderFromWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isImage = file != null && isImageUrl(file!);

    return InkWell(
      onTap: () async {
        if (file?.trim().isNotEmpty ?? false) {
          final Uri launchUri = Uri.parse(file!);
          await urlLauncher.launchUrl(
            launchUri,
            mode: urlLauncher.LaunchMode.externalApplication,
          );
        }
      },
      child: isImage
          ? Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: BoxConstraints(maxWidth: context.width / 1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: senderFromWeb
                      ? context.color.accentContrastColor
                      : Colors.white24,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: CachedNetworkImage(
                  imageUrl: file!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.black12,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white24,
                      size: 32,
                    ),
                  ),
                ),
              ),
            )
          : SquircleContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              color: senderFromWeb
                  ? context.color.accentContrastColor.withOpacity(0.1)
                  : Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.only(top: 4),
              radius: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_present_rounded,
                    size: 18,
                    color: senderFromWeb ? primaryColor : Colors.white,
                  ),
                  8.toWidth,
                  Flexible(
                    child: Text(
                      LocalKeys.downloadAttachment,
                      style: context.titleMedium?.copyWith(
                        fontSize: 13,
                        color: senderFromWeb ? primaryColor : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
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
