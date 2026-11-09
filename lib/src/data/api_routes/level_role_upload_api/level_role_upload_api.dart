import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/level_role_upload_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class LevelRoleUploadApi {
  static Uri get _base => Uri.parse('$baseUrl/level-role-upload');

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

  static const _mimeByExtension = {
    'pdf': 'application/pdf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
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
    log('========================================', name: 'MAR API');
    log('GET $url', name: 'MAR API');
    log('Headers: ${_safeHeaders(_headers())}', name: 'MAR API');

    final response = await http.get(url, headers: _headers());
    log('Status: ${response.statusCode}', name: 'MAR API');
    log('Response body: ${response.body}', name: 'MAR API');
    log('========================================', name: 'MAR API');

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
    final mime = _mimeByExtension[extension];
    if (mime == null) {
      throw Exception('Upload a PDF, image, Word, or Excel file');
    }
    final size = await file.length();
    if (size > 15 * 1024 * 1024) {
      throw Exception('File must be 15 MB or smaller');
    }

    final fileName = _fileName(file.path);
    final parts = mime.split('/');
    final contentType = MediaType(parts.first, parts.last);
    final requestBody = {
      'type': 'report',
      'title': title,
      'description': description,
      'file': {
        'field': 'file',
        'path': file.path,
        'fileName': fileName,
        'extension': extension,
        'mimeType': mime,
        'sizeBytes': size,
      },
    };

    log('========================================', name: 'MAR API');
    log('POST $_base', name: 'MAR API');
    log('Headers: ${_safeHeaders(_headers())}', name: 'MAR API');
    log('Request body: ${jsonEncode(requestBody)}', name: 'MAR API');

    final request = http.MultipartRequest('POST', _base);
    request.headers.addAll(_headers());
    request.fields['type'] = 'report';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: fileName,
      contentType: contentType,
    ));

    log(
      'Multipart fields: ${request.fields}, files: ${request.files.map((f) => {
            'field': f.field,
            'filename': f.filename,
            'length': f.length,
            'contentType': f.contentType.toString(),
          }).toList()}',
      name: 'MAR API',
    );

    try {
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      log('Status: ${streamed.statusCode}', name: 'MAR API');
      log('Response headers: ${streamed.headers}', name: 'MAR API');
      log('Response body: $body', name: 'MAR API');
      log('========================================', name: 'MAR API');

      final decoded = _decode(body);
      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final data = decoded['data'];
        if (data is Map) {
          return LevelRoleUpload.fromJson(Map<String, dynamic>.from(data));
        }
        throw Exception('Upload saved, but the response was incomplete');
      }
      throw Exception(_message(decoded, 'Could not upload the report'));
    } catch (error, stackTrace) {
      log('Upload exception: $error', name: 'MAR API', stackTrace: stackTrace);
      log('========================================', name: 'MAR API');
      rethrow;
    }
  }

  static Future<void> deleteUpload(String id) async {
    final url = Uri.parse('$baseUrl/level-role-upload/$id');
    log('========================================', name: 'MAR API');
    log('DELETE $url', name: 'MAR API');
    log('Headers: ${_safeHeaders(_headers())}', name: 'MAR API');

    final response = await http.delete(url, headers: _headers());
    log('Status: ${response.statusCode}', name: 'MAR API');
    log('Response body: ${response.body}', name: 'MAR API');
    log('========================================', name: 'MAR API');

    if (response.statusCode == 200 || response.statusCode == 201) return;
    throw Exception(
        _message(_decode(response.body), 'Could not delete the report'));
  }

  static Map<String, String> _safeHeaders(Map<String, String> headers) {
    final copy = Map<String, String>.from(headers);
    final auth = copy['Authorization'];
    if (auth != null && auth.length > 20) {
      copy['Authorization'] =
          '${auth.substring(0, 15)}...${auth.substring(auth.length - 6)}';
    }
    return copy;
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
    return name.isEmpty ? 'mar.pdf' : name;
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
