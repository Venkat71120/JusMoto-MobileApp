import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://jusmoto.blackitechs.in/api/v1/admin/franchises');
  final body = {
    "name": "test franchise",
    "email": "donfran@gmail.com", 
    "phone": "5988966888",
    "password": "1234567890"
  };

  print('Sending POST to $url...');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // We might need Authorization! Oh! The mobile app sends Authorization token!
    },
    body: jsonEncode(body),
  );

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
