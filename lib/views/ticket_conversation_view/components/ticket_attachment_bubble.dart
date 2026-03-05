import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';

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
        debugPrint("file".toString());
        debugPrint(file.toString());
        if (file?.trim().isNotEmpty ?? false) {
          final Uri launchUri = Uri.parse(file!);
          await urlLauncher.launchUrl(
            launchUri,
            mode: urlLauncher.LaunchMode.externalApplication,
          );
        }
      },
      child:
          isImage
              ? Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: BoxConstraints(maxWidth: context.width / 1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        senderFromWeb
                            ? context.color.accentContrastColor
                            : primaryColor,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    file!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[500],
                        ),
                      );
                    },
                  ),
                ),
              )
              : SquircleContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color:
                    senderFromWeb
                        ? context.color.accentContrastColor
                        : primaryColor,
                margin: const EdgeInsets.only(top: 4),
                radius: 12,
                child: FittedBox(
                  child: Row(
                    children: [
                      SvgAssets.download.toSVGSized(
                        18,
                        color:
                            senderFromWeb
                                ? primaryColor
                                : context.color.accentContrastColor,
                      ),
                      6.toWidth,
                      Text(
                        LocalKeys.downloadAttachment,
                        textAlign: senderFromWeb ? null : TextAlign.end,
                        style: context.titleMedium?.copyWith(
                          fontSize: 14,
                          color:
                              senderFromWeb
                                  ? primaryColor
                                  : context.color.accentContrastColor,
                        ),
                      ),
                    ],
                  ),
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
