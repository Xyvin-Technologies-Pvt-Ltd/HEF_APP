import 'dart:convert';
import 'dart:developer';

import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:hef/src/data/globals.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:image_cropper/image_cropper.dart';



import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> imageUpload(String imagePath) async {
  File imageFile = File(imagePath);
  Uint8List imageBytes = await imageFile.readAsBytes();
  print("Original image size: ${imageBytes.lengthInBytes / 1024} KB");


  final String extension = p.extension(imagePath);
  final String? mimeType = lookupMimeType(imagePath, headerBytes: imageBytes);

  log("Image extension: $extension");
  log("Image MIME type: $mimeType");


  // Check if the image is larger than 1 MB
  if (imageBytes.lengthInBytes > 1024 * 1024) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image != null) {
      img.Image resizedImage =
          img.copyResize(image, width: (image.width * 0.5).toInt());
      imageBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 80));
      print("Compressed image size: ${imageBytes.lengthInBytes / 1024} KB");

      // Save compressed image
      imageFile = await File(imagePath).writeAsBytes(imageBytes);
    }
  }
  //////////////////////////////////////
  

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/upload'),
  );
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    return extractImageUrl(responseBody);
  } else {
    var responseBody = await response.stream.bytesToString();
    log(responseBody.toString());
    throw Exception('Failed to upload image');
  }
}



String extractImageUrl(String responseBody) {
  final responseJson = jsonDecode(responseBody);
  log(name: "image upload response", responseJson.toString());
  return responseJson['data'];
}

Future<String> saveUint8ListToFile(Uint8List bytes, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}


class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickImageFromCamera() async {
    final canUseCamera = await requestPermission(Permission.camera);
    if (!canUseCamera) return null;

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    return video != null ? File(video.path) : null;
  }

  Future<File?> pickVideoFromCamera() async {
    final canUseCamera = await requestPermission(Permission.camera);
    if (!canUseCamera) return null;

    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    return video != null ? File(video.path) : null;
  }

  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'rtf',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      log('Error picking document: $e');
    }
    return null;
  }
}



class FileDownloadService {
  final Dio _dio = Dio();

  Future<String> downloadFile({
    required String url,
    String? fileName,
    String? fileExtension,
    MimeType mimeType = MimeType.other,
  }) async {
    try {
      final name = fileName ?? _extractFileName(url);

      log('Starting download: $name');

      // Download file to bytes
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            log('Download progress: $progress%');
          }
        },
      );

      if (response.data == null) {
        throw Exception('Failed to download file data');
      }

      // Determine extension if not provided
      String ext = fileExtension ?? '';
      if (ext.isEmpty) {
        if (mimeType == MimeType.pdf) {
          ext = 'pdf';
        } else if (mimeType == MimeType.jpeg) {
          ext = 'jpg';
        } else if (mimeType == MimeType.png) {
          ext = 'png';
        } else {
          // Try to get from URL
          final uri = Uri.parse(url);
          final segments = uri.path.split('/');
          if (segments.isNotEmpty && segments.last.contains('.')) {
            ext = segments.last.split('.').last;
          } else {
            ext = 'txt';
          }
        }
      }

      // Save using file_saver
      final path = await FileSaver.instance.saveFile(
        name: name,
        bytes: Uint8List.fromList(response.data!),
        fileExtension: ext,
        mimeType: mimeType,
      );

      log('File saved at: $path');
      return path;
    } catch (e) {
      log('Download error: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  /// Extract filename from URL
  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.path.split('/');
      return pathSegments.last.isNotEmpty
          ? pathSegments.last
          : 'file_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}



// ============================================================================
// MEDIA PICKER DIALOG
// ============================================================================

Future<dynamic> pickMedia({
  required BuildContext context,
  bool allowMultiple = false,
  bool enableCrop = false,
  CropAspectRatio? cropRatio,
  bool showDocument = true,
}) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PickSourceDialog(
      allowMultiple: allowMultiple,
      enableCrop: enableCrop,
      cropRatio: cropRatio,
      showDocument: showDocument,
    ),
  );
}




class _PickSourceDialog extends StatelessWidget {
  final bool allowMultiple;
  final bool enableCrop;
  final CropAspectRatio? cropRatio;
  final bool showDocument;

  const _PickSourceDialog({
    required this.allowMultiple,
    required this.enableCrop,
    required this.cropRatio,
    required this.showDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 15,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _option(
            context,
            "Camera",
            Icons.camera_alt_rounded,
            () => _pickFromCamera(context),
          ),
          _option(
            context,
            "Gallery",
            Icons.photo_library_rounded,
            () => _pickFromGallery(context),
          ),
          if (showDocument)
            _option(
              context,
              "Document",
              Icons.insert_drive_file_rounded,
              () => _pickDocument(context),
            ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final canUseCamera = await requestPermission(Permission.camera);
    if (!canUseCamera) {
      if (context.mounted) {
        openAppSettings();
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? rawImage = await picker.pickImage(source: ImageSource.camera);

    if (rawImage == null) {
      Navigator.pop(context, null);
      return;
    }

    if (enableCrop) {
      final cropped = await _cropImage(rawImage.path);
      Navigator.pop(context, cropped);
      return;
    }

    Navigator.pop(context, rawImage);
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();

    if (allowMultiple) {
      final List<XFile> images = await picker.pickMultiImage();

      if (enableCrop) {
        final List<XFile> croppedImages = [];

        for (final img in images) {
          final cropped = await _cropImage(img.path);
          if (cropped != null) croppedImages.add(cropped);
        }

        Navigator.pop(context, croppedImages);
        return;
      }

      Navigator.pop(context, images);
      return;
    }

    final XFile? rawImage = await picker.pickImage(source: ImageSource.gallery);

    if (rawImage == null) {
      Navigator.pop(context, null);
      return;
    }

    if (enableCrop) {
      final cropped = await _cropImage(rawImage.path);
      Navigator.pop(context, cropped);
      return;
    }

    Navigator.pop(context, rawImage);
  }

  // -------------------------
  // PICK DOCUMENT
  // -------------------------
  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.custom,
      allowedExtensions: [
        "pdf",
        "doc",
        "docx",
        "xls",
        "xlsx",
        "png",
        "jpg",
        "jpeg",
      ],
    );
    Navigator.pop(context, result);
  }

  Future<XFile?> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: cropRatio,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "cropImage",
          hideBottomControls: false,
          lockAspectRatio: cropRatio != null,
        ),
        IOSUiSettings(title: "cropImage"),
      ],
    );

    if (croppedFile == null) return null;

    return XFile(croppedFile.path);
  }
}








Future<bool> requestPermission(Permission setting) async {
  final result = await setting.request();
  switch (result) {
    case PermissionStatus.granted:
    case PermissionStatus.limited:
    case PermissionStatus.provisional:
      return true;
    case PermissionStatus.denied:
    case PermissionStatus.restricted:
    case PermissionStatus.permanentlyDenied:
      return false;
  }
}
