import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../services/auth_services/sign_in_service.dart';
import '../../services/chat_services/chat_credential_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../services/push_notification_service.dart';

class SocialSignInViewModel {
  final googleSignIn = GoogleSignIn();
  String type = "";
  String fName = "";
  String lName = "";
  String id = "";
  String email = "";

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

  trySocialSignIn(
    BuildContext context, {
    type = "google",
  }) async {
    try {
      switch (type) {
        case "facebook":
          await facebook();
          break;
        case "apple":
          await apple();
          if (id.isEmpty) return;
          break;
        default:
          await google();
      }

      sPref?.setString("ss_type", type ?? "");

      final result = await Provider.of<SignInService>(context, listen: false)
          .trySocialSignIn(
        type: type,
        fName: fName,
        lName: lName,
        email: email,
        id: id,
      );
      if (result == true) {
        Provider.of<ChatCredentialService>(context, listen: false)
            .fetchCredentials();
        await PushNotificationService().updateDeviceToken(forceUpdate: true);
        await Provider.of<ProfileInfoService>(context, listen: false)
            .fetchProfileInfo();
        context.toUntilPage(const LandingView());
      }
    } catch (e) {
      LocalKeys.signInFailed.showToast();
    }
  }

  google() async {
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      LocalKeys.signInFailed.showToast();
      return;
    }
    GoogleSignInAccount? user = googleUser;

    type = "google";
    fName = user.displayName?.split(" ").firstOrNull ?? "";
    try {
      lName = user.displayName?.split(" ").sublist(1).join(" ") ?? "";
    } catch (e) {
      lName = user.displayName ?? "";
    }
    email = user.email;
    id = user.id;
  }

  facebook() async {
    final facebookAuth = FacebookAuth.instance;
    final token = await facebookAuth.accessToken;
    var userDetails = {};

    if (token == null) {
      final LoginResult result = await facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw "";
      }
    }

    userDetails = await facebookAuth.getUserData(
      fields: "name,email",
    );

    type = "facebook";
    fName = userDetails["name"].split(" ").firstOrNull ?? "";
    try {
      lName = userDetails["name"].split(" ").sublist(1).join(" ") ?? "";
    } catch (e) {
      lName = userDetails["name"];
    }
    email = userDetails["email"];
    id = userDetails["id"];
  }

  apple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      fName =
          credential.givenName ?? sPref?.getString("apple_user_fName") ?? "";
      lName =
          credential.familyName ?? sPref?.getString("apple_user_lName") ?? "";
      email = credential.email ?? sPref?.getString("apple_user_email") ?? "";
      id = credential.userIdentifier ?? "";
      type = "apple";

      sPref?.setString("apple_user_token", credential.identityToken ?? "");
      sPref?.setString("apple_user_id", credential.userIdentifier ?? "");
      sPref?.setString("apple_user_email", credential.email ?? "");
      sPref?.setString("apple_user_fName", credential.givenName ?? "");
      sPref?.setString("apple_user_lName", credential.familyName ?? "");
    } catch (e) {}
  }

  void signOut() {
    final ssType = sPref?.getString("ss_type");

    switch (ssType) {
      case null:
        break;
      case "facebook":
        FacebookAuth.instance.logOut();
        break;
      case "apple":
        sPref?.remove("apple_user_token");
        sPref?.remove("apple_user_id");
        sPref?.remove("apple_user_email");
        sPref?.remove("apple_user_fName");
        sPref?.remove("apple_user_lName");
        break;
      default:
        googleSignIn.signOut();
    }
    sPref?.remove("ss_type");
  }
}
