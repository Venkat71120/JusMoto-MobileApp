// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_home_app_bar.dart
// Location: lib/views/Franchise_home_view/components/franchise_home_app_bar.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/auth_services/FranchiseLoginService.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/view_models/franchise_home_view_model/franchise_home_view_model.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FranchiseHomeAppBar extends StatelessWidget {
  const FranchiseHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final hvm = FranchiseHomeViewModel.instance;
    
    // ✅ Add scroll listener for color animation (same as HomeAppBar)
    hvm.scrollController.addListener(() {
      hvm.appBarSize.value = hvm.scrollController.offset;
    });
    
    return ValueListenableBuilder(
      valueListenable: hvm.appBarSize,
      builder: (context, value, child) {
        final color = value < 200
            ? context.color.accentContrastColor
            : context.color.secondaryContrastColor;
            
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Consumer<FranchiseLoginService>(
            builder: (context, flService, child) {
              final displayName = flService.name.isNotEmpty 
                  ? flService.name 
                  : flService.username;
              final profileImage = flService.image;
              
              return AppBar(
                centerTitle: false,
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: profileImage != null && profileImage.isNotEmpty
                        ? null
                        : Border.all(
                            color: context.color.accentContrastColor,
                          ),
                  ),
                  child: CustomNetworkImage(
                    height: 40,
                    width: 40,
                    radius: 26,
                    userPreloader: true,
                    imageUrl: profileImage,
                    fit: BoxFit.cover,
                    name: flService.name.isNotEmpty ? flService.name : flService.username,
                  ),
                ),
                systemOverlayStyle: value < 200
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      LocalKeys.welcomeBack,
                      style: context.bodyMedium?.copyWith(
                        color: color.withOpacity(.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    4.toHeight,
                    RichText(
                      text: TextSpan(
                        text: displayName.isNotEmpty 
                            ? "$displayName !"
                            : "Franchise User !",
                        style: context.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  // ✅ Franchise Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: value < 200 
                          ? Colors.white.withOpacity(0.2)
                          : primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: value < 200
                            ? Colors.white.withOpacity(0.3)
                            : primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: value < 200 ? Colors.white : primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Franchise',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: value < 200 ? Colors.white : primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  12.toWidth,
                  
                  // ✅ Logout Button
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: Icon(
                      Icons.logout,
                      color: color,
                      size: 22,
                    ),
                    tooltip: LocalKeys.logout,
                  ),
                  8.toWidth,
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              onPressed: () async {
                // Clear franchise data
                await Provider.of<FranchiseLoginService>(context, listen: false)
                    .clearFranchiseData();
                
                // Clear profile
                Provider.of<ProfileInfoService>(context, listen: false).reset();
                
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