import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/support_services/ticket_list_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/views/support_ticket_view/components/ticket_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/ticket_list_skeleton.dart';

class SupportTicketView extends StatelessWidget {
  const SupportTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    final tlProvider = Provider.of<TicketListService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.supportTicket),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await tlProvider.fetchTicketList();
        },
        child: SafeArea(
            child: Container(
          padding: 24.paddingH,
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Consumer<TicketListService>(
                builder: (context, tl, child) {
                  return Row(
                    children: [
                      _FilterChip(
                        label: "All",
                        isSelected: tl.activeFilter == "all",
                        onTap: () => tl.setFilter("all"),
                      ),
                      8.toWidth,
                      _FilterChip(
                        label: "Open",
                        isSelected: tl.activeFilter == "open",
                        onTap: () => tl.setFilter("open"),
                      ),
                      8.toWidth,
                      _FilterChip(
                        label: "Closed",
                        isSelected: tl.activeFilter == "closed",
                        onTap: () => tl.setFilter("closed"),
                      ),
                    ],
                  );
                },
              ),
              Expanded(
                  child: CustomFutureWidget(
                function: tlProvider.shouldAutoFetch
                    ? tlProvider.fetchTicketList()
                    : null,
                shimmer: const TicketListSkeleton(),
                child:
                    Consumer<TicketListService>(builder: (context, tl, child) {
                  return tl.ticketListModel.tickets.isEmpty
                      ? EmptyWidget(title: LocalKeys.noTicketsFound)
                      : CustomScrollView(
                          slivers: [
                            24.toHeight.toSliver,
                            SliverList.separated(
                              itemBuilder: (context, index) {
                                final ticket =
                                    tl.ticketListModel.tickets[index];
                                return TicketTile(ticket: ticket);
                              },
                              separatorBuilder: (context, index) => 12.toHeight,
                              itemCount: tl.ticketListModel.tickets.length,
                            ),
                            24.toHeight.toSliver,
                            if (tl.nextPage != null && !tl.nexLoadingFailed)
                              const ScrollPreloader(loading: false).toSliver,
                          ],
                        );
                }),
              ))
            ],
          ),
        )),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : mutedPrimaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: context.bodySmall?.copyWith(
            color: isSelected ? Colors.white : primaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
