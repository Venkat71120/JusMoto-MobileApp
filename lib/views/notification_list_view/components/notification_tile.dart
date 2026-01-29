import 'package:badges/badges.dart' as badges;
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/models/notification_models/notification_list_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../services/support_services/ticket_conversation_service.dart';
import '../../order_details_view/order_details_view.dart';
import '../../ticket_conversation_view/ticket_conversation_view.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint(notification.type.toString());
        switch (notification.type) {
          case "order":
            context.toPage(OrderDetailsView(
              orderId: notification.identity,
            ));
            break;
          case "ticket":
            Provider.of<TicketConversationService>(context, listen: false)
                .fetchSingleTickets(context, notification.identity);
            context.toPage(TicketConversationView(
              id: notification.identity,
              title: "",
            ));
            break;
          default:
        }
      },
      child: Container(
        color: context.color.accentContrastColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              badges.Badge(
                position: badges.BadgePosition.custom(end: 2),
                showBadge: notification.isRead,
                badgeStyle: badges.BadgeStyle(
                    badgeColor: context.color.primaryWarningColor),
                child: SvgAssets.notificationBell.toSVGSized(
                  24,
                  color: context.color.tertiaryContrastColo,
                ),
              ),
              16.toWidth,
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message ?? LocalKeys.na,
                        style: context.titleMedium?.bold.copyWith(),
                      ),
                      4.toHeight,
                      Text(
                        timeago
                            .format(notification.createdAt ?? DateTime.now()),
                        style: context.titleSmall?.copyWith(),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
