import 'dart:convert';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';

import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart'as http;


Future<void> createUser(
    {required UserModel user}) async {
  final url = Uri.parse('$baseUrl/feeds');

  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
{
  "name": user.name,
  "uid": user.name,
  "memberId": user.name,
  "bloodgroup": user.name,
  "role":user.name,
  "chapter": user.name,
  "image": user.name,
  "email": user.name,
  "phone":user.name,
  "bio": user.name,
  "status": user.name,
  "address": user.name,
  "businessCatogary":user.name,
  "businessSubCatogary": user.name,
  "company": {
    "name": user.company?.name,
    "designation":user.company?.designation,
    "email": user.company?.email,
    "websites": user.company?.websites,
    "phone": user.company?.phone,
  }
}
  });

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      print('Feed created successfully');
    } else {
      print('Failed to create feed: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
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
