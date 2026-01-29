import 'package:car_service/utils/components/empty_spacer_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SocialSignInButton extends StatelessWidget {
  final image;
  final title;
  final onTap;
  const SocialSignInButton({
    required this.title,
    required this.image,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier isLoading = ValueNotifier(false);
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) => OutlinedButton(
          onPressed: value
              ? null
              : () async {
                  isLoading.value = true;
                  if (onTap != null) {
                    await onTap();
                  }
                  await Future.delayed(3.seconds);
                  isLoading.value = false;
                },
          child: value
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 24,
                        child: FittedBox(child: CircularProgressIndicator())),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (image != null) ...[
                      SizedBox(
                        height: 24,
                        child: Image.asset(
                          'assets/icons/$image.png',
                        ),
                      ),
                      EmptySpaceHelper.emptyWidth(12)
                    ],
                    Text(title),
                  ],
                )),
    );
  }
}
