import 'dart:convert';
import 'dart:io';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/level_role_upload_model.dart';
import 'package:http/http.dart' as http;

class LevelRoleUploadApi {
  static final _base = Uri.parse('$baseUrl/level-role-upload');

  static const allowedExtensions = {
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'webp',
    'doc',
    'docx',
    'xls',
    'xlsx',
  };

  static Map<String, String> _headers() => {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };

  static Future<List<LevelRoleUpload>> fetchMyUploads({
    int pageNo = 1,
    int limit = 20,
  }) async {
    final url = _base.replace(queryParameters: {
      'pageNo': pageNo.toString(),
      'limit': limit.toString(),
      'type': 'report',
    });
    final response = await http.get(url, headers: _headers());
    final decoded = _decode(response.body);
    if (response.statusCode == 200) {
      final data = decoded['data'];
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((item) => LevelRoleUpload.fromJson(
              Map<String, dynamic>.from(item)))
          .where((item) => item.isMar)
          .toList();
    }
    throw Exception(_message(decoded, 'Could not load reports'));
  }

  static Future<LevelRoleUpload> uploadMar({
    required File file,
    required String title,
    String description = 'Monthly Analysis Report',
  }) async {
    final extension = _extension(file.path);
    if (!allowedExtensions.contains(extension)) {
      throw Exception('Upload a PDF, image, Word, or Excel file');
    }
    final size = await file.length();
    if (size > 15 * 1024 * 1024) {
      throw Exception('File must be 15 MB or smaller');
    }

    final request = http.MultipartRequest('POST', _base);
    request.headers.addAll(_headers());
    request.fields['type'] = 'report';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: _fileName(file.path),
    ));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final decoded = _decode(body);
    if (streamed.statusCode == 200 || streamed.statusCode == 201) {
      final data = decoded['data'];
      if (data is Map) {
        return LevelRoleUpload.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Upload saved, but the response was incomplete');
    }
    throw Exception(_message(decoded, 'Could not upload the report'));
  }

  static Future<void> deleteUpload(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/level-role-upload/$id'),
      headers: _headers(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) return;
    throw Exception(_message(_decode(response.body), 'Could not delete the report'));
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  static String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final name = normalized.split('/').last;
    return name.isEmpty ? 'mar' : name;
  }

  static String _extension(String path) {
    final name = _fileName(path);
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static String _message(Map<String, dynamic> decoded, String fallback) {
    final message = decoded['message']?.toString().trim() ?? '';
    return message.isEmpty ? fallback : message;
  }
}
