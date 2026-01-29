import 'package:car_service/helper/extension/string_extension.dart';

class WalletBalanceModel {
  final num availableBalance;

  WalletBalanceModel({required this.availableBalance});

  factory WalletBalanceModel.fromJson(Map json) {
    return WalletBalanceModel(
      availableBalance: json['available_balance'].toString().tryToParse,
    );
  }
}

class WalletTransactionListModel {
  final List<WalletTransaction> transactions;
  final WalletPagination? pagination;

  WalletTransactionListModel({
    required this.transactions,
    this.pagination,
  });

  factory WalletTransactionListModel.fromJson(Map json) {
    return WalletTransactionListModel(
      transactions: json['all_transactions'] == null ||
              json['all_transactions'] is! List
          ? []
          : List<WalletTransaction>.from(
              json['all_transactions'].map((x) => WalletTransaction.fromJson(x)),
            ),
      pagination: json['pagination'] == null
          ? null
          : WalletPagination.fromJson(json['pagination']),
    );
  }
}

class WalletTransaction {
  final int? id;
  final int? userId;
  final int? userBalanceId;
  final String? transactionType;
  final num amount;
  final String? description;
  final String? paymentGateway;
  final String? paymentAttachment;
  final String? status;
  final String? referenceType;
  final String? invoiceNumber;
  final String? createdAt;

  WalletTransaction({
    this.id,
    this.userId,
    this.userBalanceId,
    this.transactionType,
    required this.amount,
    this.description,
    this.paymentGateway,
    this.paymentAttachment,
    this.status,
    this.referenceType,
    this.invoiceNumber,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map json) {
    return WalletTransaction(
      id: json['id'],
      userId: json['user_id'],
      userBalanceId: json['user_balance_id'],
      transactionType: json['transaction_type'],
      amount: json['amount'].toString().tryToParse,
      description: json['description'],
      paymentGateway: json['payment_gateway'],
      paymentAttachment: json['payment_attachment'],
      status: json['status'],
      referenceType: json['reference_type'],
      invoiceNumber: json['invoice_number'],
      createdAt: json['created_at'],
    );
  }

  bool get isDeposit => transactionType == 'deposit';
  bool get isPayment => transactionType == 'payment';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';

  WalletTransaction copyWith({
    int? id,
    int? userId,
    int? userBalanceId,
    String? transactionType,
    num? amount,
    String? description,
    String? paymentGateway,
    String? paymentAttachment,
    String? status,
    String? referenceType,
    String? invoiceNumber,
    String? createdAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userBalanceId: userBalanceId ?? this.userBalanceId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      paymentAttachment: paymentAttachment ?? this.paymentAttachment,
      status: status ?? this.status,
      referenceType: referenceType ?? this.referenceType,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WalletPagination {
  final int? total;
  final int? count;
  final int? perPage;
  final int? currentPage;
  final int? lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  WalletPagination({
    this.total,
    this.count,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory WalletPagination.fromJson(Map json) {
    return WalletPagination(
      total: json['total'],
      count: json['count'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

class WalletDepositResponse {
  final WalletDepositDetails? depositDetails;

  WalletDepositResponse({this.depositDetails});

  factory WalletDepositResponse.fromJson(Map json) {
    return WalletDepositResponse(
      depositDetails: json['deposit_details'] == null
          ? null
          : WalletDepositDetails.fromJson(json['deposit_details']),
    );
  }
}

class WalletDepositDetails {
  final int? id;
  final int? userId;
  final int? walletId;
  final String? transactionType;
  final num amount;
  final String? description;
  final String? paymentGateway;
  final String? paymentAttachment;
  final String? status;
  final String? referenceType;
  final String? invoiceNumber;
  final String? createdAt;

  WalletDepositDetails({
    this.id,
    this.userId,
    this.walletId,
    this.transactionType,
    required this.amount,
    this.description,
    this.paymentGateway,
    this.paymentAttachment,
    this.status,
    this.referenceType,
    this.invoiceNumber,
    this.createdAt,
  });

  factory WalletDepositDetails.fromJson(Map json) {
    return WalletDepositDetails(
      id: json['id'],
      userId: json['user_id'],
      walletId: json['wallet_id'],
      transactionType: json['transaction_type'],
      amount: json['amount'].toString().tryToParse,
      description: json['description'],
      paymentGateway: json['payment_gateway'],
      paymentAttachment: json['payment_attachment'],
      status: json['status'],
      referenceType: json['reference_type'],
      invoiceNumber: json['invoice_number'],
      createdAt: json['created_at'],
    );
  }

  WalletTransaction toTransaction() {
    return WalletTransaction(
      id: id,
      userId: userId,
      userBalanceId: walletId,
      transactionType: transactionType,
      amount: amount,
      description: description,
      paymentGateway: paymentGateway,
      paymentAttachment: paymentAttachment,
      status: status,
      referenceType: referenceType,
      invoiceNumber: invoiceNumber,
      createdAt: createdAt,
    );
  }
}
