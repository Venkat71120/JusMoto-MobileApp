import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../helper/image_assets.dart';

class EmptyElement extends StatelessWidget {
  final String text;
  const EmptyElement({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ImageAssets.emptyList.toAImage(),
        ),
        Text(
          text,
          style: context.titleSmall,
        ),
      ],
    );
  }
}
