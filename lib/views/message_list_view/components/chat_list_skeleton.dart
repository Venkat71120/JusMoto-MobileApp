import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/widget_extension.dart';
import '/utils/components/skeleton_widget.dart';
import '../../../utils/components/empty_spacer_helper.dart';

class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: 16.paddingV,
                child: Row(
                  children: [
                    Container(
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                          color: context.color.mutedContrastColor,
                          shape: BoxShape.circle),
                    ),
                    EmptySpaceHelper.emptyWidth(12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerWidget(
                                color: context.color.mutedContrastColor,
                                height: 16,
                                width: context.width / 3,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextSkeleton(
                                height: 14,
                                width: context.width * .3,
                              ),
                              const Spacer(),
                              TextSkeleton(
                                height: 14,
                                width: context.width * .2,
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Padding(
                  padding: 24.paddingH,
                  child: Divider(
                    height: 2,
                    thickness: 2,
                    color: context.color.primaryBorderColor,
                  ),
                ),
            itemCount: 4)
        .shim;
  }
}
