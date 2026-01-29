import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class RrListSkeleton extends StatelessWidget {
  const RrListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        Expanded(
            child: Container(
          color: context.color.accentContrastColor,
          child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    context.color.mutedContrastColor,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextSkeleton(
                                    height: 14,
                                    width: 120,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextSkeleton(
                                    height: 14,
                                    width: 72,
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          TextSkeleton(
                            height: 12,
                            width: context.width * .8,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextSkeleton(
                            height: 12,
                            width: context.width * .55,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const TextSkeleton(
                            height: 12,
                            width: 56,
                          ),
                        ],
                      )),
                  separatorBuilder: (context, index) =>
                      const SizedBox().divider.hp20,
                  itemCount: 15)
              .shim,
        ))
      ],
    );
  }
}
