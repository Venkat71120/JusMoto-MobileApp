import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';

/// Handles all email OTP flows:
///   - Send/resend OTP for email verification after sign-up  → POST /auth/resend-otp
///   - Send OTP for email change                             → POST /user/change-email
///   - Verify email with OTP                                 → POST /auth/verify-email
///   - Forgot password                                       → POST /auth/forgot-password
///   - Reset password                                        → POST /auth/reset-password
///
/// New backend OTP response shape:
///   { success, message, data: { expiresAt, otp (dev only) } }
class EmailManageService with ChangeNotifier {
  String? otp;
  String? email;
  Timer? timer;
  bool loadingSendOTP = false;
  bool loadingVerify = false;
  bool canSend = false;

  // ─── Send/Resend OTP for email verification (after register) ──────────────

  /// Sends (or resends) OTP to [emailUsername] for email verification.
  /// Endpoint: POST /auth/resend-otp   Body: { email }
  Future tryOtpToEmail({required String emailUsername}) async {
    email = emailUsername;
    final data = {'email': emailUsername};

    loadingSendOTP = true;
    notifyListeners();

    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.sentOtpToMailUrl, // /auth/resend-otp
      LocalKeys.signUp,
    );

    loadingSendOTP = false;

    // Backend: { success, message, data: { expiresAt, otp (dev only) } }
    if (responseData != null && responseData['data'] != null) {
      otp = responseData['data']['otp']?.toString(); // present in dev mode only
      canSend = false;
      LocalKeys.otpSendToMailSuccessfully.showToast();
      _startResendTimer();
      notifyListeners();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    notifyListeners();
    return null;
  }

  // ─── Send OTP to new email (change email flow) ────────────────────────────

  /// Sends OTP to a new email address for the change-email flow.
  /// Endpoint: POST /user/change-email   Body: { email }   (auth required)
  Future tryOtpToNewEmail({String? emailUsername}) async {
    if (emailUsername != null) email = emailUsername;
    final data = {'email': emailUsername ?? email ?? ""};

    loadingSendOTP = true;
    notifyListeners();

    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.changeEmailUrl,
      LocalKeys.changeEmail,
      headers: commonAuthHeader,
    );

    loadingSendOTP = false;

    if (responseData != null && responseData['success'] == true) {
      canSend = false;
      LocalKeys.otpSendToMailSuccessfully.showToast();
      _startResendTimer();
      notifyListeners();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    notifyListeners();
    return null;
  }

  // ─── Verify email with OTP ────────────────────────────────────────────────

  /// Verifies [emailUsername]'s email using the stored [otp].
  /// Endpoint: POST /auth/verify-email   Body: { email, otp }
  /// Backend sets email_verified = 1 and clears the token on success.
  Future tryEmailVerify({
    required String emailUsername,
    required String userId,   // kept for API compatibility; backend uses email+otp only
    required String token,    // kept for API compatibility
  }) async {
    email = emailUsername;
    final data = {
      'email': email,
      'otp': otp.toString(),
    };

    // /auth/verify-email is a public endpoint — no auth header needed
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.verifyEmailUrl,
      LocalKeys.signUp,
    );

    // Backend: { success: true, message: "Email verified successfully" }
    if (responseData != null && responseData['success'] == true) {
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    return null;
  }

  // ─── Change email (confirm OTP) ───────────────────────────────────────────

  /// Confirms the OTP and completes the email change.
  /// Endpoint: POST /user/verify-email-otp   Body: { email, otp }   (auth required)
  Future tryEmailChange({required String otp}) async {
    final data = {
      'email': email,
      'otp': otp,
    };

    loadingVerify = true;
    notifyListeners();

    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.verifyEmailOtpUrl,
      LocalKeys.changeEmail,
      headers: commonAuthHeader,
    );

    if (responseData != null && responseData['success'] == true) {
      LocalKeys.changedEmailSuccessfully.showToast();
      loadingVerify = false;
      notifyListeners();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    loadingVerify = false;
    notifyListeners();
    return null;
  }

  // ─── Forgot password ──────────────────────────────────────────────────────

  /// Sends a password-reset link to [email].
  /// Endpoint: POST /auth/forgot-password   Body: { email }
  /// Backend does NOT reveal whether the email exists (security).
  /// Backend response is always: { success: true, message: "If the email exists..." }
  Future tryForgotPassword({required String emailAddress}) async {
    final data = {'email': emailAddress};

    loadingSendOTP = true;
    notifyListeners();

    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.sendOtpUrl, // /auth/forgot-password
      LocalKeys.resetPassword,
    );

    loadingSendOTP = false;
    notifyListeners();

    // Always success-shaped (backend doesn't reveal email existence)
    if (responseData != null && responseData['success'] == true) {
      responseData['message']?.toString().showToast();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    return null;
  }

  // ─── Reset password (with token from email link) ──────────────────────────

  /// Resets the password using the token from the reset-email link.
  /// Endpoint: POST /auth/reset-password
  /// Body: { token, password, password_confirmation }
  Future tryResetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final data = {
      'token': resetToken,
      'password': newPassword,
      'password_confirmation': confirmPassword,   // ✅ must match exactly
    };

    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.resetPasswordUrl, // /auth/reset-password
      LocalKeys.resetPassword,
    );

    if (responseData != null && responseData['success'] == true) {
      LocalKeys.passwordResetSuccessful.showToast();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    return null;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _startResendTimer() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 120), () {
      canSend = true;
      notifyListeners();
    });
  }

  void setResetTimer() {
    loadingSendOTP = false;
    canSend = true;
  }
}