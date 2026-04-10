abstract class BaseApiServices {
  Future<dynamic> getApi(
    String url,
    requestName, {
    Map<String, String>? headers,
  });

  Future<dynamic> postApi(
    dynamic data,
    String url,
    requestName, {
    Map<String, String>? headers,
  });

  Future<dynamic> putApi(
    dynamic data,
    String url,
    requestName, {
    Map<String, String>? headers,
  });

  Future<dynamic> patchApi(
    dynamic data,
    String url,
    requestName, {
    Map<String, String>? headers,
  });

  Future<dynamic> deleteApi(
    String url,
    requestName, {
    Map<String, String>? headers,
  });
}
