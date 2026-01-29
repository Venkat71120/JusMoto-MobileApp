import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '/utils/components/empty_spacer_helper.dart';
import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../utils/components/field_label.dart';

class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.timeNotifier,
    this.fieldLabel,
    this.hintText,
    this.isRequired = false,
  });

  final ValueNotifier<TimeOfDay?> timeNotifier;
  final String? fieldLabel;
  final String? hintText;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: fieldLabel ?? LocalKeys.time,
          isRequired: isRequired,
        ),
        ValueListenableBuilder(
          valueListenable: timeNotifier,
          builder: (context, value, child) {
            return InkWell(
              onTap: () async {
                if (value != null) {
                  timeNotifier.value = null;
                  LocalKeys.fileRemoved.showToast();
                  return;
                }
                final now = TimeOfDay.now();
                try {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: now,
                  );
                  if (time == null) {
                    return;
                  }
                  timeNotifier.value = time;
                  LocalKeys.timeSelected.showToast();
                } catch (error) {
                  LocalKeys.failedToSelectTime.showToast();
                }
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.color.primaryBorderColor,
                    )),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SvgAssets.calendar.toSVG,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: context.width - (context.width / 1.8),
                        child: Text(
                          value != null
                              ? value.format(context)
                              : hintText ?? LocalKeys.selectTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleSmall?.copyWith(
                            color: context.color.primaryContrastColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        EmptySpaceHelper.emptyHeight(16),
      ],
    );
  }
}
