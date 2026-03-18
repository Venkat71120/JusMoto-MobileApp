import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '/helper/extension/context_extension.dart';
import '../../services/auth_services/sign_in_service.dart';
import '../../services/chat_services/chat_credential_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../services/push_notification_service.dart';
import '../../views/landing_view/landing_view.dart';

/// Handles Google, Facebook, and Apple sign-in.
/// Social login API: POST /auth/social/login
/// Required params: provider, email, firstName, lastName, socialId
class SocialSignInViewModel {
  final googleSignIn = GoogleSignIn(
    serverClientId: '423970134410-mdc81pgqk39aue1m1sv2126l62r7amue.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  String type = "";
  String fName = "";
  String lName = "";
  String id = "";
  String email = "";
  String? imageUrl;
  bool signInSuccess = false;

  SocialSignInViewModel._init();
  static SocialSignInViewModel? _instance;
  static SocialSignInViewModel get instance {
    _instance ??= SocialSignInViewModel._init();
    return _instance!;
  }

  SocialSignInViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  // ─── Entry point ─────────────────────────────────────────────────────────

  Future<void> trySocialSignIn(
    BuildContext context, {
    String type = "google",
  }) async {
    try {
      // Step 1 — get credentials from the social provider
      switch (type) {
        case "facebook":
          await _getFacebookCredentials();
          break;
        case "apple":
          await _getAppleCredentials();
          if (id.isEmpty) return; // user cancelled
          break;
        default:
          await _getGoogleCredentials();
      }

      if (email.isEmpty || id.isEmpty) {
        LocalKeys.signInFailed.showToast();
        return;
      }

      sPref?.setString("ss_type", type);

      // Step 2 — authenticate with our backend
      final signInService = SignInService();
      final result = await signInService.trySocialSignIn(
        type: type,
        fName: fName,
        lName: lName,
        email: email,
        id: id,
        image: imageUrl,
      );

      if (!context.mounted) return;

      if (result == true) {
        LocalKeys.signedInSuccessfully.showToast();

        Provider.of<ChatCredentialService>(context, listen: false)
            .fetchCredentials();

        signInSuccess = true;
        await PushNotificationService().updateDeviceToken(forceUpdate: true);
        await Provider.of<ProfileInfoService>(context, listen: false)
            .fetchProfileInfo();

        if (context.mounted) {
          context.toUntilPage(const LandingView());
        }
      } else {
        LocalKeys.signInFailed.showToast();
      }
    } catch (e) {
      debugPrint('❌ Social sign-in error: $e');
      LocalKeys.signInFailed.showToast();
    }
  }

  // ─── Provider credential fetchers ────────────────────────────────────────

  Future<void> _getGoogleCredentials() async {
    final currentUser = googleSignIn.currentUser;
    if (currentUser != null) await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      LocalKeys.signInFailed.showToast();
      return;
    }

    type = "google";
    final parts = (googleUser.displayName ?? "").split(" ");
    fName = parts.firstOrNull ?? "";
    lName = parts.length > 1 ? parts.sublist(1).join(" ") : "";
    email = googleUser.email;
    id = googleUser.id;
    imageUrl = googleUser.photoUrl;
  }

  Future<void> _getFacebookCredentials() async {
    final facebookAuth = FacebookAuth.instance;
    final existingToken = await facebookAuth.accessToken;

    if (existingToken == null) {
      final result = await facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw Exception("Facebook login failed: ${result.status}");
      }
    }

    final userDetails = await facebookAuth.getUserData(
      fields: "name,email,id,picture",
    );

    type = "facebook";
    final parts = ((userDetails["name"] as String?) ?? "").split(" ");
    fName = parts.firstOrNull ?? "";
    lName = parts.length > 1 ? parts.sublist(1).join(" ") : "";
    email = userDetails["email"] ?? "";
    id = userDetails["id"] ?? "";
    imageUrl = userDetails["picture"]?["data"]?["url"];
  }

  Future<void> _getAppleCredentials() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    type = "apple";
    // Apple only provides name/email on the FIRST sign-in — fall back to saved
    fName = credential.givenName ?? sPref?.getString("apple_user_fName") ?? "";
    lName = credential.familyName ?? sPref?.getString("apple_user_lName") ?? "";
    email = credential.email ?? sPref?.getString("apple_user_email") ?? "";
    id = credential.userIdentifier ?? "";

    if (credential.givenName != null) {
      sPref?.setString("apple_user_fName", credential.givenName!);
    }
    if (credential.familyName != null) {
      sPref?.setString("apple_user_lName", credential.familyName!);
    }
    if (credential.email != null) {
      sPref?.setString("apple_user_email", credential.email!);
    }
    sPref?.setString("apple_user_id", credential.userIdentifier ?? "");
  }

  // ─── Sign out ────────────────────────────────────────────────────────────

  void signOut() {
    final ssType = sPref?.getString("ss_type");

    switch (ssType) {
      case "facebook":
        FacebookAuth.instance.logOut();
        break;
      case "apple":
        for (final key in [
          "apple_user_token",
          "apple_user_id",
          "apple_user_email",
          "apple_user_fName",
          "apple_user_lName",
        ]) {
          sPref?.remove(key);
        }
        break;
      case "google":
        googleSignIn.signOut();
        break;
    }

    sPref?.remove("ss_type");
  }
}