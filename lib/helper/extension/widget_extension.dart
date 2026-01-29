import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constant_helper.dart';

extension WidgetExtension on Widget {
  Widget get toSliver {
    return SliverToBoxAdapter(child: this);
  }
}

extension CreateShimmerExtension on Widget {
  Widget get shim {
    return animate(
      delay: 0.ms,
      autoPlay: true,
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: const Duration(seconds: 1),
      color: color.accentContrastColor.withOpacity(.65),
    );
  }
}

extension PaddingExtension on Widget {
  Widget get hp20 {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: this,
    );
  }
}

extension BottomModal on Widget {
  showBModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => this,
    );
  }
}

extension DividerExtension on Widget {
  Widget get divider {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        this,
        Divider(
          color: color.primaryBorderColor,
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }
}
