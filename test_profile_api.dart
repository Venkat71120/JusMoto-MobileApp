import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  var url = Uri.parse(
    'https://jusmoto.blackitechs.in/api/v1/user/profile/update',
  );

  // Create a dummy image file
  var file = File('test_image.jpg');
  await file.writeAsBytes([
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    0x00,
    0x10,
    0x4A,
    0x46,
    0x49,
    0x46,
    0x00,
  ]);

  // Try with 'file' key
  var request1 =
      http.MultipartRequest('POST', url)
        ..fields['update_type'] = 'after_login'
        ..fields['first_name'] = 'test'
        ..fields['last_name'] = 'test'
        ..headers['Accept'] = 'application/json'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

  var response1 = await request1.send();
  var body1 = await response1.stream.bytesToString();
  print('Response with key "file": $body1');

  // Try with 'image' key
  var request2 =
      http.MultipartRequest('POST', url)
        ..fields['update_type'] = 'after_login'
        ..fields['first_name'] = 'test'
        ..fields['last_name'] = 'test'
        ..headers['Accept'] = 'application/json'
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

  var response2 = await request2.send();
  var body2 = await response2.stream.bytesToString();
  print('Response with key "image": $body2');

  // Try with 'profile_image' key
  var request3 =
      http.MultipartRequest('POST', url)
        ..fields['update_type'] = 'after_login'
        ..fields['first_name'] = 'test'
        ..fields['last_name'] = 'test'
        ..headers['Accept'] = 'application/json'
        ..files.add(
          await http.MultipartFile.fromPath('profile_image', file.path),
        );

  var response3 = await request3.send();
  var body3 = await response3.stream.bytesToString();
  print('Response with key "profile_image": $body3');

  await file.delete();
}
