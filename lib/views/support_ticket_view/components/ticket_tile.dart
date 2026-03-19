import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/models/support_models/ticket_list_model.dart';
import 'package:car_service/services/support_services/ticket_conversation_service.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/views/support_ticket_view/components/ticket_tile_status.dart';
import 'package:car_service/views/ticket_conversation_view/ticket_conversation_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'ticket_tile_priority.dart';

class TicketTile extends StatelessWidget {
  final Ticket ticket;
  const TicketTile({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<TicketConversationService>(context, listen: false)
            .fetchSingleTickets(context, ticket.id);
        context.toPage(TicketConversationView(
          id: ticket.id,
          title: ticket.title ?? "",
          status: ticket.status,
        ));
      },
      child: SquircleContainer(
        radius: 12,
        borderColor: context.color.primaryBorderColor,
        color: context.color.accentContrastColor,
        child: Column(
          children: [
            // Top section: icon + ticket details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ticket icon container
                  SquircleContainer(
                    height: 48,
                    width: 48,
                    radius: 10,
                    color: primaryColor.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: SvgAssets.ticket.toSVGSized(24, color: primaryColor),
                  ),
                  12.toWidth,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + status/priority badges
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                ticket.title ?? LocalKeys.na,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.titleSmall?.bold,
                              ),
                            ),
                            6.toWidth,
                            TicketTileStatus(ticket: ticket),
                          ],
                        ),
                        6.toHeight,
                        // Description
                        if (ticket.description != null &&
                            ticket.description!.isNotEmpty)
                          Text(
                            ticket.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodySmall?.copyWith(
                              color: context.color.secondaryContrastColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: context.color.primaryBorderColor,
            ),
            // Bottom section: priority, time, chevron
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  TicketTilePriority(ticket: ticket),
                  12.toWidth,
                  SvgAssets.clock.toSVGSized(14,
                      color: context.color.secondaryContrastColor),
                  4.toWidth,
                  Expanded(
                    child: Text(
                      ticket.createdAt == null
                          ? ""
                          : timeago.format(ticket.createdAt!,
                              locale: context.dProvider.languageSlug),
                      style: context.bodySmall?.copyWith(
                          color: context.color.secondaryContrastColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SvgAssets.chevron.toSVGSized(16,
                      color: context.color.secondaryContrastColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
