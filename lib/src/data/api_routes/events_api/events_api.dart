import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/models/attendance_user_model.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'events_api.g.dart';

@riverpod
Future<List<Event>> fetchEvents(Ref ref) async {
  final url = Uri.parse('$baseUrl/event/list');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  print('hello');
  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    log(response.body);
    List<Event> events = [];

    for (var item in data) {
      events.add(Event.fromJson(item));
    }
    print(events);
    return events;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

@riverpod
Future<AttendanceUserListModel> fetchEventAttendance(FetchEventAttendanceRef ref,{required String eventId}) async {
  final url = Uri.parse('$baseUrl/event/attend/$eventId');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  print('hello');
  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {

    final dynamic data = json.decode(response.body)['data'];
    return AttendanceUserListModel.fromJson(data);
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

@riverpod
Future<List<Event>> fetchMyEvents(FetchMyEventsRef ref) async {
  final url = Uri.parse('$baseUrl/event/reg-events');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  print('hello');
  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    print(response.body);
    List<Event> events = [];

    for (var item in data) {
      events.add(Event.fromJson(item));
    }
    print(events);
    return events;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

Future<void> markEventAsRSVP(String eventId) async {
  final String url = '$baseUrl/event/single/$eventId';

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Success

      print('RSVP marked successfully');
    } else {
      // Handle error
      final dynamic data = json.decode(response.body)['message'];
      print('Failed to mark RSVP: ${data}');
    }
  } catch (e) {
    // Handle exceptions
    print('An error occurred: $e');
  }
}

Future<AttendanceUserModel?> markAttendanceEvent({
  required String eventId,
  required String userId,
}) async {
  SnackbarService snackbarService = SnackbarService();
  final String url = '$baseUrl/event/attend/$eventId';
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final Map<String, String> body = {
    'userId': userId,
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final dynamic data = json.decode(response.body)['data'];

    print(data);
    return AttendanceUserModel.fromJson(data);
  } else {
    print(json.decode(response.body)['message']);
    snackbarService.showSnackBar(json.decode(response.body)['message']);
    return null;
    throw Exception(json.decode(response.body)['message']);
  }
}
