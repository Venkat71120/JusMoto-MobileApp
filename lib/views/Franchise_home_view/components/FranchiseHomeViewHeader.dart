// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_home_view_header.dart
// Location: lib/views/Franchise_home_view/components/franchise_home_view_header.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/image_assets.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/auth_services/FranchiseLoginService.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../views/home_view/components/home_header_painter.dart';

class FranchiseHomeViewHeader extends StatelessWidget {
  const FranchiseHomeViewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // ✅ 1. Background with painter (bottom layer)
        Container(
          margin: EdgeInsets.only(bottom: 28),
          width: context.width,
          decoration: BoxDecoration(
            color: primaryColor,
            image: DecorationImage(
              image: ImageAssets.logoPattern.toAsset,
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Stack(
            children: [
              Transform.flip(
                flipX: dProvider.textDirectionRight,
                child: CustomPaint(
                  size: Size(
                    (context.width * .8),
                    (context.width * 0.8).toDouble(),
                  ),
                  painter: HomeHeaderPainter(
                    color: primaryColor,
                    sizes: Size(
                      (context.width * .8),
                      (context.width * 0.8).toDouble(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // ✅ 2. Car image (middle layer) - MOVED BEFORE THE CARD
        Positioned(
          right: dProvider.textDirectionRight ? null : 0,
          left: dProvider.textDirectionRight ? 0 : null,
          bottom: 32,
          child: Opacity(
            opacity: 0.8, // ✅ Slightly transparent so card shows through
            child: Transform.flip(
              flipX: dProvider.textDirectionRight,
              child: ImageAssets.headerCar.toAImage(),
            ),
          ),
        ),
        
        // ✅ 3. Franchise Info Card (top layer) - MOVED TO END
        Positioned(
          right: 0,
          bottom: 0,
          left: 0, // ✅ Added left: 0 for proper centering
          child: const FranchiseInfoCard(),
        ),
      ],
    );
  }
}

// ✅ Franchise Info Card (replaces HomeSearchField)
class FranchiseInfoCard extends StatelessWidget {
  const FranchiseInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseLoginService>(
      builder: (context, flService, child) {
        final displayName = flService.name.isNotEmpty 
            ? flService.name 
            : flService.username;
        final franchiseCode = flService.franchiseCode;
        final franchiseLocation = flService.franchiseLocation;

        return SquircleContainer(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(16),
          color: context.color.accentContrastColor,
          radius: 22,
          child: Row(
            children: [
              // ✅ Franchise Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store_outlined,
                  size: 24,
                  color: primaryColor,
                ),
              ),
              
              16.toWidth,
              
              // ✅ Franchise Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalKeys.welcomeBack,
                      style: context.bodySmall?.copyWith(
                        color: context.color.secondaryContrastColor.withOpacity(0.6),
                      ),
                    ),
                    4.toHeight,
                    Text(
                      displayName.isNotEmpty ? displayName : 'Franchise User',
                      style: context.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.color.primaryContrastColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (franchiseCode.isNotEmpty) ...[
                      6.toHeight,
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              franchiseCode,
                              style: context.bodySmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (franchiseLocation.isNotEmpty) ...[
                            8.toWidth,
                            Expanded(
                              child: Text(
                                franchiseLocation,
                                style: context.bodySmall?.copyWith(
                                  color: context.color.secondaryContrastColor.withOpacity(0.5),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // ✅ Franchise Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 12,
                      color: Colors.white,
                    ),
                    4.toWidth,
                    Text(
                      'Franchise',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}