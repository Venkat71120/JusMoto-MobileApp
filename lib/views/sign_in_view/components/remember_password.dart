import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '../../../helper/local_keys.g.dart';

class RememberPassword extends StatelessWidget {
  const RememberPassword({
    super.key,
    required this.rememberPass,
  });

  final ValueNotifier rememberPass;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ValueListenableBuilder(
            valueListenable: rememberPass,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  value: value,
                  onChanged: (value) {
                    rememberPass.value = value;
                  },
                ),
              );
            },
          ),
        ),
        4.toWidth,
        Expanded(
          flex: 8,
          child: Text(
            LocalKeys.rememberMe,
            style: context.titleMedium,
          ),
        ),
      ],
    );
  }
}
