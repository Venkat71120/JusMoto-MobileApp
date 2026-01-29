import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/views/add_edit_address_view/add_edit_address_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/address_models/address_model.dart';
import '../../../services/google_location_search_service.dart';
import '../../../view_models/add_edit_address_view_model/add_edit_address_view_model.dart';

class AddressTile extends StatelessWidget {
  final Address address;
  const AddressTile({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final aea = AddEditAddressViewModel.instance;
    return SquircleContainer(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(8),
      radius: 8,
      color: context.color.accentContrastColor,
      child: Row(
        children: [
          (address.type.toString() == "1"
                  ? SvgAssets.addressOffice
                  : SvgAssets.addressHome)
              .toSVGSized(24, color: context.color.tertiaryContrastColo),
          8.toWidth,
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.title ?? LocalKeys.address,
                  style: context.titleSmall?.bold,
                ),
                Text(
                  address.address ?? "---",
                  style: context.bodySmall,
                ),
              ],
            ),
          ),
          8.toWidth,
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case "edit":
                  aea.initAddress(address);
                  Provider.of<GoogleLocationSearch>(context, listen: false)
                      .setFromAddress(address)
                      .then((_) {
                    debugPrint((Provider.of<GoogleLocationSearch>(context,
                                listen: false)
                            .geoLoc
                            ?.lat)
                        .toString());
                    context.toPage(const AddEditAddressView());
                  });

                  break;
                default:
                  aea.tryRemovingAddress(context, address.id);
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      SvgAssets.pencil.toSVGSized(20,
                          color: context.color.tertiaryContrastColo),
                      6.toWidth,
                      Text(
                        LocalKeys.editAddress,
                        style: context.titleSmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "remove",
                  child: Row(
                    children: [
                      SvgAssets.trash.toSVGSized(20,
                          color: context.color.primaryWarningColor),
                      6.toWidth,
                      Text(
                        LocalKeys.removeAddress,
                        style: context.titleSmall?.copyWith(
                          color: context.color.primaryWarningColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          )
        ],
      ),
    );
  }
}
