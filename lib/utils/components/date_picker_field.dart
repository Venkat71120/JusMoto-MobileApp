import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '/utils/components/empty_spacer_helper.dart';
import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../utils/components/field_label.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.dateNotifier,
    this.fieldLabel,
    this.hintText,
    this.firstDate,
    this.isRequired = false,
  });

  final ValueNotifier<DateTime?> dateNotifier;
  final String? fieldLabel;
  final String? hintText;
  final bool isRequired;
  final DateTime? firstDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: fieldLabel ?? LocalKeys.date,
          isRequired: isRequired,
        ),
        ValueListenableBuilder(
          valueListenable: dateNotifier,
          builder: (context, value, child) {
            return InkWell(
              onTap: () async {
                final now = DateTime.now();
                try {
                  final date = await showDatePicker(
                      context: context,
                      firstDate: firstDate ?? now,
                      initialDate: value ?? firstDate,
                      lastDate: DateTime(now.year + 1));
                  if (date == null) {
                    return;
                  }
                  dateNotifier.value = date;
                  LocalKeys.dateSelected.showToast();
                } catch (error) {
                  LocalKeys.fileSelectFailed.showToast();
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
                              ? DateFormat("EEE dd, MM, yyyy").format(value)
                              : hintText ?? LocalKeys.selectDate,
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
