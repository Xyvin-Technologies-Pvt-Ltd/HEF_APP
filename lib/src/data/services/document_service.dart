import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DocumentService {
  static String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;
    if (!fileName.contains('.')) {
      fileName += '.pdf';
    }
    return fileName;
  }

  static Future<void> downloadAndOpenDocument({
    required String url,
    required BuildContext context,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = _getFileNameFromUrl(url);
      final savePath = "${dir.path}/$fileName";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $fileName...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final dio = Dio();
      await dio.download(url, savePath);

      final result = await OpenFile.open(savePath);
      debugPrint("OpenFile result: ${result.message}");

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open file: ${result.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to Download: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
