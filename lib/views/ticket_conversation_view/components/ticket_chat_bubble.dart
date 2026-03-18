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
    final isAdmin = senderFromWeb;
    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAdmin ? context.color.accentContrastColor : primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 0 : 16),
            bottomRight: Radius.circular(isAdmin ? 16 : 0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (datum.message != null && datum.message!.isNotEmpty)
              Text(
                datum.message!.trim(),
                style: context.bodySmall?.copyWith(
                  color: isAdmin ? context.color.primaryContrastColor : Colors.white,
                  height: 1.4,
                ),
              ),
            if (datum.attachment != null && datum.attachment.toString().isNotEmpty) ...[
              if (datum.message != null && datum.message!.isNotEmpty) 8.toHeight,
              TicketAttachmentBubble(
                file: datum.attachment,
                senderFromWeb: senderFromWeb,
              ),
            ],
            4.toHeight,
            Text(
              DateFormat("EEEE, hh:mm aa").format(datum.createdAt ?? DateTime.now()),
              style: TextStyle(
                color: isAdmin ? Colors.grey[500] : Colors.white70,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
