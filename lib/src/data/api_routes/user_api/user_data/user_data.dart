import 'dart:convert';
import 'dart:developer';
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

@riverpod
Future<UserModel> fetchUserDetails(Ref ref, String userId) async {
  final url = Uri.parse('$baseUrl/user/single/$userId');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  log(response.body);
  if (response.statusCode == 200) {
    final dynamic data = json.decode(response.body)['data'];
    return UserModel.fromJson(data);
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}


Future<UserModel> fetchUser( String userId) async {
  final url = Uri.parse('$baseUrl/user/single/$userId');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  log(response.body);
  if (response.statusCode == 200) {
    final dynamic data = json.decode(response.body)['data'];
    return UserModel.fromJson(data);
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

@riverpod
Future<UserDashboard> fetchUserDashboardDetails(Ref ref,
    {String? startDate, String? endDate}) async {
  Uri url = Uri.parse('$baseUrl/user/dashboard');

  if (startDate != null && endDate != null) {
    url = Uri.parse(
        '$baseUrl/user/dashboard?startDate=$startDate&endDate=$endDate');
  }
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  log(response.body);
  if (response.statusCode == 200) {
    final dynamic data = json.decode(response.body)['data'];
    return UserDashboard.fromJson(data);
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

Future<List<UserModel>> fetchMultipleUsers(
    {required List<String> users}) async {
  final List<UserModel> userList = [];
  log('im inside multiple user ');
  for (var userId in users) {
    try {
      log('im inside multiple user fetching');
      final url = Uri.parse('$baseUrl/user/single/$userId');
      print('Requesting URL: $url');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data['data']);
        userList.add(user);
        print('Fetched user: $user');
      } else {
        print(
            'Failed to fetch user $userId: ${json.decode(response.body)['message']}');
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      print('Error fetching user $userId: $e');
    }
  }

  return userList;
}

@riverpod
Future<List<Subscription>> getSubscription(GetSubscriptionRef ref) async {
  final String url = '$baseUrl/payment/user/$id';
  log('requesting url:$url');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      log(response.body);
      List<Subscription> subscriptions = [];

      for (var item in data) {
        subscriptions.add(Subscription.fromJson(item));
      }
      print('subscriptions::::::$subscriptions');

      return subscriptions;
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error in loading subscription details: $e');
    return [];
  }
}

Future<void> createReport({
  required String reportedItemId,
  required String reportType,
}) async {
  SnackbarService snackbarService = SnackbarService();
  String url = '$baseUrl/report';
  try {
    final Map<String, dynamic> body = {
      'content':
          reportedItemId != null && reportedItemId != '' ? reportedItemId : ' ',
      'reportType': reportType,
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $token', // Include your token if authentication is required
      },
      body: jsonEncode(body),
    );

    // Handle the response
    if (response.statusCode == 201) {
      snackbarService.showSnackBar('Reported to admin');
      print('Report created successfully');
    } else {
      snackbarService.showSnackBar('Failed to Report');
      print('Failed to create report: ${response.statusCode}');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

Future<void> blockUser(
    String userId, String? reason, context, WidgetRef ref) async {
  final String url = '$baseUrl/user/block/$userId';
  log('requesting url:$url');
  SnackbarService snackbarService = SnackbarService();
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Success
      ref.read(userProvider.notifier).refreshUser();

      print('User Blocked successfully');

      snackbarService.showSnackBar('Blocked');
    } else {
      // Handle error
      print('Failed to Block: ${response.statusCode}');
      final dynamic message = json.decode(response.body)['message'];
      log(message);
      snackbarService.showSnackBar('Failed to Block');
    }
  } catch (e) {
    // Handle exceptions
    print('An error occurred: $e');
  }
}

Future<void> unBlockUser(String userId) async {
  final String url = '$baseUrl/user/unblock/$userId';
  SnackbarService snackbarService = SnackbarService();
  log('requesting url:$url');
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Success
      print('User unBlocked successfully');
      snackbarService.showSnackBar('User unBlocked successfully');
    } else {
      // Handle error
      print('Failed to unBlock: ${response.statusCode}');
      final dynamic message = json.decode(response.body)['message'];
      log(message);
      snackbarService.showSnackBar('Failed to UnBlock');
    }
  } catch (e) {
    // Handle exceptions
    print('An error occurred: $e');
  }
}

@riverpod
Future<List<PaymentYearModel>> getPaymentYears(Ref ref) async {
  final url = Uri.parse('$baseUrl/payment/parent-subscription');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    print(response.body);
    List<PaymentYearModel> paymentYears = [];

    for (var item in data) {
      paymentYears.add(PaymentYearModel.fromJson(item));
    }
    print(paymentYears);
    return paymentYears;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

Future<String?> uploadPayment({
  required String amount,
  required String image,
  required String catergory,
  required String parentSub,
}) async {
  SnackbarService snackbarService = SnackbarService();
  final url = Uri.parse('$baseUrl/payment/user');

  final body = {
    'category': catergory,
    'receipt': image,
    'amount': amount,
    'parentSub': parentSub,
  };
  log(body.toString());
  try {
    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print('Payment uploaded successfully');
      final jsonResponse = json.decode(response.body);
      snackbarService.showSnackBar(jsonResponse['message']);
      return jsonResponse['message'];
    } else {
      final jsonResponse = json.decode(response.body);
      snackbarService.showSnackBar(jsonResponse['message']);
      print('Failed to upload Payment: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error occurred: $e');
    snackbarService.showSnackBar(e.toString());
    return null;
  }
}

@riverpod
Future<List<String>> fetchBusinessTags(Ref ref, {String? search}) async {
  Uri url = Uri.parse('$baseUrl/user/business-tags');

  if (search != null) {
    url = Uri.parse('$baseUrl/user/business-tags?search=$search');
  }

  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  log(response.body);

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final List<dynamic> data = responseData['data'];

    final List<String> tags = data.map((e) => e.toString()).toList();

    log('business tags response data: $tags');
    return tags;
  } else {
    final errorMessage = json.decode(response.body)['message'];
    print(errorMessage);
    throw Exception(errorMessage);
  }
}

Future<bool> checkUser({required String mobile}) async {
  final String url = '$baseUrl/user/check-user';
  log('Requesting URL: $url');

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"phone": mobile}),
    );

    log('Response: ${response.body}');

    return response.statusCode == 200;
  } catch (e) {
    log('Error: $e');
    return false;
  }
}
