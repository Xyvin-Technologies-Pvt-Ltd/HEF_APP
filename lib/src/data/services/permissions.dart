import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> ensurePhotoPermission(BuildContext context) async {
  if (!Platform.isIOS) return true;

  final status = await Permission.photos.request();

  if (status.isGranted) return true;

  if (status.isDenied || status.isPermanentlyDenied) {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Photo access is required to pick images. Please enable it from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return false;
  }

  return false;
}
