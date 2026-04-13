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
                            _buildQuotesCard(context),
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

  Widget _buildQuotesCard(BuildContext context) {
    const color = Colors.indigo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminQuoteListView()),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.12),
                color.withOpacity(0.04),
                context.color.backgroundColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Decorative background circle
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Icon with complex container
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.request_quote_rounded,
                          color: color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quotes Management',
                              style: context.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: context.color.primaryContrastColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Review and respond to custom service requests',
                              style: context.bodySmall?.copyWith(
                                color: context.color.secondaryContrastColor.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow button
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: color,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
