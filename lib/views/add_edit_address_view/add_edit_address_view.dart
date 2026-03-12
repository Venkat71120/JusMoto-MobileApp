import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/area_dropdown.dart';
import 'package:car_service/utils/components/city_dropdown.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/state_dropdown.dart';
import 'package:car_service/view_models/add_edit_address_view_model/add_edit_address_view_model.dart';
import 'package:car_service/views/add_edit_address_view/components/address_type_buttons.dart';
import 'package:car_service/views/add_edit_address_view/components/map_choose_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/components/custom_button.dart';

class AddEditAddressView extends StatelessWidget {
  const AddEditAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final aea = AddEditAddressViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.addAddress),
      ),
      body: ValueListenableBuilder(
          valueListenable: aea.disableScroll,
          builder: (context, dv, child) {
            return SingleChildScrollView(
              controller: aea.scrollController,
              physics: dv
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              child: Form(
                key: aea.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.toHeight,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      color: context.color.accentContrastColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AddressTypeButtons(),
                          ValueListenableBuilder(
                            valueListenable: aea.selectedFromMap,
                            builder: (context, value, child) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  value: value,
                                  onChanged: (_) {
                                    aea.selectedFromMap.value = !value;
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    LocalKeys.selectFromMap,
                                    style: context.titleSmall?.bold,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                                if (value) ...[
                                  Hero(tag: "map", child: MapChooseBlock()),
                                  4.toHeight,
                                  Text(
                                    LocalKeys.mapMoveNote,
                                    style: context.bodySmall,
                                  ),
                                  16.toHeight,
                                ],
                              ],
                            ),
                          ),
                          FieldWithLabel(
                            label: LocalKeys.title,
                            hintText: LocalKeys.enterTitle,
                            isRequired: true,
                            controller: aea.titlePassController,
                          ),
                          ValueListenableBuilder(
                            valueListenable: aea.selectedFromMap,
                            builder: (context, value, child) => Column(
                              children: [
                                if (!value) ...[
                                  StatesDropdown(
                                    stateNotifier: aea.selectedState,
                                    isRequired: true,
                                  ),
                                  CityDropdown(
                                    stateNotifier: aea.selectedState,
                                    cityNotifier: aea.selectedCity,
                                    isRequired: true,
                                  ),
                                  AreaDropdown(
                                    cityNotifier: aea.selectedCity,
                                    areaNotifier: aea.selectedArea,
                                    isRequired: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          FieldWithLabel(
                            label: LocalKeys.address,
                            hintText: LocalKeys.enterAddress,
                            isRequired: true,
                            controller: aea.addressController,
                            validator: (value) {
                              return (value ?? "").length < 4
                                  ? LocalKeys.enterValidAddress
                                  : null;
                            },
                          ),
                          FieldWithLabel(
                            label: LocalKeys.zipCode,
                            hintText: LocalKeys.enterZipCode,
                            isRequired: true,
                            controller: aea.zipCodeController,
                          ),
                          FieldWithLabel(
                            label: LocalKeys.phone,
                            controller: aea.phoneController,
                            hintText: LocalKeys.enterPhone,
                            keyboardType: TextInputType.number,
                            prefixText: "+91 ",
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if ((value ?? "").isEmpty) {
                                return null;
                              }
                              if (value.toString().length == 10) {
                                return null;
                              }
                              return LocalKeys.enterAValidPhoneNumber;
                            },
                          ),
                          FieldWithLabel(
                            controller: aea.emergencyPhoneController,
                            hintText: LocalKeys.enterPhone,
                            label: LocalKeys.emergencyPhoneNumber,
                            keyboardType: TextInputType.number,
                            prefixText: "+91 ",
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if ((value ?? "").isEmpty) {
                                return null;
                              }
                              if (value.toString().length == 10) {
                                return null;
                              }
                              return LocalKeys.enterAValidPhoneNumber;
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
      bottomNavigationBar: ValueListenableBuilder(
          valueListenable: aea.isLoading,
          builder: (context, loading, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  color: context.color.accentContrastColor,
                  border: Border(
                      top:
                          BorderSide(color: context.color.primaryBorderColor))),
              child: CustomButton(
                onPressed: () {
                  aea.tryAddingAddress(context);
                },
                btText: aea.addressId == null
                    ? LocalKeys.addAddress
                    : LocalKeys.saveChanges,
                isLoading: loading,
              ),
            );
          }),
    );
  }
}
