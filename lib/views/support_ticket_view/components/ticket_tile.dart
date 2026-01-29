import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/support_models/ticket_list_model.dart';
import 'package:car_service/services/support_services/ticket_conversation_service.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/views/support_ticket_view/components/ticket_tile_status.dart';
import 'package:car_service/views/ticket_conversation_view/ticket_conversation_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
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
        ));
      },
      child: SquircleContainer(
          padding: 12.paddingAll,
          radius: 10,
          color: context.color.accentContrastColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#${ticket.id}",
                    style:
                        context.bodySmall?.bold.copyWith(color: primaryColor),
                  ),
                  Text(
                    ticket.createdAt == null
                        ? ""
                        : timeago.format(ticket.createdAt!,
                            locale: context.dProvider.languageSlug),
                    style: context.bodySmall,
                  )
                ],
              ),
              4.toHeight,
              Text(
                ticket.title ?? LocalKeys.na,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.titleLarge?.bold,
              ),
              4.toHeight,
              ReadMoreText(ticket.description ?? LocalKeys.na,
                  trimMode: TrimMode.Line,
                  trimLines: 1,
                  colorClickableText: primaryColor,
                  trimCollapsedText: LocalKeys.showMore,
                  trimExpandedText: " ${LocalKeys.showLess}",
                  style: context.bodySmall),
              8.toHeight,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TicketTileStatus(ticket: ticket),
                  TicketTilePriority(ticket: ticket),
                ],
              )
            ],
          )),
    );
  }
}
