import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/add_edit_address_view_model/add_edit_address_view_model.dart';
import 'package:car_service/views/account_skeleton/account_skeleton.dart';
import 'package:car_service/views/add_edit_address_view/add_edit_address_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../models/address_models/address_model.dart';
import '../../../services/address_services/address_list_service.dart';
import '../../../utils/components/custom_future_widget.dart';
import '../../../utils/components/custom_preloader.dart';
import '../../../utils/components/empty_widget.dart';

class AddressSelectView extends StatelessWidget {
  final ValueNotifier<Address?> selectedAddress;
  const AddressSelectView({super.key, required this.selectedAddress});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressListService>(builder: (context, al, child) {
      return Consumer<ProfileInfoService>(builder: (context, pi, child) {
        return Scaffold(
          appBar: AppBar(
            leading: const NavigationPopIcon(),
          ),
          backgroundColor: context.color.accentContrastColor,
          body: pi.profileInfoModel.userDetails == null
              ? const Column(
                  children: [AccountSkeleton()],
                )
              : CustomFutureWidget(
                  function: al.shouldAutoFetch ? al.fetchAddressList() : null,
                  shimmer: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CustomPreloader()),
                  isLoading: al.isLoading,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Consumer<ProfileInfoService>(
                        builder: (context, pi, child) {
                      return Column(
                        children: [
                          if (al.addressListModel.allLocations.isEmpty)
                            Column(
                              children: [
                                SizedBox(
                                  height: 308,
                                  child: EmptyWidget(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      title: LocalKeys.address),
                                ),
                                TextButton(
                                    onPressed: () {
                                      al.fetchAddressList();
                                    },
                                    child: Text(LocalKeys.retry)),
                                24.toHeight,
                              ],
                            ),
                          ...al.addressListModel.allLocations.map((address) {
                            return AddressSheetTile(
                              valueListenable: selectedAddress,
                              address: address,
                              isLast: al.addressListModel.allLocations
                                      .lastOrNull?.id
                                      ?.toString() ==
                                  address.id.toString(),
                            );
                          }),
                          12.toHeight,
                        ],
                      );
                    }),
                  ),
                ),
          bottomNavigationBar: pi.profileInfoModel.userDetails == null
              ? null
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                      color: context.color.accentContrastColor,
                      border: Border(
                          top: BorderSide(
                              color: context.color.primaryBorderColor))),
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          },
                          child: Text(LocalKeys.select),
                        ),
                      ),
                      12.toHeight,
                    ],
                  ),
                ),
        );
      });
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
