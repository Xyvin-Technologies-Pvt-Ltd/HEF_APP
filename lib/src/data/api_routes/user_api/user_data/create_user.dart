import 'dart:convert';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';

import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart'as http;


Future<void> createUser(
    {required UserModel user}) async {
  final url = Uri.parse('$baseUrl/');

  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // Prepare the payload
  final Map<String, dynamic> payload = {
    "name": user.name,
    "uid": user.uid,
    "memberId": user.memberId,
    "bloodgroup": user.bloodgroup,
    "role": user.role,
    "chapter": user.chapter,
    "image": user.image,
    "email": user.email,
    "phone": user.phone,
    "bio": user.bio,
    "status": user.status,
    "address": user.address,
    "businessCatogary": user.businessCategory,
    "businessSubCatogary": user.businessSubCategory,
    "dateOfJoining": user.dateOfJoining?.toIso8601String(),
    "company": {
      "name": user.company?[0].name,
      "designation": user.company?[0].designation,
      "email": user.company?[0].email,
      "websites": user.company?[0].websites,
      "phone": user.company?[0].phone,
    }
  };

  // Log the entire payload being sent to backend
  print('=== MEMBER CREATION PAYLOAD ===');
  print('URL: $url');
  print('Headers: $headers');
  print('Payload: ${const JsonEncoder.withIndent('  ').convert(payload)}');
  print('================================');

  final body = jsonEncode(payload);

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    // Log the response
    print('=== BACKEND RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('========================');

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Member created successfully');
    } else {
      print('❌ Failed to create member: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
    }
  } catch (e) {
    print('❌ Error creating member: $e');
  }
}

Future<void> deletePost( String postId, context) async {
  SnackbarService snackbarService = SnackbarService();
  final url = Uri.parse('$baseUrl/feeds/single/$postId');
  print('requesting url:$url');
  final response = await http.delete(
    url,
    headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
        snackbarService.showSnackBar('Post Deleted Successfully');
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text('Post Deleted Successfully')));
  } else {
    final jsonResponse = json.decode(response.body);
    snackbarService.showSnackBar(jsonResponse['message']);
    print(jsonResponse['message']);
    print('Failed to delete image: ${response.statusCode}');
  }
}
