import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';

Future<String> editUser(Map<String, dynamic> profileData) async {
  final url = Uri.parse('$baseUrl/user/update');
  log('requesting url:$url');
  final response = await http.patch(
    url,
    headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(profileData),
  );

  if (response.statusCode == 200) {
    print('Profile updated successfully');
    print(json.decode(response.body)['message']);
    return json.decode(response.body)['message'];
  } else {
    print(json.decode(response.body)['message']);

    print('Failed to update profile. Status code: ${response.statusCode}');
    return json.decode(response.body)['message'];
    // throw Exception('Failed to update profile');
  }
}
