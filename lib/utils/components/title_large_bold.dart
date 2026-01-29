import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';

class TitleLargeBold extends StatelessWidget {
  final label;
  const TitleLargeBold({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.asProvider.getString(label),
      style: context.titleLarge!.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
