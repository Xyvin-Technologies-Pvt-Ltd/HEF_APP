import 'dart:developer';
import 'dart:typed_data';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> saveQr({
  required ScreenshotController screenshotController,
}) async {
        SnackbarService snackbarService = SnackbarService();
  var status = await Permission.photos.request();
  if (status.isGranted) {
    // Capture the screenshot
    screenshotController.capture().then((Uint8List? image) async {

      log('capture  image$image');
      if (image != null) {
        // Save the screenshot to the gallery
        final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(image),
          quality: 100,
          name: "HEF${DateTime.now().millisecondsSinceEpoch}",
        );
        print(result); // You can check the result if needed
        snackbarService.showSnackBar('Downloaded to gallery!');
      }
    }).catchError((onError) {
      print(onError);
 snackbarService.showSnackBar('Error Saving to gallery!');
    });
  } else {
   snackbarService.showSnackBar('Permission not granted!');
  }
}
