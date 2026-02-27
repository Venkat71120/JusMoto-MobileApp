abstract class BaseApiServices {
  Future<dynamic> getApi(String url, requestName);

  Future<dynamic> postApi(dynamic data, String url, requestName);

  Future<dynamic> putApi(dynamic data, String url, requestName);
}
