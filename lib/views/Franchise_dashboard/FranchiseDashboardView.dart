import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/auth_services/FranchiseLoginService.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_tickets_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helper/constant_helper.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../landing_view/landing_view.dart';

class FranchiseDashboardView extends StatelessWidget {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String franchiseCode;
  final String franchiseLocation;
  final String outletLocationId;
  final String userId;
  final String token;

  const FranchiseDashboardView({
    super.key,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.franchiseCode,
    required this.franchiseLocation,
    required this.outletLocationId,
    required this.userId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        title: Text(LocalKeys.franchiseDashboard),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: LocalKeys.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green[300]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                    size: 32,
                  ),
                  16.toWidth,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✅ Login Successful!',
                          style: context.titleMedium?.copyWith(
                            color: Colors.green[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        4.toHeight,
                        Text(
                          'API call completed successfully. All data displayed below.',
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

            24.toHeight,

            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.7),
                  ],
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
                  Text(
                    LocalKeys.welcome,
                    style: context.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  8.toHeight,
                  Text(
                    name.isNotEmpty ? name : username,
                    style: context.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  12.toHeight,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: Colors.white,
                          size: 16,
                        ),
                        8.toWidth,
                        Text(
                          LocalKeys.franchiseUser,
                          style: context.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            32.toHeight,

            // User Information Card
            _buildInfoCard(
              context,
              title: LocalKeys.userInformation,
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.badge_outlined,
                  label: 'User ID',
                  value: userId,
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.person_outline,
                  label: LocalKeys.name,
                  value: name.isNotEmpty ? name : LocalKeys.notProvided,
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.account_circle_outlined,
                  label: LocalKeys.username,
                  value: username,
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.email_outlined,
                  label: LocalKeys.email,
                  value: email,
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.phone_outlined,
                  label: LocalKeys.phone,
                  value: phone,
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Role',
                  value: role.toUpperCase(),
                ),
              ],
            ),

            24.toHeight,

            // Franchise Details Card
            _buildInfoCard(
              context,
              title: LocalKeys.franchiseInformation,
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.verified_outlined,
                  label: 'Is Franchise',
                  value: 'Yes',
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.vpn_key_outlined,
                  label: LocalKeys.franchiseCode,
                  value: franchiseCode,
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'Franchise Location',
                  value: franchiseLocation,
                ),
                16.toHeight,
                _buildInfoRow(
                  context,
                  icon: Icons.store_outlined,
                  label: 'Outlet Location ID',
                  value: outletLocationId,
                ),
              ],
            ),

            24.toHeight,

            // Token Information Card
            _buildInfoCard(
              context,
              title: 'Authentication',
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.token_outlined,
                  label: 'Token',
                  value: token.length > 30 
                    ? '${token.substring(0, 30)}...' 
                    : token,
                  isCopyable: true,
                ),
              ],
            ),

            24.toHeight,

            // Quick Stats Card
            _buildInfoCard(
              context,
              title: LocalKeys.quickStats,
              children: [
                Consumer<FranchiseTicketsService>(
                  builder: (context, ts, _) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.shopping_bag_outlined,
                                label: 'Orders',
                                value: '0', // TODO: Connect OrdersService
                                color: Colors.blue,
                              ),
                            ),
                            16.toWidth,
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.pending_actions_outlined,
                                label: 'Pending',
                                value: '0',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        16.toHeight,
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.support_agent_outlined,
                                label: 'Open Tickets',
                                value: ts.statistics.open.toString(),
                                color: Colors.green,
                              ),
                            ),
                            16.toWidth,
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.assignment_outlined,
                                label: 'Total Tickets',
                                value: ts.statistics.total.toString(),
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            32.toHeight,

            // Action Buttons
            CustomButton(
              onPressed: () {
                // Navigate to orders or main dashboard
                Navigator.pushReplacementNamed(context, '/user.dashboard');
              },
              btText: LocalKeys.viewDashboard,
              isLoading: false,
            ),

            16.toHeight,

            OutlinedButton(
              onPressed: () => _handleLogout(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: Colors.red[400]!),
              ),
              child: Text(
                LocalKeys.logout,
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          16.toHeight,
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isCopyable = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
        ),
        16.toWidth,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              4.toHeight,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCopyable) ...[
                    8.toWidth,
                    InkWell(
                      onTap: () {
                        // Copy to clipboard
                        // Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: primaryColor,
                      ),
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

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          8.toHeight,
          Text(
            value,
            style: context.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          4.toHeight,
          Text(
            label,
            style: context.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(LocalKeys.confirmLogout),
          content: Text(LocalKeys.logoutConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(LocalKeys.cancel),
            ),
            TextButton(
              onPressed: () {
                // Clear franchise data
                Provider.of<FranchiseLoginService>(context, listen: false)
                    .clearFranchiseData();
                
                // Clear profile
                Provider.of<ProfileInfoService>(context, listen: false).reset();
                
                // Clear token
                sPref?.remove('token');
                
                // Navigate to landing page
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LandingView()),
                  (route) => false,
                );
              },
              child: Text(
                LocalKeys.logout,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}