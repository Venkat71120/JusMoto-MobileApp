import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/custom_service_request_model.dart';
import 'package:car_service/services/custom_service_request_service.dart';
import 'package:car_service/services/support_services/ticket_conversation_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/views/ticket_conversation_view/ticket_conversation_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyServiceRequestsView extends StatelessWidget {
  const MyServiceRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final service =
        Provider.of<CustomServiceRequestService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: const Text("My Service Requests"),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () => service.fetchRequests(),
        child: SafeArea(
          child: CustomFutureWidget(
            function:
                service.shouldAutoFetch ? service.fetchRequests() : null,
            child: Consumer<CustomServiceRequestService>(
              builder: (context, svc, child) {
                if (svc.requests.isEmpty) {
                  return const EmptyWidget(
                      title: "No service requests yet");
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: svc.requests.length,
                  separatorBuilder: (_, __) => 12.toHeight,
                  itemBuilder: (context, index) {
                    return _ServiceRequestTile(
                        request: svc.requests[index]);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceRequestTile extends StatelessWidget {
  final CustomServiceRequest request;
  const _ServiceRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      radius: 12,
      borderColor: context.color.primaryBorderColor,
      color: context.color.accentContrastColor,
      child: Column(
        children: [
          // Top: description + status
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                SquircleContainer(
                  height: 48,
                  width: 48,
                  radius: 10,
                  color: primaryColor.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.build_outlined,
                    size: 24,
                    color: primaryColor,
                  ),
                ),
                12.toWidth,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Custom Service Request",
                              style: context.titleSmall?.bold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          6.toWidth,
                          _StatusBadge(status: request.status),
                        ],
                      ),
                      6.toHeight,
                      Text(
                        request.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodySmall?.copyWith(
                          color: context.color.secondaryContrastColor,
                        ),
                      ),
                      if (request.adminNote != null &&
                          request.adminNote!.isNotEmpty) ...[
                        6.toHeight,
                        Text(
                          "Admin: ${request.adminNote}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodySmall?.copyWith(
                            color: primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
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
          // Bottom: time + chat button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: context.color.secondaryContrastColor,
                ),
                4.toWidth,
                Expanded(
                  child: Text(
                    request.createdAt.isNotEmpty
                        ? timeago.format(
                            DateTime.tryParse(request.createdAt) ??
                                DateTime.now(),
                            locale: context.dProvider.languageSlug,
                          )
                        : "",
                    style: context.bodySmall?.copyWith(
                      color: context.color.secondaryContrastColor,
                    ),
                  ),
                ),
                if (request.isChatEnabled)
                  GestureDetector(
                    onTap: () {
                      Provider.of<TicketConversationService>(context,
                              listen: false)
                          .fetchSingleTickets(context, request.ticketId);
                      context.toPage(TicketConversationView(
                        id: request.ticketId,
                        title: "Custom Service Request",
                        status: "open",
                      ));
                    },
                    child: SquircleContainer(
                      radius: 8,
                      color: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          4.toWidth,
                          Text(
                            "Chat",
                            style: context.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (request.isPending)
                  Text(
                    "Awaiting response",
                    style: context.bodySmall?.copyWith(
                      color: context.color.mutedContrastColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = context.color.mutedPendingColor;
        textColor = context.color.primaryPendingColor;
        label = "Pending";
        break;
      case 'accepted':
      case 'open':
      case 'in_progress':
        bgColor = mutedPrimaryColor;
        textColor = primaryColor;
        label = status == 'in_progress' ? "In Progress" : "Accepted";
        break;
      case 'completed':
      case 'closed':
        bgColor = context.color.mutedSuccessColor;
        textColor = context.color.primarySuccessColor;
        label = "Completed";
        break;
      case 'cancelled':
      case 'rejected':
        bgColor = context.color.mutedWarningColor;
        textColor = context.color.primaryWarningColor;
        label = status == 'rejected' ? "Rejected" : "Cancelled";
        break;
      default:
        bgColor = mutedPrimaryColor;
        textColor = primaryColor;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
