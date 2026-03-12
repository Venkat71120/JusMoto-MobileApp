import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/address_services/address_list_service.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/add_edit_address_view_model/add_edit_address_view_model.dart';
import 'package:car_service/views/add_edit_address_view/add_edit_address_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/address_tile.dart';

class AddressListView extends StatefulWidget {
  const AddressListView({super.key});

  @override
  State<AddressListView> createState() => _AddressListViewState();
}

class _AddressListViewState extends State<AddressListView> {
  @override
  Widget build(BuildContext context) {
    final alProvider = Provider.of<AddressListService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(
          LocalKeys.addresses,
        ),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await alProvider.fetchAddressList().then((_) {
            setState(() {});
          });
        },
        child: Consumer<AddressListService>(builder: (context, al, child) {
          return FutureBuilder(
              future: al.shouldAutoFetch ? al.fetchAddressList() : null,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CustomPreloader();
                }
                return (al.addressListModel.allLocations.isEmpty)
                    ? EmptyWidget(title: LocalKeys.address)
                    : Scrollbar(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemBuilder: (context, index) {
                            final address =
                                (al.addressListModel.allLocations)[index];
                            return AddressTile(address: address);
                          },
                          separatorBuilder: (context, index) => 12.toHeight,
                          itemCount: (al.addressListModel.allLocations).length,
                        ),
                      );
              });
        }),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            border: Border(
                top: BorderSide(color: context.color.primaryBorderColor))),
        child: ElevatedButton.icon(
          onPressed: () {
            AddEditAddressViewModel.dispose;
            context.toPage(const AddEditAddressView());
          },
          label: Text(LocalKeys.newAddress),
          icon: const Icon(
            Icons.add_circle_outline_rounded,
          ),
        ),
      ),
    );
  }
}
