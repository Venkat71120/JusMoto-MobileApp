import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';

/// Logs out the current user.
/// Endpoint: POST /auth/logout   Auth: Bearer token
///
/// Backend has NO server-side token blacklisting.
/// The client must clear the token from SharedPreferences after this call.
class SignOutService {
  Future trySignOut() async {
    final responseData = await NetworkApiServices().postApi(
      {},
      AppUrls.signOutUrl, // /auth/logout
      LocalKeys.signOut,
      headers: acceptJsonAuthHeader,
    );

    // Backend: { success: true, message: "Logged out successfully" }
    if (responseData != null &&
        (responseData['success'] == true ||
            responseData.containsKey("message"))) {
      LocalKeys.signOutSuccessful.showToast();

      // ✅ Always clear local token regardless of response,
      //    since backend has no token blacklisting anyway.
      setToken("");
      return true;
    }

    // Fallback: clear local token even if the API call fails
    setToken("");
    return true;
  }
}