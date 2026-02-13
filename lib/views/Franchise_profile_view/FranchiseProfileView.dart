import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/auth_services/FranchiseLoginService.dart';
import 'package:car_service/view_models/Franchise_landing_view_model/FranchiseLandingViewModel.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/constant_helper.dart';
import '../../services/profile_services/profile_info_service.dart';
// import '../../view_models/franchise_landing_view_model/franchise_landing_view_model.dart';

class FranchiseProfileView extends StatelessWidget {
  const FranchiseProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseLoginService>(
      builder: (context, franchise, _) {
        return Scaffold(
          backgroundColor: context.color.backgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(LocalKeys.profile),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: LocalKeys.logout,
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: Text(
                    franchise.name.isNotEmpty
                        ? franchise.name[0].toUpperCase()
                        : franchise.username[0].toUpperCase(),
                    style: context.headlineMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                16.toHeight,
                Text(
                  franchise.name.isNotEmpty
                      ? franchise.name
                      : franchise.username,
                  style:
                      context.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                4.toHeight,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    franchise.role.toUpperCase(),
                    style: context.bodySmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                24.toHeight,

                // Profile info tiles
                _tile(context, Icons.account_circle_outlined,
                    LocalKeys.username, franchise.username),
                _tile(context, Icons.email_outlined,
                    LocalKeys.email, franchise.email),
                _tile(context, Icons.phone_outlined,
                    LocalKeys.phone, franchise.phone),
                _tile(context, Icons.vpn_key_outlined,
                    LocalKeys.franchiseCode, franchise.franchiseCode),
                _tile(context, Icons.location_on_outlined,
                    'Franchise Location', franchise.franchiseLocation),
                _tile(context, Icons.store_outlined,
                    'Outlet Location ID', franchise.outletLocationId),

                32.toHeight,

                // Logout button
                OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: BorderSide(color: Colors.red[400]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.logout, color: Colors.red[400]),
                  label: Text(
                    LocalKeys.logout,
                    style: TextStyle(color: Colors.red[400]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tile(
      BuildContext context, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: primaryColor),
          12.toWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
                4.toHeight,
                Text(
                  value,
                  style:
                      context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocalKeys.confirmLogout),
        content: Text(LocalKeys.logoutConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocalKeys.cancel),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FranchiseLoginService>(context, listen: false)
                  .clearFranchiseData();
              Provider.of<ProfileInfoService>(context, listen: false).reset();
              sPref?.remove('token');
              FranchiseLandingViewModel.dispose;
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const LandingView()),
                (route) => false,
              );
            },
            child: Text(
              LocalKeys.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}