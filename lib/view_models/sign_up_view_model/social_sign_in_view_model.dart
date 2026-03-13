import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
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
  final googleSignIn = GoogleSignIn(
    serverClientId: '423970134410-mdc81pgqk39aue1m1sv2126l62r7amue.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
    ],
  );
  String type = "";
  String fName = "";
  String lName = "";
  String id = "";
  String email = "";
  bool signInSuccess = false;  // ✅ ADDED: Track sign-in success like email sign-in

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
    debugPrint('🔐 ===== STARTING SOCIAL SIGN-IN =====');
    debugPrint('🔐 Type: $type');
    
    try {
      debugPrint('📍 STEP 1: Calling provider method ($type)');
      switch (type) {
        case "facebook":
          await facebook();
          break;
        case "apple":
          await apple();
          if (id.isEmpty) {
            debugPrint('❌ Apple sign-in cancelled - no ID received');
            return;
          }
          break;
        default:
          await google();
      }

      debugPrint('✅ STEP 1 COMPLETE: Got user data');
      debugPrint('   First Name: "$fName"');
      debugPrint('   Last Name: "$lName"');
      debugPrint('   Email: "$email"');
      debugPrint('   ID: "$id"');

      // Validate data
      if (email.isEmpty || id.isEmpty) {
        debugPrint('❌ VALIDATION FAILED: Missing email or ID');
        LocalKeys.signInFailed.showToast();
        return;
      }

      debugPrint('✅ VALIDATION PASSED');
      sPref?.setString("ss_type", type ?? "");

      debugPrint('📍 STEP 2: Calling backend API');
      
      final signInService = SignInService();
      final result = await signInService.trySocialSignIn(
        type: type,
        fName: fName,
        lName: lName,
        email: email,
        id: id,
      );
      
      debugPrint('📥 Backend result: $result');

      if (result == true) {
        debugPrint('✅ Backend accepted sign-in');
        
        // Show success toast like email sign-in does
        LocalKeys.signedInSuccessfully.showToast();
        
        debugPrint('🔍 Verifying token was saved...');
        final savedToken = sPref?.getString("token") ?? "";
        debugPrint('📋 Token in storage: ${savedToken.isNotEmpty ? "${savedToken.substring(0, 20)}..." : "EMPTY!"}');
        
        if (savedToken.isEmpty) {
          debugPrint('❌ ERROR: Token not found in storage!');
          LocalKeys.signInFailed.showToast();
          return;
        }
        
        // Fetch credentials and update tokens (same as email sign-in)
        Provider.of<ChatCredentialService>(context, listen: false)
            .fetchCredentials();
        
        // ✅ CRITICAL: Set the signInSuccess flag BEFORE API calls
        signInSuccess = true;
        
        await PushNotificationService().updateDeviceToken(forceUpdate: true);
        await Provider.of<ProfileInfoService>(context, listen: false)
            .fetchProfileInfo();
        
        debugPrint('📍 STEP 3: Closing sign-in screen');
        
        // ✅ FIXED: Pop like email sign-in does - use context.popFalse
        if (context.mounted) {
          // Using the same navigation method as email sign-in
          Navigator.of(context).pop(false);
          debugPrint('✅ Navigation triggered with popFalse');
        }
        
        debugPrint('🎉 Sign-in complete!');
      } else {
        debugPrint('❌ Backend returned false/null');
        LocalKeys.signInFailed.showToast();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception: $e');
      debugPrint('StackTrace: $stackTrace');
      LocalKeys.signInFailed.showToast();
    }
  }

  google() async {
    debugPrint('🔍 Starting Google Sign-In...');
    
    try {
      final currentUser = googleSignIn.currentUser;
      if (currentUser != null) {
        debugPrint('   Signing out previous user...');
        await googleSignIn.signOut();
      }

      debugPrint('   Calling googleSignIn.signIn()...');
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ User cancelled Google sign-in');
        LocalKeys.signInFailed.showToast();
        return;
      }

      debugPrint('✅ Got Google user data');
      debugPrint('   Email: ${googleUser.email}');
      debugPrint('   Name: ${googleUser.displayName}');
      debugPrint('   ID: ${googleUser.id}');

      GoogleSignInAccount user = googleUser;

      type = "google";
      fName = user.displayName?.split(" ").firstOrNull ?? "";
      try {
        lName = user.displayName?.split(" ").sublist(1).join(" ") ?? "";
      } catch (e) {
        lName = "";
      }
      email = user.email;
      id = user.id;

      debugPrint('✅ Google sign-in complete');
    } catch (e, stackTrace) {
      debugPrint('❌ Google sign-in error: $e');
      debugPrint('StackTrace: $stackTrace');
      LocalKeys.signInFailed.showToast();
      rethrow;
    }
  }

  facebook() async {
    debugPrint('🔍 Starting Facebook Sign-In...');
    
    try {
      final facebookAuth = FacebookAuth.instance;
      final token = await facebookAuth.accessToken;
      var userDetails = {};

      if (token == null) {
        debugPrint('   Showing Facebook login dialog...');
        final LoginResult result = await facebookAuth.login();
        if (result.status != LoginStatus.success) {
          debugPrint('❌ Facebook login failed: ${result.status}');
          throw "Facebook login failed";
        }
      }

      userDetails = await facebookAuth.getUserData(
        fields: "name,email,id",
      );

      debugPrint('✅ Got Facebook user data: $userDetails');

      type = "facebook";
      fName = userDetails["name"]?.split(" ").firstOrNull ?? "";
      try {
        lName = userDetails["name"]?.split(" ").sublist(1).join(" ") ?? "";
      } catch (e) {
        lName = userDetails["name"] ?? "";
      }
      email = userDetails["email"] ?? "";
      id = userDetails["id"] ?? "";

      debugPrint('✅ Facebook sign-in complete');
    } catch (e, stackTrace) {
      debugPrint('❌ Facebook sign-in error: $e');
      debugPrint('StackTrace: $stackTrace');
      throw e;
    }
  }

  apple() async {
    debugPrint('🔍 Starting Apple Sign-In...');
    
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      debugPrint('✅ Got Apple credential');

      fName = credential.givenName ?? sPref?.getString("apple_user_fName") ?? "";
      lName = credential.familyName ?? sPref?.getString("apple_user_lName") ?? "";
      email = credential.email ?? sPref?.getString("apple_user_email") ?? "";
      id = credential.userIdentifier ?? "";
      type = "apple";

      // Save for future (Apple only provides on first sign-in)
      if (credential.givenName != null) {
        sPref?.setString("apple_user_fName", credential.givenName!);
      }
      if (credential.familyName != null) {
        sPref?.setString("apple_user_lName", credential.familyName!);
      }
      if (credential.email != null) {
        sPref?.setString("apple_user_email", credential.email!);
      }
      
      sPref?.setString("apple_user_token", credential.identityToken ?? "");
      sPref?.setString("apple_user_id", credential.userIdentifier ?? "");

      debugPrint('✅ Apple sign-in complete');
    } catch (e, stackTrace) {
      debugPrint('❌ Apple sign-in error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  void signOut() {
    final ssType = sPref?.getString("ss_type");
    debugPrint('🚪 Signing out: $ssType');

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