import 'dart:convert';
import 'dart:developer';

import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;

import 'package:hef/src/data/globals.dart';

Future<String> createUser({Map<String, dynamic>? data}) async {
  SnackbarService snackbarService = SnackbarService();
  final url = Uri.parse('$baseUrl/user/new-member');

  // COMPREHENSIVE REQUEST BODY LOGGING
  print('=== MEMBER CREATION API CALL ===');
  print('URL: $url');
  print('Method: POST');
  print('Headers: {');
  print('  Content-type: application/json');
  print('  Authorization: Bearer $token');
  print('}');

  // DETAILED REQUEST BODY ANALYSIS
  print('\n=== COMPLETE REQUEST BODY ANALYSIS ===');
  print('Raw Data Map Keys: ${data?.keys.toList()}');

  if (data != null) {
    // Log each field with detailed analysis
    data.forEach((key, value) {
      print('📝 Field: "$key"');
      if (value is List) {
        print('   Type: List<${value.runtimeType}>');
        print('   Length: ${value.length}');
        if (key == 'company') {
          print('   📊 COMPANY ARRAY DETAILS:');
          for (int i = 0; i < value.length; i++) {
            print('     Company[$i]: ${value[i]}');
            if (value[i] is Map) {
              (value[i] as Map).forEach((compKey, compValue) {
                print('       $compKey: "$compValue"');
              });
            }
          }
        } else {
          for (int i = 0; i < value.length; i++) {
            print('     [$i]: ${value[i]}');
          }
        }
      } else if (value is Map) {
        print('   Type: Map<${value.runtimeType}>');
        print('   Keys: ${value.keys.toList()}');
        value.forEach((mapKey, mapValue) {
          print('     $mapKey: "$mapValue"');
        });
      } else {
        print('   Value: "$value"');
        print('   Type: ${value.runtimeType}');
        print('   Is Null: ${value == null}');
        print('   Is Empty: ${value == ''}');
      }
      print('');
    });
  } else {
    print('❌ DATA IS NULL - No payload will be sent!');
  }

  print('\n=== COMPLETE JSON PAYLOAD ===');
  if (data != null) {
    print(const JsonEncoder.withIndent('  ').convert(data));
  } else {
    print('NULL - No JSON to display');
  }
  print('==================================');
  print('=== END REQUEST BODY LOG ===\n');

  final response = await http.post(url,
      headers: {
        'Content-type': 'application/json',
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data));

  // Enhanced response logging
  print('=== API RESPONSE ===');
  print('Status Code: ${response.statusCode}');
  print('Response Headers: ${response.headers}');
  print('Response Body: ${response.body}');
  print('===================');

  if (response.statusCode == 200) {
    print('✅ Member created successfully');
    final responseData = json.decode(response.body);
    print('✅ Response message: ${responseData['message']}');
    if (responseData['data'] != null) {
      print(
          '✅ Response data: ${const JsonEncoder.withIndent('  ').convert(responseData['data'])}');
    }
    snackbarService.showSnackBar(responseData['message']);
    return responseData['message'];
  } else {
    final errorData = json.decode(response.body);
    print('❌ Failed to create member');
    print('❌ Error message: ${errorData['message']}');
    print('❌ Status code: ${response.statusCode}');
    snackbarService.showSnackBar(errorData['message']);
    return errorData['message'];
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
