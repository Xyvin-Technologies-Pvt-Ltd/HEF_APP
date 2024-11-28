import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minio_flutter/io.dart';
import 'package:minio_flutter/minio.dart';

import 'package:path/path.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Future<String> imageUpload(String imageName, String imagePath) async {
  // Initialize Minio
  Minio.init(
    endPoint: 's3.amazonaws.com',
    accessKey: dotenv.env['AWS_ACCESS_KEY_ID']!,
    secretKey: dotenv.env['AWS_SECRET_ACCESS_KEY']!,
    region: 'ap-south-1',
  );

  // Load the image as bytes
  File imageFile = File(imagePath);
  Uint8List imageBytes = await imageFile.readAsBytes();
  print("Original image size: ${imageBytes.lengthInBytes / 1024} KB");

  // Check if the image is larger than 1 MB (1 MB = 1024 * 1024 bytes)
  if (imageBytes.lengthInBytes > 1024 * 1024) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image != null) {
      // Compress the image by resizing or reducing quality
      img.Image resizedImage = img.copyResize(image,
          width: (image.width * 0.5).toInt()); // Resize to 50%
      imageBytes = Uint8List.fromList(
          img.encodeJpg(resizedImage, quality: 80)); // Adjust quality as needed
      print("Compressed image size: ${imageBytes.lengthInBytes / 1024} KB");

      // Save the compressed image temporarily for upload
      imageFile = await File(imagePath).writeAsBytes(imageBytes);
    }
  }

  // Upload the image to Minio
  await Minio.shared
      .fPutObject('akcaf-s3-bucket', basename(imageName), imageFile.path);
  final imageUrl =
      "https://akcaf-s3-bucket.s3.ap-south-1.amazonaws.com/${basename(imagePath)}";
  return imageUrl;
}
