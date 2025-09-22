import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';

Future<String> videoUpload(String videoPath) async {
  File videoFile = File(videoPath);

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/upload/'),
  );
  request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    return extractVideoUrl(responseBody);
  } else {
    var responseBody = await response.stream.bytesToString();
    log(responseBody.toString());
    throw Exception('Failed to upload video');
  }
}

String extractVideoUrl(String responseBody) {
  final responseJson = jsonDecode(responseBody);
  log(name: "video upload response", responseJson.toString());
  return responseJson['data'];
}
