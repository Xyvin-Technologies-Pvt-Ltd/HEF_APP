import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/attendance_user_model.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events_api.g.dart';

class EventApiService {
  static Future<List<Event>> fetchEvents() async {
    final url = Uri.parse('$baseUrl/event/list');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final status = json.decode(response.body)['status'];
      log('Status: $status');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((item) => Event.fromJson(item)).toList();
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      log('Error fetching events: $e');
      rethrow;
    }
  }

  static Future<Event> fetchEventById(String id) async {
    final url = Uri.parse('$baseUrl/event/single/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final status = json.decode(response.body)['status'];
      log('Status: $status');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body)['data'];
        return Event.fromJson(data);
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      log('Error fetching event by ID: $e');
      rethrow;
    }
  }

  static Future<AttendanceUserListModel> fetchEventAttendance(String eventId) async {
    final url = Uri.parse('$baseUrl/event/attend/$eventId');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final status = json.decode(response.body)['status'];
      log('Status: $status');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return AttendanceUserListModel.fromJson(data);
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      log('Error fetching attendance: $e');
      rethrow;
    }
  }

  static Future<List<Event>> fetchMyEvents() async {
    final url = Uri.parse('$baseUrl/event/reg-events');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final status = json.decode(response.body)['status'];
      log('Status: $status');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((item) => Event.fromJson(item)).toList();
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      log('Error fetching my events: $e');
      rethrow;
    }
  }

  static Future<void> markEventAsRSVP(String eventId) async {
    final url = Uri.parse('$baseUrl/event/single/$eventId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        log('RSVP marked successfully');
      } else {
        final error = json.decode(response.body)['message'];
        log('Failed to mark RSVP: $error');
      }
    } catch (e) {
      log('Error marking RSVP: $e');
    }
  }

  static Future<AttendanceUserModel?> markAttendanceEvent({
    required String eventId,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/event/attend/$eventId');
    final snackbarService = SnackbarService();

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return AttendanceUserModel.fromJson(data);
      } else {
        final error = json.decode(response.body)['message'];
        snackbarService.showSnackBar(error);
        return null;
      }
    } catch (e) {
      log('Error marking attendance: $e');
      return null;
    }
  }
}

@riverpod
Future<List<Event>> fetchEvents(Ref ref) async {
  return EventApiService.fetchEvents();
}

@riverpod
Future<Event> fetchEventById(Ref ref, {required String id}) async {
  return EventApiService.fetchEventById(id);
}

@riverpod
Future<AttendanceUserListModel> fetchEventAttendance(Ref ref, {required String eventId}) async {
  return EventApiService.fetchEventAttendance(eventId);
}

@riverpod
Future<List<Event>> fetchMyEvents(Ref ref) async {
  return EventApiService.fetchMyEvents();
}
