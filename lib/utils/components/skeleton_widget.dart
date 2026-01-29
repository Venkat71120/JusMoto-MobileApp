import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';

class ShimmerWidget extends StatelessWidget {
  final width;
  final height;
  final color;
  const ShimmerWidget({super.key, this.height, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.toDouble(),
      height: height?.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color ?? context.color.backgroundColor,
      ),
    );
  }
}
