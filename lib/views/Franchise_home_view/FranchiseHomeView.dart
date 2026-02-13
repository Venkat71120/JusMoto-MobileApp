import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/auth_services/FranchiseLoginService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FranchiseHomeView extends StatelessWidget {
  const FranchiseHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseLoginService>(
      builder: (context, franchise, child) {
        return Scaffold(
          backgroundColor: context.color.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App bar row ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalKeys.welcome,
                            style: context.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            franchise.name.isNotEmpty
                                ? franchise.name
                                : franchise.username,
                            style: context.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: primaryColor.withOpacity(0.15),
                        child: Text(
                          franchise.name.isNotEmpty
                              ? franchise.name[0].toUpperCase()
                              : franchise.username[0].toUpperCase(),
                          style: context.titleMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  20.toHeight,

                  // ── Success Banner ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[300]!, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[700], size: 28),
                        12.toWidth,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✅ Login Successful',
                                style: context.titleSmall?.copyWith(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              4.toHeight,
                              Text(
                                'API call completed. All data loaded below.',
                                style: context.bodySmall?.copyWith(
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  20.toHeight,

                  // ── Welcome gradient card ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user,
                                color: Colors.white, size: 18),
                            8.toWidth,
                            Text(
                              LocalKeys.franchiseUser,
                              style: context.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        8.toHeight,
                        Text(
                          franchise.name.isNotEmpty
                              ? franchise.name
                              : franchise.username,
                          style: context.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        4.toHeight,
                        Text(
                          franchise.franchiseLocation,
                          style: context.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  20.toHeight,

                  // ── Quick stat cards ───────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          context,
                          icon: Icons.shopping_bag_outlined,
                          label: LocalKeys.totalOrders,
                          value: '0',
                          color: Colors.blue,
                        ),
                      ),
                      12.toWidth,
                      Expanded(
                        child: _statCard(
                          context,
                          icon: Icons.pending_actions_outlined,
                          label: LocalKeys.pending,
                          value: '0',
                          color: Colors.orange,
                        ),
                      ),
                      12.toWidth,
                      Expanded(
                        child: _statCard(
                          context,
                          icon: Icons.check_circle_outline,
                          label: LocalKeys.complete,
                          value: '0',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  20.toHeight,

                  // ── User Information card ──────────────────────────────
                  _infoCard(
                    context,
                    title: LocalKeys.userInformation,
                    rows: [
                      _infoRow(context,
                          icon: Icons.badge_outlined,
                          label: 'User ID',
                          value: franchise.userId),
                      _infoRow(context,
                          icon: Icons.person_outline,
                          label: LocalKeys.name,
                          value: franchise.name.isNotEmpty
                              ? franchise.name
                              : LocalKeys.notProvided),
                      _infoRow(context,
                          icon: Icons.account_circle_outlined,
                          label: LocalKeys.username,
                          value: franchise.username),
                      _infoRow(context,
                          icon: Icons.email_outlined,
                          label: LocalKeys.email,
                          value: franchise.email),
                      _infoRow(context,
                          icon: Icons.phone_outlined,
                          label: LocalKeys.phone,
                          value: franchise.phone),
                      _infoRow(context,
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Role',
                          value: franchise.role.toUpperCase()),
                    ],
                  ),

                  16.toHeight,

                  // ── Franchise Details card ─────────────────────────────
                  _infoCard(
                    context,
                    title: LocalKeys.franchiseInformation,
                    rows: [
                      _infoRow(context,
                          icon: Icons.verified_outlined,
                          label: 'Is Franchise',
                          value: franchise.isFranchise ? 'Yes ✅' : 'No'),
                      _infoRow(context,
                          icon: Icons.vpn_key_outlined,
                          label: LocalKeys.franchiseCode,
                          value: franchise.franchiseCode),
                      _infoRow(context,
                          icon: Icons.location_on_outlined,
                          label: 'Franchise Location',
                          value: franchise.franchiseLocation),
                      _infoRow(context,
                          icon: Icons.store_outlined,
                          label: 'Outlet Location ID',
                          value: franchise.outletLocationId),
                    ],
                  ),

                  16.toHeight,

                  // ── Auth token card ────────────────────────────────────
                  _infoCard(
                    context,
                    title: 'Authentication',
                    rows: [
                      _infoRow(
                        context,
                        icon: Icons.token_outlined,
                        label: 'Token',
                        value: franchise.token.length > 30
                            ? '${franchise.token.substring(0, 30)}...'
                            : franchise.token,
                        isCopyable: true,
                        fullValue: franchise.token,
                      ),
                    ],
                  ),

                  32.toHeight,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _statCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          8.toHeight,
          Text(
            value,
            style: context.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          4.toHeight,
          Text(
            label,
            style:
                context.bodySmall?.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context,
      {required String title, required List<Widget> rows}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: context.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          16.toHeight,
          ...rows
              .expand((w) => [w, const SizedBox(height: 14)])
              .toList()
            ..removeLast(), // removes trailing spacer
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      bool isCopyable = false,
      String? fullValue}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: primaryColor),
        ),
        12.toWidth,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: context.bodySmall
                      ?.copyWith(color: Colors.grey[600])),
              4.toHeight,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: context.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCopyable) ...[
                    8.toWidth,
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Token copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Icon(Icons.copy, size: 16, color: primaryColor),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}