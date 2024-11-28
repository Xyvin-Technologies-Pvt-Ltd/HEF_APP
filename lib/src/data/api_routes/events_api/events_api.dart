import 'dart:convert';
import 'dart:developer';
import 'package:hef/src/data/models/events_model.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'events_api.g.dart';

@riverpod
Future<List<Event>> fetchEvents(FetchEventsRef ref) async {
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
