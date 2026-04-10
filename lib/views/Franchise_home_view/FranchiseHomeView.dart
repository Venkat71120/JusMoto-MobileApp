// ─────────────────────────────────────────────────────────────────────────────
// VIEW: franchise_home_view.dart
// Location: lib/views/Franchise_home_view/FranchiseHomeView.dart
//
// Uses franchise-specific header and app bar instead of regular user components
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_dashboard_service.dart';
import 'package:car_service/services/theme_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/view_models/franchise_home_view_model/franchise_home_view_model.dart';
import 'package:car_service/views/Franchise_home_view/components/FranchiseHomeViewHeader.dart';
import 'package:car_service/views/Franchise_home_view/components/activity_v2.dart';
import 'package:car_service/views/Franchise_home_view/components/franchise_earnings_section.dart';
import 'package:car_service/views/Franchise_home_view/components/franchise_home_app_bar.dart';
// import 'package:car_service/views/Franchise_home_view/components/franchise_home_view_header.dart';
import 'package:car_service/views/Franchise_home_view/components/franchise_order_breakdown.dart';
import 'package:car_service/views/Franchise_home_view/components/franchise_stats_skeleton.dart';
import 'package:car_service/views/Franchise_home_view/components/franchise_summary_stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Admin_quotes_view/admin_quote_list_view.dart';

class FranchiseHomeView extends StatelessWidget {
  const FranchiseHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final hvm = FranchiseHomeViewModel.instance;

    return Consumer<ThemeService>(
      builder: (context, ts, child) {
        return CustomRefreshIndicator(
          onRefresh: () async {
            await Provider.of<FranchiseDashboardService>(
              context,
              listen: false,
            ).refresh();
          },
          child: Container(
            height: context.height,
            color: ts.selectedTheme.backgroundColor,
            child: CustomScrollView(
              controller: hvm.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Franchise-specific SliverAppBar ───────────────────
                SliverAppBar(
                  expandedHeight: 244,
                  pinned: true,
                  leadingWidth: 0,
                  automaticallyImplyLeading: false,
                  title: const FranchiseHomeAppBar(),
                  backgroundColor: ts.selectedTheme.backgroundColor,
                  flexibleSpace: const FlexibleSpaceBar(
                    background: FranchiseHomeViewHeader(),
                  ),
                ),

                // ── Dashboard content ─────────────────────────────────
                SliverList(
                  delegate: SliverChildListDelegate([
                    Consumer<FranchiseDashboardService>(
                      builder: (context, ds, child) {
                        // ── Auto-fetch on first render ────────────────
                        if (ds.shouldAutoFetch) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ds.fetchDashboard();
                          });
                        }

                        // ── Loading skeleton ──────────────────────────
                        if (ds.isLoading && ds.shouldAutoFetch) {
                          return const FranchiseStatsSkeleton();
                        }

                        // ── Real content ──────────────────────────────
                        return Column(
                          children: [
                            // 1 — Summary stat cards (orders + tickets + earnings)
                            FranchiseSummaryStats(statistics: ds.statistics),

                            // 2 — Order breakdown (paid/unpaid/active/delivered)
                            FranchiseOrderBreakdown(
                              orderCounts: ds.orderCounts,
                            ),

                            // 3 — Earnings panel with period tabs
                            FranchiseEarningsSection(
                              earnings: ds.earnings,
                              hvm: hvm,
                              onPeriodChanged: (period) {
                                hvm.earningsPeriod.value = period;
                              },
                            ),

                            // 4 — Recent orders + tickets tabbed list
                            FranchiseActivitySection(
                              activity: ds.recentActivity,
                              hvm: hvm,
                            ),

                            const SizedBox(height: 16),
                            _buildManagementCard(
                              context,
                              'Quotes',
                              Icons.request_quote,
                              Colors.blueGrey,
                              const AdminQuoteListView(),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
