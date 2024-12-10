import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:hef/src/data/globals.dart';

Future<String> createUser({Map<String, dynamic>? data}) async {
  final url = Uri.parse('$baseUrl/user/member');
  log(data.toString());
  final response = await http.post(url,
      headers: {
        'Content-type': 'application/json',
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data));

  if (response.statusCode == 200) {
    print('Member created successfully');
    print(json.decode(response.body)['data']);
    return json.decode(response.body)['message'];
  } else {
    print(json.decode(response.body)['message']);

    print('Failed to create member Status code: ${response.statusCode}');
    return json.decode(response.body)['message'];
    // throw Exception('Failed to update profile');
  }
}

Future<Map<String, dynamic>> verifyUser(
    {required String phone, required String otp}) async {
  final url = Uri.parse('$baseUrl/user/verify');
  log('phone :$phone');
  log('otp:$otp');
  final response = await http.post(url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({"phone": '$phone', "otp": int.parse(otp)}));

  if (response.statusCode == 200) {
    print('Verified successfully');
    print(json.decode(response.body)['message']);
    log(response.body);
    print(json.decode(response.body)['data']);
    return json.decode(response.body)['data'];
  } else {
    print(json.decode(response.body)['message']);

    print('Failed to update profile. Status code: ${response.statusCode}');
    return json.decode(response.body)['data'];
    // throw Exception('Failed to update profile');
  }
}
