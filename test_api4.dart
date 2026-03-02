import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var req = http.Request(
    'POST',
    Uri.parse('https://jusmoto.blackitechs.in/api/v1/user/profile/update'),
  );
  req.body = jsonEncode({
    'update_type': 'after_login',
    'first_name': 'Test',
    'last_name': 'User',
  });
  req.headers.addAll({
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    // Not using token to see what error returns first (should be 401 unauthenticated)
  });
  try {
    var res = await req.send();
    print('STATUS: ${res.statusCode}');
    var resBodyBytes = await res.stream.toBytes();
    print('BODY LENGTH: ${resBodyBytes.length}');
    print(utf8.decode(resBodyBytes));
  } catch (e) {
    print(e);
  }
}
