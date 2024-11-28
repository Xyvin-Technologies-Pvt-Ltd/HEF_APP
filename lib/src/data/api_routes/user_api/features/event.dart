import 'dart:convert';

import 'package:http/http.dart' as http;
  import 'package:hef/src/data/globals.dart';

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
