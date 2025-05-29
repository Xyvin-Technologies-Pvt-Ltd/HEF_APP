import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/models/dashboard_model.dart';
import 'package:hef/src/data/models/payment_year_model.dart';
import 'package:hef/src/data/models/subscription_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_data.g.dart';

class UserService {
  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };
  static Future<UserModel> fetchUserDetails(String userId) async {
    final url = Uri.parse('$baseUrl/user/single/$userId');
    final response = await http.get(url, headers: _headers());
    log(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<List<UserModel>> fetchMultipleUsers(List<String> users) async {
    List<UserModel> userList = [];

    for (var userId in users) {
      try {
        final url = Uri.parse('$baseUrl/user/single/$userId');
        final response = await http.get(url, headers: _headers());

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          userList.add(UserModel.fromJson(data));
        } else {
          throw Exception(json.decode(response.body)['message']);
        }
      } catch (e) {
        log('Error fetching user $userId: $e');
      }
    }

    return userList;
  }

  static Future<UserDashboard> fetchDashboard(
      {String? startDate, String? endDate}) async {
    Uri url = Uri.parse('$baseUrl/user/dashboard');

    if (startDate != null && endDate != null) {
      url = Uri.parse(
          '$baseUrl/user/dashboard?startDate=$startDate&endDate=$endDate');
    }
    log("Token of dashboard:$token");
    final response = await http.get(url, headers: _headers());
    log(response.body, name: "USER DASHBOARD DATA");

    if (response.statusCode == 200) {
      return UserDashboard.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<void> createReport(
      {required String reportedItemId,
      required String reportType,
      required String reason}) async {
    final url = Uri.parse('$baseUrl/report');
    final body = {
      'content': reportedItemId.isNotEmpty ? reportedItemId : ' ',
      'reportType': reportType,
      'reason': reason
    };

    try {
      final response =
          await http.post(url, headers: _headers(), body: jsonEncode(body));
      if (response.statusCode == 201) {
        SnackbarService().showSnackBar('Reported to admin');
      } else {
        final jsonResponse = json.decode(response.body);
        log(jsonResponse['message']);
        SnackbarService().showSnackBar('Failed to Report');
      }
    } catch (e) {
      log('Error occurred: $e');
    }
  }

  static Future<void> blockUser(String userId, String? reason,
      BuildContext context, WidgetRef ref) async {
    final url = Uri.parse('$baseUrl/user/block/$userId');
    try {
      final response = await http.put(url, headers: _headers());
      if (response.statusCode == 200) {
        ref.read(userProvider.notifier).refreshUser();
        SnackbarService().showSnackBar('Blocked');
      } else {
        SnackbarService().showSnackBar('Failed to Block');
      }
    } catch (e) {
      log('An error occurred: $e');
    }
  }

  static Future<void> unBlockUser(String userId) async {
    final url = Uri.parse('$baseUrl/user/unblock/$userId');
    try {
      final response = await http.put(url, headers: _headers());
      if (response.statusCode == 200) {
        SnackbarService().showSnackBar('User unBlocked successfully');
      } else {
        SnackbarService().showSnackBar('Failed to UnBlock');
      }
    } catch (e) {
      log('An error occurred: $e');
    }
  }

  static Future<List<PaymentYearModel>> getPaymentYears() async {
    final url = Uri.parse('$baseUrl/payment/parent-subscription');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return List<PaymentYearModel>.from(
        data.map((item) => PaymentYearModel.fromJson(item)),
      );
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<String?> uploadPayment({
    required String image,
    required String catergory,
    required String parentSub,
  }) async {
    final url = Uri.parse('$baseUrl/payment/user');
    final body = {
      'category': catergory,
      'receipt': image,
      'amount': '1000',
      'parentSub': parentSub,
    };

    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );

      final jsonResponse = json.decode(response.body);
      SnackbarService().showSnackBar(jsonResponse['message']);

      return response.statusCode == 201 ? jsonResponse['message'] : null;
    } catch (e) {
      SnackbarService().showSnackBar(e.toString());
      return null;
    }
  }

  static Future<List<Subscription>> getSubscription(String id) async {
    final url = Uri.parse('$baseUrl/payment/user/$id');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return List<Subscription>.from(
        data.map((item) => Subscription.fromJson(item)),
      );
    } else {
      return [];
    }
  }

  static Future<List<String>> fetchBusinessTags({String? search}) async {
    Uri url = Uri.parse('$baseUrl/user/business-tags');
    if (search != null) {
      url = Uri.parse('$baseUrl/user/business-tags?search=$search');
    }

    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return List<String>.from(data.map((e) => e.toString()));
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<bool> checkUser(String mobile) async {
    final url = Uri.parse('$baseUrl/user/check-user');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({"phone": mobile}),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }
}

@riverpod
Future<UserModel> fetchUserDetails(Ref ref, String id) {
  return UserService.fetchUserDetails(id);
}

@riverpod
Future<List<UserModel>> getMultipleUsers(Ref ref, List<String> userIds) {
  return UserService.fetchMultipleUsers(userIds);
}

@riverpod
Future<UserDashboard> getUserDashboard(
  Ref ref, {
  String? startDate,
  String? endDate,
}) {
  return UserService.fetchDashboard(startDate: startDate, endDate: endDate);
}

@riverpod
Future<List<PaymentYearModel>> getPaymentYears(Ref ref) {
  return UserService.getPaymentYears();
}

@riverpod
Future<List<Subscription>> getUserSubscription(Ref ref) {
  return UserService.getSubscription(id);
}

@riverpod
Future<List<String>> searchBusinessTags(Ref ref, {String? search}) {
  return UserService.fetchBusinessTags(search: search);
}
