import 'dart:io';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/support_models/ticket_messages_model.dart';
import 'package:car_service/services/conversation_service.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../customizations/colors.dart';
import 'ticket_attachment_bubble.dart';

class TicketChatBubble extends StatelessWidget {
  final bool senderFromWeb;
  final int index;
  final TicketMessage datum;
  final bool sameUser;
  final dynamic id;
  const TicketChatBubble({
    required this.senderFromWeb,
    required this.datum,
    required this.index,
    super.key,
    this.sameUser = false,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if ((datum.attachment != null &&
                (datum.attachment is File ||
                    datum.attachment.toString().isNotEmpty)) ||
            ((datum.message != null && datum.message!.isNotEmpty)))
          Row(
            mainAxisAlignment:
                senderFromWeb ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                senderFromWeb
                    ? widgetList(context, datum.message)
                    : widgetList(context, datum.message).reversed.toList(),
          ),
      ],
    );
  }

  widgetList(BuildContext context, message) {
    final cs = Provider.of<ConversationService>(context, listen: false);
    final ValueNotifier messageClicked = ValueNotifier(null);
    return [
      12.toWidth,
      Column(
        crossAxisAlignment:
            senderFromWeb ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message != null)
            GestureDetector(
              onTap: () {
                if (datum.id == messageClicked.value) {
                  messageClicked.value = null;
                  return;
                }
                messageClicked.value = datum.id;
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

          if (datum.attachment != null &&
              (datum.attachment is File ||
                  datum.attachment.toString().isNotEmpty))
            GestureDetector(
              child: TicketAttachmentBubble(
                file: datum.attachment,
                senderFromWeb: senderFromWeb,
              ),
            ),
          4.toHeight,
          ValueListenableBuilder(
            valueListenable: messageClicked,
            builder: (context, value, child) {
              if (value != datum.id) {
                return const SizedBox();
              }
              return Text(
                DateFormat("EEEE, hh:mm aa").format(DateTime.now()),
                style: context.bodySmall,
              );
            },
          ),
        ],
      ),
    ];
  }
}
