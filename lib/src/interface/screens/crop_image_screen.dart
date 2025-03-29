import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
 
class CropImageScreen extends StatefulWidget {
  final File imageFile;

  const CropImageScreen({super.key, required this.imageFile});

  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  late CustomImageCropController controller;

  @override
  void initState() {
    super.initState();
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final croppedImage = await controller.onCropImage();
              if (croppedImage != null) {
                Navigator.of(context).pop(croppedImage);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomImageCrop(
              backgroundColor: Colors.black,
              cropController: controller,
              image: FileImage(widget.imageFile),
              ratio: Ratio(width: 4, height: 5),
              shape: CustomCropShape.Ratio,
              borderRadius: 0,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.reset,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () => controller.addTransition(
                    CropImageData(scale: 1.33),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () => controller.addTransition(
                    CropImageData(scale: 0.75),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_left),
                  onPressed: () => controller.addTransition(
                    CropImageData(angle: -pi / 4),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_right),
                  onPressed: () => controller.addTransition(
                    CropImageData(angle: pi / 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
