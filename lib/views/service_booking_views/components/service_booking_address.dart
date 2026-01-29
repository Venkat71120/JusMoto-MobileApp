import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/views/service_booking_views/components/address_select_sheet.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../utils/components/custom_squircle_widget.dart';
import '../../../utils/components/field_label.dart';
import '../../../view_models/service_booking_view_model/service_booking_view_model.dart';

class ServiceBookingAddress extends StatelessWidget {
  const ServiceBookingAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final svm = ServiceBookingViewModel.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: LocalKeys.address,
          isRequired: true,
        ),
        8.toHeight,
        ValueListenableBuilder(
          valueListenable: svm.selectedAddress,
          builder: (context, value, child) {
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.color.accentContrastColor,
                  builder: (context) {
                    return AddressSelectSheet(
                        selectedAddress: svm.selectedAddress);
                  },
                );
              },
              child: SquircleContainer(
                  radius: 10,
                  padding: 8.paddingAll,
                  margin: const EdgeInsets.only(bottom: 16),
                  borderColor: context.color.primaryBorderColor,
                  child: Row(
                    children: [
                      (value?.type?.toString() == "1"
                              ? SvgAssets.addressOffice
                              : SvgAssets.addressHome)
                          .toSVGSized(24,
                              color: context.color.secondaryContrastColor),
                      6.toWidth,
                      Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(value?.title ?? LocalKeys.selectAddress,
                                  style: context.titleSmall?.bold),
                              if (value?.address != null)
                                Text(value!.address!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.bodySmall),
                            ],
                          )),
                      6.toWidth,
                      (value == null ? SvgAssets.arrowDown : SvgAssets.pencil)
                          .toSVGSized(20,
                              color: context.color.tertiaryContrastColo),
                    ],
                  )),
            );
          },
        ),
      ],
    );
  }
}
