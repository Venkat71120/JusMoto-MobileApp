import 'dart:io';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../customization.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/wallet_models/wallet_model.dart';
import '../profile_services/profile_info_service.dart';

class WalletService with ChangeNotifier {
  WalletBalanceModel? _walletBalance;
  WalletTransactionListModel? _transactionList;
  String token = "";
  String? nextPage;
  bool nextPageLoading = false;
  bool nexLoadingFailed = false;

  WalletBalanceModel get walletBalance =>
      _walletBalance ?? WalletBalanceModel(availableBalance: 0);

  WalletTransactionListModel get transactionList =>
      _transactionList ?? WalletTransactionListModel(transactions: []);

  bool get shouldAutoFetch => _walletBalance == null || token.isInvalid;

  Map<String, String> get _authHeaders => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $getToken',
  };

  Future<void> fetchWalletBalance() async {
    token = getToken;
    final url = AppUrls.walletBalanceUrl;
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.wallet,
      headers: _authHeaders,
    );

    if (responseData != null) {
      _walletBalance = WalletBalanceModel.fromJson(responseData);
    }
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    token = getToken;
    final url = AppUrls.walletTransactionsUrl;
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.walletTransactions,
      headers: _authHeaders,
    );

    if (responseData != null) {
      _transactionList = WalletTransactionListModel.fromJson(responseData);
      nextPage = _transactionList?.pagination?.nextPageUrl;
    } else {
      _transactionList ??= WalletTransactionListModel(transactions: []);
    }
    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (nextPageLoading || nextPage == null) return;
    nextPageLoading = true;
    notifyListeners();

    final responseData = await NetworkApiServices().getApi(
      nextPage!,
      LocalKeys.walletTransactions,
      headers: _authHeaders,
    );

    if (responseData != null) {
      final tempData = WalletTransactionListModel.fromJson(responseData);
      for (var element in tempData.transactions) {
        _transactionList?.transactions.add(element);
      }
      nextPage = tempData.pagination?.nextPageUrl;
    } else {
      nexLoadingFailed = true;
      Future.delayed(const Duration(seconds: 1)).then((value) {
        nexLoadingFailed = false;
        notifyListeners();
      });
    }
    nextPageLoading = false;
    notifyListeners();
  }

  Future<WalletDepositResponse?> createDeposit({
    required String amount,
    required String paymentGateway,
    File? attachment,
  }) async {
    final url = AppUrls.walletDepositCreateUrl;
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields.addAll({
      'amount': amount,
      'selected_payment_gateway': paymentGateway,
    });

    if (paymentGateway == "manual_payment" && attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', attachment.path),
      );
    }

    request.headers.addAll(_authHeaders);

    final responseData = await NetworkApiServices().postWithFileApi(
      request,
      LocalKeys.walletDeposit,
    );

    if (responseData != null) {
      final response = WalletDepositResponse.fromJson(responseData);
      // Add transaction to local list immediately
      if (response.depositDetails != null) {
        _addTransactionLocally(response.depositDetails!.toTransaction());
      }
      return response;
    }
    return null;
  }

  void _addTransactionLocally(WalletTransaction transaction) {
    _transactionList ??= WalletTransactionListModel(transactions: []);
    // Insert at the beginning of the list (newest first)
    _transactionList!.transactions.insert(0, transaction);
    notifyListeners();
  }

  void _updateTransactionStatus(int transactionId, String status) {
    if (_transactionList == null) return;

    final index = _transactionList!.transactions.indexWhere(
      (t) => t.id == transactionId,
    );
    if (index != -1) {
      final oldTransaction = _transactionList!.transactions[index];
      _transactionList!.transactions[index] = oldTransaction.copyWith(
        status: status,
      );
      notifyListeners();
    }
  }

  void _updateBalance(num amount) {
    final currentBalance = _walletBalance?.availableBalance ?? 0;
    _walletBalance = WalletBalanceModel(
      availableBalance: currentBalance + amount,
    );
    notifyListeners();
  }

  Future<bool> updateDepositPayment(
    BuildContext context, {
    required int transactionId,
    num? amount,
  }) async {
    debugPrint("=== updateDepositPayment called ===");
    debugPrint("Transaction ID: $transactionId");

    final pi = Provider.of<ProfileInfoService>(context, listen: false);
    final userEmail = pi.profileInfoModel.userDetails?.email ?? "";

    final url = AppUrls.walletDepositPaymentUpdateUrl;

    var data = {'transaction_id': transactionId.toString()};

    debugPrint("User Email for HMAC: $userEmail");

    var headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $getToken',
      "X-HMAC": userEmail.toHmac(secret: paymentUpdateKey),
    };

    debugPrint("URL: $url");
    debugPrint("Data: $data");
    debugPrint("Headers: $headers");
    debugPrint("email: $userEmail");

    final responseData = await NetworkApiServices().postApi(
      data,
      url,
      LocalKeys.walletDeposit,
      headers: headers,
    );

    debugPrint("Response: $responseData");

    if (responseData != null) {
      debugPrint("Payment update successful, updating locally...");
      // Update transaction status locally
      _updateTransactionStatus(transactionId, 'completed');
      // Update balance locally if amount is provided
      if (amount != null) {
        _updateBalance(amount);
      }
      return true;
    }
    debugPrint("Payment update failed");
    return false;
  }

  Future<void> refresh() async {
    await fetchWalletBalance();
    await fetchTransactions();
  }

  void reset() {
    _walletBalance = null;
    _transactionList = null;
    token = "";
    nextPage = null;
    nextPageLoading = false;
    nexLoadingFailed = false;
  }
}
