// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_stats_skeleton.dart
// Location: lib/views/Franchise_home_view/components/franchise_stats_skeleton.dart
//
// Loading shimmer — mirrors the ServicesHorizontalSkeleton / CategoryCardSkeleton 
// pattern: TextSkeleton + SquircleContainer + .shim extension
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class FranchiseStatsSkeleton extends StatelessWidget {
  const FranchiseStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header skeleton ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: TextSkeleton(height: 16, width: context.width * 0.3),
        ),

        // ── Two stat cards row ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _cardSkeleton(context)),
              12.toWidth,
              Expanded(child: _cardSkeleton(context)),
            ],
          ),
        ).shim,
        12.toHeight,

        // ── Full-width earnings skeleton ────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SquircleContainer(
            height: 100,
            width: double.infinity,
            radius: 14,
            color: context.color.mutedContrastColor,
            child: const SizedBox(),
          ),
        ).shim,
        20.toHeight,

        // ── Order breakdown skeleton ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SquircleContainer(
            height: 130,
            width: double.infinity,
            radius: 14,
            color: context.color.mutedContrastColor,
            child: const SizedBox(),
          ),
        ).shim,
        20.toHeight,

        // ── Earnings section skeleton ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SquircleContainer(
            height: 160,
            width: double.infinity,
            radius: 14,
            color: context.color.mutedContrastColor,
            child: const SizedBox(),
          ),
        ).shim,
        20.toHeight,

        // ── Activity section skeleton ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SquircleContainer(
                height: 220,
                width: double.infinity,
                radius: 14,
                color: context.color.mutedContrastColor,
                child: const SizedBox(),
              ),
            ],
          ),
        ).shim,
      ],
    );
  }

  Widget _cardSkeleton(BuildContext context) {
    return SquircleContainer(
      height: 110,
      radius: 14,
      color: context.color.mutedContrastColor,
      child: const SizedBox(),
    );
  }
}