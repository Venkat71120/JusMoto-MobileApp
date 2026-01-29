import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/support_models/ticket_list_model.dart';
import 'package:flutter/material.dart';

import '../../../helper/svg_assets.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class TicketTileStatus extends StatelessWidget {
  final Ticket ticket;
  const TicketTileStatus({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        radius: 10,
        borderColor: ticket.status.toString().getTicketPrimaryStatusColor,
        color: ticket.status.toString().getTicketMutedStatusColor,
        child: FittedBox(
          child: Row(
            children: [
              Text(
                ticket.status.toString().getTicketStatus,
                style: context.bodySmall?.bold.copyWith(
                    color:
                        ticket.status.toString().getTicketPrimaryStatusColor),
              ),
              if (1 == 2) ...[
                4.toWidth,
                SvgAssets.arrowDown.toSVGSized(12,
                    color: ticket.status.toString().getTicketPrimaryStatusColor)
              ],
            ],
          ),
        ));
  }
}
