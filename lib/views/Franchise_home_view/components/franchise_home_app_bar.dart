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
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/view_models/franchise_home_view_model/franchise_home_view_model.dart';
import 'package:car_service/view_models/Franchise_landing_view_model/FranchiseLandingViewModel.dart';
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
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 8,
            left: 20,
            right: 20,
          ),
          child: Consumer<FranchiseLoginService>(
            builder: (context, flService, child) {
              final displayName = flService.name.isNotEmpty 
                  ? flService.name 
                  : flService.username;
              final profileImage = flService.image;
              
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FranchiseLandingViewModel.instance.setNavIndex(3);
                },
                child: Row(
                children: [
                  // ✅ Profile Image
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: profileImage != null && profileImage.isNotEmpty
                          ? null
                          : Border.all(
                              color: context.color.accentContrastColor,
                            ),
                    ),
                    child: CustomNetworkImage(
                      height: 42,
                      width: 42,
                      radius: 26,
                      userPreloader: true,
                      imageUrl: profileImage,
                      fit: BoxFit.cover,
                      name: flService.name.isNotEmpty ? flService.name : flService.username,
                    ),
                  ),
                  12.toWidth,
                  
                  // ✅ Welcome Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocalKeys.welcomeBack,
                          style: context.bodySmall?.copyWith(
                            color: color.withOpacity(.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        2.toHeight,
                        Text(
                          displayName.isNotEmpty 
                              ? "$displayName !"
                              : "Franchise User !",
                          style: context.titleMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
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
                ],
              ),
              );
            },
          ),
        );
      },
    );
  }
}