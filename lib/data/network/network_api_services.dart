import 'dart:convert';
import 'dart:io';

import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../data/network/base_api_services.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../helper/network_connectivity.dart';
import '../../main.dart';
import '../../view_models/landding_view_model/landding_view_model.dart';
import '../../views/landing_view/landing_view.dart';
import '../../services/auth_services/AdminLoginService.dart';
import '../../services/auth_services/FranchiseLoginService.dart';
import '../../views/Admin_sign_in_view/AdminLoginView.dart';
import '../../views/Franchise_sign_in_view/FranchiseLoginView.dart';
import '../app_exceptions.dart';

class NetworkApiServices extends BaseApiServices {
  final NetworkConnectivity networkConnectivity = NetworkConnectivity.instance;

  @override
  Future<Map?> getApi(
    String url,
    requestName, {
    headers,
    timeoutSeconds,
  }) async {
    if (kDebugMode) {
      debugPrint(url);
    }

    final hasConnection = await networkConnectivity.currentStatus();
    if (!hasConnection) {
      debugPrint("connection state is $hasConnection".toString());
      LocalKeys.noConnectionFound.showToast();
      return null;
    }
    Map<String, String> h = headers ?? {};
    h.addAll({'Accept': 'application/json'});
    Map? responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: h)
          .timeout(Duration(seconds: timeoutSeconds ?? 20));
      if (kDebugMode) {
        debugPrint(response.body.toString());
        debugPrint(response.statusCode.toString());
      }
      responseJson = returnResponse(response);
    } on SocketException {
      InternetException('');
      debugPrint("invalid url");
      showError(requestName, LocalKeys.invalidUrl);
    } on RequestTimeOut {
      debugPrint("request timeout");
      showError(requestName, LocalKeys.invalidUrl);
      RequestTimeOut('');
    } catch (e) {
      debugPrint(e.toString());
      showError(requestName, e.toString());
    }
    debugPrint(responseJson?.toString());
    return responseJson;
  }

  @override
  Future<Map?> postApi(
    var data,
    String url,
    requestName, {
    Map<String, String>? headers,
    int? timeoutSeconds,
  }) async {
    if (kDebugMode) {
      debugPrint(url);
      debugPrint(data.toString());
    }
    final hasConnection = await networkConnectivity.currentStatus();
    if (!hasConnection) {
      debugPrint("connection state is $hasConnection".toString());
      LocalKeys.noConnectionFound.showToast();
      return null;
    }

    Map<String, String> h = Map<String, String>.from(headers ?? {});
    h.putIfAbsent('Accept', () => 'application/json');

    Map? responseJson;
    try {
      http.Response response;

      // ✅ FIX: If data contains any non-String value (nested List, Map, int,
      // bool, null…), send as JSON. Otherwise use the original form-encoded
      // path so all existing callers (Map<String,String>) are unaffected.
      final bool needsJson =
          (data is Map && data.values.any((v) => v is! String)) ||
          (h['Content-Type']?.contains('application/json') == true);

      if (needsJson) {
        h['Content-Type'] = 'application/json';
        response = await http
            .post(Uri.parse(url), body: jsonEncode(data), headers: h)
            .timeout(Duration(seconds: timeoutSeconds ?? 10));
      } else {
        // Original behaviour — form-encoded, works for Map<String,String>
        response = await http
            .post(Uri.parse(url), body: data, headers: h)
            .timeout(Duration(seconds: timeoutSeconds ?? 10));
      }

      if (kDebugMode) {
        debugPrint(response.body.toString());
        debugPrint(response.statusCode.toString());
      }
      responseJson = returnResponse(response);
    } on SocketException {
      debugPrint("invalid url");
      showError(requestName, LocalKeys.invalidUrl);
    } on RequestTimeOut {
      debugPrint("request timeout");
      showError(requestName, LocalKeys.requestTimeOut);
    } catch (e) {
      showError(requestName, e.toString());
      debugPrint(e.toString());
    }
    return responseJson;
  }

  @override
  Future<Map?> putApi(
    var data,
    String url,
    requestName, {
    Map<String, String>? headers,
    int? timeoutSeconds,
  }) async {
    if (kDebugMode) {
      debugPrint(url);
      debugPrint(data.toString());
    }
    final hasConnection = await networkConnectivity.currentStatus();
    if (!hasConnection) {
      debugPrint("connection state is $hasConnection".toString());
      LocalKeys.noConnectionFound.showToast();
      return null;
    }
    Map<String, String> h = Map<String, String>.from(headers ?? {});
    h.putIfAbsent('Accept', () => 'application/json');
    Map? responseJson;
    try {
      http.Response response;

      final bool needsJson =
          (data is Map && data.values.any((v) => v is! String)) ||
          (h['Content-Type']?.contains('application/json') == true);

      if (needsJson) {
        h['Content-Type'] = 'application/json';
        response = await http
            .put(Uri.parse(url), body: jsonEncode(data), headers: h)
            .timeout(Duration(seconds: timeoutSeconds ?? 10));
      } else {
        response = await http
            .put(Uri.parse(url), body: data, headers: h)
            .timeout(Duration(seconds: timeoutSeconds ?? 10));
      }
      if (kDebugMode) {
        debugPrint(response.body.toString());
        debugPrint(response.statusCode.toString());
      }
      responseJson = returnResponse(response);
    } on SocketException {
      debugPrint("invalid url");
      showError(requestName, LocalKeys.invalidUrl);
    } on RequestTimeOut {
      debugPrint("request timeout");
      showError(requestName, LocalKeys.requestTimeOut);
    } catch (e) {
      showError(requestName, e.toString());
      debugPrint(e.toString());
    }
    return responseJson;
  }

  @override
  Future<Map?> patchApi(
    var data,
    String url,
    requestName, {
    Map<String, String>? headers,
    int? timeoutSeconds,
  }) async {
    if (kDebugMode) {
      debugPrint(url);
      debugPrint(data.toString());
    }
    final hasConnection = await networkConnectivity.currentStatus();
    if (!hasConnection) {
      debugPrint("connection state is $hasConnection".toString());
      LocalKeys.noConnectionFound.showToast();
      return null;
    }
    Map<String, String> h = Map<String, String>.from(headers ?? {});
    h.putIfAbsent('Accept', () => 'application/json');
    Map? responseJson;
    try {
      http.Response response;

      final bool needsJson =
          data is Map && data.values.any((v) => v is! String);

      if (needsJson) {
        h['Content-Type'] = 'application/json';
        response = await http
            .patch(Uri.parse(url), body: jsonEncode(data), headers: h)
            .timeout(Duration(seconds: timeoutSeconds ?? 10));
      } else {
        response = await http
            .patch(Uri.parse(url), body: data, headers: h)
            .timeout(Duration(seconds: timeoutSeconds ?? 10));
      }
      if (kDebugMode) {
        debugPrint(response.body.toString());
        debugPrint(response.statusCode.toString());
      }
      responseJson = returnResponse(response);
    } on SocketException {
      debugPrint("invalid url");
      showError(requestName, LocalKeys.invalidUrl);
    } on RequestTimeOut {
      debugPrint("request timeout");
      showError(requestName, LocalKeys.requestTimeOut);
    } catch (e) {
      showError(requestName, e.toString());
      debugPrint(e.toString());
    }
    return responseJson;
  }

  @override
  Future<Map?> deleteApi(
    String url,
    requestName, {
    Map<String, String>? headers,
    int? timeoutSeconds,
  }) async {
    if (kDebugMode) {
      debugPrint(url);
    }
    final hasConnection = await networkConnectivity.currentStatus();
    if (!hasConnection) {
      debugPrint("connection state is $hasConnection".toString());
      LocalKeys.noConnectionFound.showToast();
      return null;
    }
    Map<String, String> h = headers ?? {};
    h.putIfAbsent('Accept', () => 'application/json');
    Map? responseJson;
    try {
      final response = await http
          .delete(Uri.parse(url), headers: h)
          .timeout(Duration(seconds: timeoutSeconds ?? 10));
      if (kDebugMode) {
        debugPrint(response.body.toString());
        debugPrint(response.statusCode.toString());
      }
      responseJson = returnResponse(response);
    } on SocketException {
      debugPrint("invalid url");
      showError(requestName, LocalKeys.invalidUrl);
    } on RequestTimeOut {
      debugPrint("request timeout");
      showError(requestName, LocalKeys.requestTimeOut);
    } catch (e) {
      showError(requestName, e.toString());
      debugPrint(e.toString());
    }
    return responseJson;
  }

  Future<Map?> postWithFileApi(
    http.MultipartRequest request,
    requestName, {
    Map<String, String>? headers,
    int? timeoutSeconds,
  }) async {
    if (kDebugMode) {
      debugPrint(request.url.toString());
      debugPrint(request.fields.toString());
    }
    final hasConnection = await networkConnectivity.currentStatus();
    if (!hasConnection) {
      debugPrint("connection state is $hasConnection".toString());
      LocalKeys.noConnectionFound.showToast();
      return null;
    }

    Map? responseJson;
    try {
      debugPrint("POST with File: ${request.url}");
      final responseStream = await request.send().timeout(
        Duration(seconds: timeoutSeconds ?? 60),
      ); // Default 60 for files
      final data = await responseStream.stream.toBytes();
      http.Response response = http.Response.bytes(
        data,
        responseStream.statusCode,
      );
      if (kDebugMode) {
        debugPrint(response.body.toString());
        debugPrint(responseStream.statusCode.toString());
      }
      responseJson = returnResponse(response);
    } on SocketException {
      debugPrint("invalid url");
      showError(requestName, LocalKeys.invalidUrl);
    } on RequestTimeOut {
      debugPrint("request timeout");
      showError(requestName, LocalKeys.requestTimeOut);
    } catch (e) {
      showError(requestName, e.toString());
      debugPrint(e.toString());
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          dynamic responseJson = jsonDecode(response.body);
          return responseJson;
        } catch (_) {
          return {};
        }
      case 201:
        try {
          dynamic responseJson = jsonDecode(response.body);
          return responseJson;
        } catch (_) {
          return {};
        }
      case 400:
        try {
          dynamic responseJson = jsonDecode(response.body);
          if (responseJson["message"] != null) {
            responseJson["message"].toString().showToast();
          } else if (responseJson["error"] != null) {
            responseJson["error"].toString().showToast();
          }
          return null;
        } catch (_) {
          debugPrint(response.body.toString());
          throw FetchDataException('${response.reasonPhrase}');
        }
      case 422:
        try {
          checkAuthentication(response);
          dynamic responseJson = jsonDecode(response.body);
          showValidationErrors(responseJson);
          return null;
        } catch (error) {
          if (error is String) {
            rethrow;
          }
          debugPrint(response.body.toString());
          throw FetchDataException('${response.reasonPhrase}');
        }
      case 401:
        try {
          checkAuthentication(response);
          dynamic responseJson = jsonDecode(response.body);
          showValidationErrors(responseJson);
          return null;
        } catch (e) {
          if (e is String) {
            rethrow;
          }
          debugPrint(response.body.toString());
          throw FetchDataException('${response.reasonPhrase}');
        }
      default:
        try {
          checkAuthentication(response);
          dynamic responseJson = jsonDecode(response.body);
          showValidationErrors(responseJson);
          return null;
        } catch (e) {
          if (e is String) {
            rethrow;
          }
          debugPrint(response.body.toString());
          throw FetchDataException('${response.reasonPhrase}');
        }
    }
  }

  checkAuthentication(http.Response response) {
    // Only check for authentication failure on non-success status codes
    if (response.statusCode == 200 || response.statusCode == 201) return;

    if (response.body.contains("Unauthenticated.") ||
        response.statusCode == 401) {
      final context = navigatorKey.currentContext;

      if (context != null && getToken.isNotEmpty) {
        debugPrint(
          "🔌 Session invalid (401/Unauthenticated). Resetting session...",
        );

        final isAdmin = sPref?.getBool("is_admin") ?? false;
        final isFranchise = sPref?.getBool("is_franchise") ?? false;

        if (isAdmin) {
          Provider.of<AdminLoginService>(
            context,
            listen: false,
          ).clearAdminData();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AdminLoginView()),
            (route) => false,
          );
        } else if (isFranchise) {
          Provider.of<FranchiseLoginService>(
            context,
            listen: false,
          ).clearFranchiseData();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const FranchiseLoginView()),
            (route) => false,
          );
        } else {
          Provider.of<ProfileInfoService>(context, listen: false).reset();
          final lvm = LandingViewModel.instance;
          lvm.setContext(null);
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LandingView()),
            (route) => false,
          );
        }

        LocalKeys.sessionExpired.showToast();
        return null;
      } else {
        debugPrint(navigatorKey.currentContext?.toString());
        debugPrint("failed to reset".toString());
      }
    }
  }

  showError(requestName, error) {
    if (requestName != null) {
      "$requestName: $error".showToast();
    }
  }

  showValidationErrors(Map json) {
    debugPrint("in validation error method".toString());
    // Handle singular "error" key (e.g. {"success":false,"error":"Email already registered"})
    if (json.containsKey("error") && json["error"] is String) {
      throw json["error"];
    }
    if (!json.containsKey("errors") || json["errors"] == {}) {
      debugPrint(json["message"].toString());
      throw json["message"] ?? json["msg"];
    }

    final errors = json["errors"];
    debugPrint(errors.toString());
    if (errors.isEmpty) {
      debugPrint("throwing error".toString());
      throw json["message"] ?? json;
    }
    if (errors is Map) {
      final keys = errors.keys.toList();
      keys.remove("status");
      debugPrint(keys.last.toString());
      final passwordError = errors[keys.first];
      debugPrint(passwordError.toString());
      if (passwordError is String) {
        throw passwordError;
      } else if (passwordError is List && passwordError.isNotEmpty) {
        throw passwordError.first;
      }
    }
  }
}
