import 'package:flutter/material.dart';

class AddressListViewModel {
  ScrollController scrollController = ScrollController();

  AddressListViewModel._init();
  static AddressListViewModel? _instance;
  static AddressListViewModel get instance {
    _instance ??= AddressListViewModel._init();
    return _instance!;
  }

  AddressListViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void tryDeletingAccount(BuildContext context) async {}
}
