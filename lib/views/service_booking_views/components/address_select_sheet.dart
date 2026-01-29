import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/view_models/add_edit_address_view_model/add_edit_address_view_model.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:car_service/views/account_skeleton/account_skeleton.dart';
import 'package:car_service/views/add_edit_address_view/add_edit_address_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../models/address_models/address_model.dart';
import '../../../services/address_services/address_list_service.dart';
import '../../../utils/components/custom_future_widget.dart';
import '../../../utils/components/custom_preloader.dart';
import '../../../utils/components/empty_widget.dart';

class AddressSelectSheet extends StatefulWidget {
  final ValueNotifier<Address?> selectedAddress;
  const AddressSelectSheet({super.key, required this.selectedAddress});

  @override
  State<AddressSelectSheet> createState() => _AddressSelectSheetState();
}

class _AddressSelectSheetState extends State<AddressSelectSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressListService>(builder: (context, al, child) {
      return CustomFutureWidget(
        function: al.shouldAutoFetch ? al.fetchAddressList() : null,
        shimmer: const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CustomPreloader()),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Consumer<ProfileInfoService>(builder: (context, pi, child) {
            if (pi.profileInfoModel.userDetails == null) {
              return const Column(
                children: [AccountSkeleton()],
              );
            }
            return Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: context.color.mutedContrastColor,
                    ),
                  ),
                ),
                if (al.addressListModel.allLocations.isEmpty)
                  Column(
                    children: [
                      SizedBox(
                        height: 308,
                        child: EmptyWidget(
                            physics: const NeverScrollableScrollPhysics(),
                            title: LocalKeys.address),
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              al.reset();
                            });
                          },
                          child: Text(LocalKeys.retry)),
                      24.toHeight,
                    ],
                  ),
                ...al.addressListModel.allLocations.map((address) {
                  return AddressSheetTile(
                    valueListenable: widget.selectedAddress,
                    address: address,
                    isLast: al.addressListModel.allLocations.lastOrNull?.id
                            ?.toString() ==
                        address.id.toString(),
                  );
                }),
                12.toHeight,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AddEditAddressViewModel.dispose;
                      context.toPage(const AddEditAddressView());
                    },
                    label: Text(LocalKeys.newAddress),
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: context.color.secondaryContrastColor,
                    ),
                  ),
                ),
                8.toHeight,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop;
                      final sbm = ServiceBookingViewModel.instance;
                      sbm.addressController.text =
                          widget.selectedAddress.value?.address ?? "";
                      if (widget.selectedAddress.value?.latitude != null &&
                          widget.selectedAddress.value?.longitude != null) {
                        sbm.selectedLatLng.value = LatLng(
                            widget.selectedAddress.value!.latitude!,
                            widget.selectedAddress.value!.latitude!);
                      }
                    },
                    child: Text(LocalKeys.select),
                  ),
                ),
                12.toHeight,
              ],
            );
          }),
        ),
      );
    });
  }
}

class AddressSheetTile extends StatelessWidget {
  final ValueNotifier<Address?> valueListenable;
  final Address address;
  final bool isLast;
  const AddressSheetTile({
    super.key,
    required this.valueListenable,
    required this.address,
    this.isLast = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("selecting address".toString());
        valueListenable.value = address;
      },
      child: ValueListenableBuilder(
        valueListenable: valueListenable,
        builder: (context, value, child) {
          return Container(
            color: Colors.transparent,
            child: Column(
              children: [
                12.toHeight,
                Row(
                  children: [
                    (address.type.toString() == "1"
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
                            Text(address.title ?? LocalKeys.address,
                                style: context.titleSmall?.bold.copyWith(
                                    color:
                                        context.color.secondaryContrastColor)),
                            if (address.address != null)
                              Text(address.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.bodySmall?.copyWith(
                                      color: context
                                          .color.secondaryContrastColor)),
                          ],
                        )),
                    6.toWidth,
                    Radio(
                      value: true,
                      groupValue: value?.id == address.id,
                      onChanged: (v) {
                        debugPrint("selecting address".toString());
                        valueListenable.value = address;
                      },
                    )
                  ],
                ),
                12.toHeight,
                if (!isLast) const SizedBox().divider
              ],
            ),
          );
        },
      ),
    );
  }
}
