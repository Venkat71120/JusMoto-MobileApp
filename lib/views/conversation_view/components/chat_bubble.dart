import 'dart:io';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/conversation_service.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/views/conversation_view/components/attachment_bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../customizations/colors.dart';
import '../../../models/conversation_model.dart';

class ChatBubble extends StatelessWidget {
  final bool senderFromWeb;
  final int index;
  final MessageModel datum;
  final clientImage;
  final name;
  final bool sameUser;
  const ChatBubble({
    required this.senderFromWeb,
    required this.datum,
    required this.index,
    super.key,
    required this.clientImage,
    required this.name,
    this.sameUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if ((datum.file != null &&
                (datum.file is File || datum.file.toString().isNotEmpty)) ||
            (((datum.message?.message ?? datum.messageText ?? "")
                .isNotEmpty)) ||
            ((datum.message?.project != null)))
          Row(
            mainAxisAlignment:
                senderFromWeb ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                senderFromWeb
                    ? widgetList(
                      context,
                      (datum.message?.message ?? datum.messageText),
                      clientImage.toString(),
                      name,
                    )
                    : widgetList(
                      context,
                      (datum.message?.message ?? datum.messageText),
                      clientImage.toString(),
                      name,
                    ).reversed.toList(),
          ),
      ],
    );
  }

  widgetList(BuildContext context, message, imageUrl, name) {
    ValueNotifier showDate = ValueNotifier(false);
    final cs = Provider.of<ConversationService>(context, listen: false);
    return [
      if (!sameUser)
        CustomNetworkImage(
          name: name,
          height: 32.0,
          width: 32.0,
          radius: 16,
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
      if (sameUser) 32.toWidth,
      12.toWidth,
      Column(
        crossAxisAlignment:
            senderFromWeb ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message != null && (name ?? "").trim().isNotEmpty)
            GestureDetector(
              onTap: () {
                debugPrint(datum.file..toString());
                showDate.value = !showDate.value;
              },
              child: SquircleContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                constraints: BoxConstraints(maxWidth: context.width / 1.7),
                color:
                    senderFromWeb
                        ? context.color.accentContrastColor
                        : primaryColor,
                radius: 12,
                child: Text(
                  message,
                  style: context.titleSmall?.copyWith(
                    color:
                        senderFromWeb
                            ? null
                            : context.color.accentContrastColor,
                  ),
                ),
              ),
            ),
          if (datum.file != null &&
              (datum.file is File || datum.file.toString().isNotEmpty)) ...[
            6.toHeight,
            AttachmentBubble(file: datum.file, senderFromWeb: senderFromWeb),
          ],
          ValueListenableBuilder(
            valueListenable: showDate,
            builder: (context, value, child) {
              return value
                  ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat(
                        "EEEE, hh:mm aa",
                      ).format(datum.createdAt ?? DateTime.now()),
                      style: context.bodySmall,
                    ),
                  )
                  : const SizedBox();
            },
          ),
        ],
      ),
    ];
  }
}
