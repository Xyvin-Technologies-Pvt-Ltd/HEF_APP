import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';

Future<String> audioUpload(String audioPath) async {
  File audioFile = File(audioPath);

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/upload/'),
  );
  request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    return extractAudioUrl(responseBody);
  } else {
    var responseBody = await response.stream.bytesToString();
    log(responseBody.toString());
    throw Exception('Failed to upload audio');
  }
}

String extractAudioUrl(String responseBody) {
  final responseJson = jsonDecode(responseBody);
  log(name: "audio upload response", responseJson.toString());
  return responseJson['data'];
}
