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
import 'package:car_service/views/create_ticekt_view/create_ticket_view.dart';
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
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.toPage(const CreateTicketView());
                    },
                    label: Text(LocalKeys.newTicket),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  )
                ],
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
