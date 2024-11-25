import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:hef/src/data/globals.dart';

Future<String> sendOtp(
    {required String phone, required String countryCode}) async {
  final url = Uri.parse('$baseUrl/user/send-Otp');

  final response = await http.post(url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({"phone": '$countryCode$phone'}));

  if (response.statusCode == 200) {
    print('Otp Send successfully');
    print(json.decode(response.body)['data']);
    return json.decode(response.body)['message'];
  } else {
    print(json.decode(response.body)['message']);

    print('Failed to update profile. Status code: ${response.statusCode}');
    return json.decode(response.body)['message'];
    // throw Exception('Failed to update profile');
  }
}

Future<String> verifyUser({required String phone, required String otp}) async {
  final url = Uri.parse('$baseUrl/user/verify');
  log('phone :$phone');
  final response = await http.post(url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({"phone": '$phone', "otp": otp}));

  if (response.statusCode == 200) {
    print('Verified successfully');
    print(json.decode(response.body)['message']);
    return json.decode(response.body)['data'];
  } else {
    print(json.decode(response.body)['message']);

    print('Failed to update profile. Status code: ${response.statusCode}');
    return json.decode(response.body)['data'];
    // throw Exception('Failed to update profile');
  }
}
