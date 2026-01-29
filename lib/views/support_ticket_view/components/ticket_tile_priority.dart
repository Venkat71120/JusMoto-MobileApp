import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/support_models/ticket_list_model.dart';
import 'package:flutter/material.dart';

import '../../../helper/svg_assets.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class TicketTilePriority extends StatelessWidget {
  final Ticket ticket;
  const TicketTilePriority({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        radius: 10,
        borderColor: ticket.priority.toString().getTicketPrimaryPriorityColor,
        color: ticket.priority.toString().getTicketMutedPriorityColor,
        child: FittedBox(
          child: Row(
            children: [
              Text(
                ticket.priority?.capitalize.tr().toString() ?? LocalKeys.na,
                style: context.bodySmall?.bold.copyWith(
                    color: ticket.priority
                        .toString()
                        .getTicketPrimaryPriorityColor),
              ),
              if (1 == 2) ...[
                4.toWidth,
                SvgAssets.arrowDown.toSVGSized(12,
                    color: ticket.priority
                        .toString()
                        .getTicketPrimaryPriorityColor)
              ],
            ],
          ),
        ));
  }
}
