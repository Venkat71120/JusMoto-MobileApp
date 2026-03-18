import 'dart:convert';

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/customization.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/intl.dart';

import '../constant_helper.dart';
import '../local_keys.g.dart';

extension SvgPathExtension on String {
  Widget get toSVG => SvgPicture.asset('assets/icons/$this.svg');
}

extension SvgSizedExtension on String {
  Widget toSVGSized(double height, {color}) => SvgPicture.asset(
        'assets/icons/$this.svg',
        height: height,
        color: color,
      );
}

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) {
      return this;
    }
    final laterPart = substring(1);
    return "${this[0].toUpperCase()}${laterPart.toLowerCase()}";
  }

  num get tryToParse {
    RegExp numberPattern = RegExp(r'\d+(\.\d+)?');

    String originalCurrency = replaceAll(",", "").replaceAll(numberPattern, '');
    return num.tryParse(replaceAll(originalCurrency, "")
            .replaceAll(",", "")
            .replaceAll(dProvider.currencySymbol.toString(), "")) ??
        0;
  }

  bool get parseToBool {
    return this == "1" || this == "true" || this == "unread";
  }
}

extension EmailObfuscation on String {
  String get obscureEmail {
    final parts = split('@');

    if (parts.length != 2) {
      return this; // Return the original string if it's not a valid email
    }

    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.length <= 2) return this;

    final obscuredLocalPart = localPart[0] +
        '*' * (localPart.length - 2) +
        localPart[localPart.length - 1];

    return '$obscuredLocalPart@$domainPart';
  }
}

extension NumConversionExtension on Object {
  num get tryToParse {
    RegExp numberPattern = RegExp(r'\d+(\.\d+)?');
    final objString = toString();

    String originalCurrency =
        objString.replaceAll(",", "").replaceAll(numberPattern, '');
    return num.tryParse(objString
            .replaceAll(originalCurrency, "")
            .replaceAll(",", "")
            .replaceAll(dProvider.currencySymbol.toString(), "")) ??
        0;
  }
}

extension NumConversionExtensionD on dynamic {
  num get tryToParse {
    RegExp numberPattern = RegExp(r'\d+(\.\d+)?');
    final objString = toString();

    String originalCurrency =
        objString.replaceAll(",", "").replaceAll(numberPattern, '');
    return num.tryParse(objString
            .replaceAll(originalCurrency, "")
            .replaceAll(",", "")
            .replaceAll(dProvider.currencySymbol.toString(), "")) ??
        0;
  }
}

extension CurrencyDynamicExtension on String {
  String get cur {
    String symbol = dProvider.currencySymbol;
    return dProvider.currencyRight ? "$this$symbol" : "$symbol$this";
  }
}

extension TranslateExtension on String {
  String tr() {
    return asProvider.getString(this);
  }
}

extension EmailValidateExtension on String {
  bool get validateEmail {
    final emailReg = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailReg.hasMatch(this);
  }

  bool get validatePhone {
    final phoneReg = RegExp(r'^\+?\d+$');
    return phoneReg.hasMatch(this);
  }
}

extension ShowToastExtension on String {
  showToast({bc, tc}) {
    print("trying to show toast");
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: asProvider.getString(this),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: bc ?? color.mutedContrastColor,
        textColor: tc ?? color.primaryContrastColor,
        fontSize: 16.0);
  }
}

extension CapitalizeWordsExtension on String {
  String get capitalizeWords {
    if (isEmpty) {
      return '';
    }

    List<String> words = split(' ');
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isNotEmpty) {
        String capitalized = word[0].toUpperCase() + word.substring(1);
        capitalizedWords.add(capitalized);
      }
    }

    return capitalizedWords.join(' ');
  }
}

extension TokenValidateExtension on String {
  bool get isInvalid {
    return this != getToken;
  }
}

extension PasswordValidatorExtension on String {
  String? get validPass {
    String? value;
    if (length < 8) {
      value = LocalKeys.passLeastCharWarning;
    } else if (!RegExp(r'[A-Z]').hasMatch(this)) {
      value = LocalKeys.passUpperCaseWarning;
    } else if (!RegExp(r'[a-z]').hasMatch(this)) {
      value = LocalKeys.passLowerCaseWarning;
    } else if (!RegExp(r'\d').hasMatch(this)) {
      value = LocalKeys.passDigitWarning;
    } else if (!RegExp(r'[@$!%*?&]').hasMatch(this)) {
      value = LocalKeys.passCharacterWarning;
    }
    debugPrint(value.toString());
    return value;
  }
}

extension ImageUrlExtension on String {
  String get toImageUrl {
    if (isEmpty) return '';
    if (startsWith('http')) return this;
    
    // Ensure siteLink doesn't have a trailing slash and the path doesn't have a leading slash
    final base = siteLink.endsWith('/') 
        ? siteLink.substring(0, siteLink.length - 1) 
        : siteLink;
    final path = startsWith('/') ? substring(1) : this;
    
    return '$base/$path';
  }
}

extension AssetExtension on String {
  Widget toAImage({color, fit}) => Image.asset(
        'assets/images/$this.png',
        fit: fit,
      );
}

extension AssetImageExtension on String {
  ImageProvider get toAsset => AssetImage(
        'assets/images/$this.png',
      );
}

extension EncryptionExtension on String {
  String toHmac({required String secret}) {
    final keyBytes = const Utf8Encoder().convert(secret);
    final dataBytes = const Utf8Encoder().convert(this);

    final hmacBytes = Hmac(sha256, keyBytes).convert(dataBytes);
    return hmacBytes.toString();
  }
}

extension OfferStatsColors on String {
  String get getOfferStatus {
    switch (this) {
      case "0":
        return LocalKeys.pending;
      case "1":
        return LocalKeys.hired;
      case "2":
        return LocalKeys.complete;
      case "3":
        return LocalKeys.cancel;
      default:
        return LocalKeys.pending;
    }
  }

  Color get getOfferPrimaryStatusColor {
    switch (this) {
      case "0":
        return color.primaryPendingColor;
      case "1":
        return primaryColor;
      case "2":
        return color.primarySuccessColor;
      case "3":
        return color.primaryWarningColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getOfferMutedStatusColor {
    switch (this) {
      case "0":
        return color.mutedPendingColor;
      case "1":
        return mutedPrimaryColor;
      case "2":
        return color.mutedSuccessColor;
      case "3":
        return color.mutedWarningColor;
      default:
        return color.mutedPendingColor;
    }
  }
}

extension OrderStatusExtension on String {
  String get getOrderStatus {
    switch (this) {
      case "0":
        return LocalKeys.pending;
      case "1":
        return LocalKeys.complete;
      case "2":
        return LocalKeys.complete;
      case "3":
        return LocalKeys.delivered;
      case "4":
        return LocalKeys.canceled;
      case "5":
        return LocalKeys.declined;
      case "6":
        return LocalKeys.suspended;
      default:
        return LocalKeys.pending;
    }
  }

  Color get getOrderPrimaryStatusColor {
    switch (this) {
      case "0":
        return color.primaryPendingColor;
      case "6":
        return color.primaryPendingColor;
      case "1":
        return color.primarySuccessColor;
      case "3":
        return color.primarySuccessColor;
      case "2":
        return color.primarySuccessColor;
      case "4":
        return color.primaryWarningColor;
      case "5":
        return color.primaryWarningColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getOrderMutedStatusColor {
    switch (this) {
      case "0":
        return color.mutedPendingColor;
      case "6":
        return color.mutedPendingColor;
      case "1":
        return color.mutedSuccessColor;
      case "3":
        return color.mutedSuccessColor;
      case "2":
        return color.mutedSuccessColor;
      case "4":
        return color.mutedWarningColor;
      case "5":
        return color.mutedWarningColor;
      default:
        return color.mutedPendingColor;
    }
  }

  String get getSuborderStatus {
    switch (this) {
      case "0":
        return LocalKeys.pending;
      case "1":
        return LocalKeys.accepted;
      case "2":
        return LocalKeys.complete;
      case "3":
        return LocalKeys.delivered;
      case "4":
        return LocalKeys.canceled;
      case "5":
        return LocalKeys.declined;
      case "6":
        return LocalKeys.suspended;
      default:
        return LocalKeys.pending;
    }
  }

  Color get getSuborderPrimaryStatusColor {
    switch (this) {
      case "0":
        return color.primaryPendingColor;
      case "6":
        return color.primaryPendingColor;
      case "1":
        return color.primaryPendingColor;
      case "3":
        return color.primarySuccessColor;
      case "2":
        return color.primarySuccessColor;
      case "4":
        return color.primaryWarningColor;
      case "5":
        return color.primaryWarningColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getSuborderMutedStatusColor {
    switch (this) {
      case "0":
        return color.mutedPendingColor;
      case "6":
        return color.mutedPendingColor;
      case "1":
        return color.mutedPendingColor;
      case "3":
        return color.mutedSuccessColor;
      case "2":
        return color.mutedSuccessColor;
      case "4":
        return color.mutedWarningColor;
      case "5":
        return color.mutedWarningColor;
      default:
        return color.mutedPendingColor;
    }
  }

  String get getPaymentStatus {
    switch (this) {
      case "0":
        return LocalKeys.pending;
      case "1":
        return LocalKeys.complete;
      case "complete":
        return LocalKeys.complete;
      default:
        return LocalKeys.pending;
    }
  }

  Color get getPaymentPrimaryStatusColor {
    switch (this) {
      case "0":
        return color.primaryPendingColor;
      case "1":
        return color.primarySuccessColor;
      case "complete":
        return color.primarySuccessColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getPaymentMutedStatusColor {
    switch (this) {
      case "0":
        return color.mutedPendingColor;
      case "1":
        return color.mutedSuccessColor;
      case "complete":
        return color.mutedSuccessColor;
      default:
        return color.mutedPendingColor;
    }
  }

  String get getCompleteRequestText {
    switch (this) {
      case "0":
        return LocalKeys.requestedForOrderCompletion;
      case "pending":
        return LocalKeys.pending;
      case "1":
        return LocalKeys.orderCompletionRequestAccepted;
      case "2":
        return LocalKeys.orderCompletionRequestDeclined;
      case "complete":
        return LocalKeys.complete;
      default:
        return LocalKeys.pending;
    }
  }

  Color get getCompleteRequestStatusColor {
    switch (this) {
      case "0":
        return color.primaryPendingColor;
      case "1":
        return color.primarySuccessColor;
      case "2":
        return color.primaryWarningColor;
      case "complete":
        return color.primarySuccessColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getCompleteRequestMutedStatusColor {
    switch (this) {
      case "0":
        return color.mutedPendingColor;
      case "1":
        return color.mutedSuccessColor;
      case "2":
        return color.mutedWarningColor;
      case "complete":
        return color.mutedSuccessColor;
      default:
        return color.mutedPendingColor;
    }
  }
}

extension JobStatusExtension on String {
  String get getJobStatus {
    switch (this) {
      case "0":
        return LocalKeys.pending;
      case "1":
        return LocalKeys.active;
      case "2":
        return LocalKeys.complete;
      case "3":
        return LocalKeys.cancel;
      default:
        return LocalKeys.pending;
    }
  }

  Color get getJobPrimaryStatusColor {
    switch (this) {
      case "0":
        return color.primaryPendingColor;
      case "1":
        return primaryColor;
      case "2":
        return color.primarySuccessColor;
      case "3":
        return color.primaryWarningColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getJobMutedStatusColor {
    switch (this) {
      case "0":
        return color.mutedPendingColor;
      case "1":
        return mutedPrimaryColor;
      case "2":
        return color.mutedSuccessColor;
      case "3":
        return color.mutedWarningColor;
      default:
        return color.mutedPendingColor;
    }
  }
}

extension RefundStatusExtension on String {
  String get getRefundStatus {
    switch (toLowerCase()) {
      case "0":
      case "pending":
        return LocalKeys.pending;
      case "1":
      case "2":
      case "3":
      case "cancelled":
        return LocalKeys.canceled;
      case "approved":
        return "Approved"; // Or use a LocalKeys if available
      case "rejected":
        return "Rejected"; // Or use a LocalKeys if available
      default:
        return this.capitalize;
    }
  }

  Color get getRefundPrimaryStatusColor {
    switch (toLowerCase()) {
      case "0":
      case "pending":
        return color.primaryPendingColor;
      case "1":
      case "2":
      case "3":
      case "cancelled":
      case "rejected":
        return color.primaryWarningColor;
      case "approved":
        return color.primarySuccessColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getRefundMutedStatusColor {
    switch (toLowerCase()) {
      case "0":
      case "pending":
        return color.mutedPendingColor;
      case "1":
      case "2":
      case "3":
      case "cancelled":
      case "rejected":
        return color.mutedWarningColor;
      case "approved":
        return color.mutedSuccessColor;
      default:
        return color.mutedPendingColor;
    }
  }
}


extension TicketStatusExtension on String {
  String get getTicketStatus {
    switch (this) {
      case "0":
        return LocalKeys.pending;
      case "open":
        return LocalKeys.open;
      case "close":
        return LocalKeys.closed;
      default:
        return LocalKeys.pending;
    }
  }

  Color get getTicketPrimaryStatusColor {
    switch (this) {
      case "0":
        return color.primaryPendingColor;
      case "open":
        return primaryColor;
      case "close":
        return color.primaryWarningColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getTicketMutedStatusColor {
    switch (this) {
      case "0":
        return color.mutedPendingColor;
      case "open":
        return mutedPrimaryColor;
      case "close":
        return color.mutedWarningColor;
      default:
        return color.mutedPendingColor;
    }
  }

  String get getTicketPriority {
    switch (this) {
      case "low":
        return LocalKeys.low0;
      case "normal":
        return LocalKeys.normal;
      case "high":
        return LocalKeys.high0;
      case "urgent":
        return LocalKeys.urgent;
      default:
        return LocalKeys.urgent;
    }
  }

  Color get getTicketPrimaryPriorityColor {
    switch (this) {
      case "low":
        return color.primarySuccessColor;
      case "normal":
        return color.primarySuccessColor;
      case "high":
        return color.primaryPendingColor;
      case "urgent":
        return color.primaryWarningColor;
      default:
        return color.primaryPendingColor;
    }
  }

  Color get getTicketMutedPriorityColor {
    switch (this) {
      case "low":
        return color.mutedSuccessColor;
      case "normal":
        return color.mutedSuccessColor;
      case "high":
        return color.mutedPendingColor;
      case "urgent":
        return color.mutedWarningColor;
      default:
        return color.mutedPendingColor;
    }
  }

  /// Formats a "created_at" string (ISO 8601) to "Just now", "Date Time", or "x mins ago"
  /// Specifically tailored for the request: "Just now" if very recent, else "Date Time"
  String get toOrderTime {
    if (isEmpty) return '';
    try {
      final dt = DateTime.parse(this).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      // If within 2 minutes, show "Just now"
      if (diff.inSeconds >= 0 && diff.inMinutes < 2) {
        return 'Just now';
      }

      // If within 1 hour, maybe show "x mins ago" OR just stick to Date Time as requested
      // The user said: "if that order is placed just now then show just now other wose just show time and date thats it"
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return this;
    }
  }
}
