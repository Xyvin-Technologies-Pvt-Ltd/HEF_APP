import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<void> captureAndShareWidgetScreenshot(BuildContext context) async {
  // Create a GlobalKey to hold the widget's RepaintBoundary
  final boundaryKey = GlobalKey();
  String userId = '';
  // Define the widget to capture
  final widgetToCapture = RepaintBoundary(
    key: boundaryKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            final asyncUser = ref.watch(userProvider);
            return asyncUser.when(
              data: (user) {
                userId = user.uid ?? '';
                return Container(
                  decoration: const BoxDecoration(color: kScaffoldColor),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, right: 15),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                width: double
                                    .infinity, // Sets a bounded width constraint
                                child: Column(
                                  children: [
                                    const SizedBox(height: 100),
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Column(
                                          children: [
                                            user.image != null &&
                                                    user.image != ''
                                                ? Container(
                                                    width:
                                                        100, // Diameter + border width
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: kPrimaryColor,
                                                        width:
                                                            2.0, // Border width
                                                      ),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        user.image ?? '',
                                                        width:
                                                            74, // Diameter of the circle (excluding border)
                                                        height: 74,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/icons/dummy_person.png'),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(user.name ?? '',
                                                  style: kHeadTitleB),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              if (user.company?.designation !=
                                                      null &&
                                                  user.company?.designation !=
                                                      '')
                                                Text(
                                                    user.company?.designation ??
                                                        '',
                                                    style: kSmallTitleM),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(user.company?.name ?? '',
                                                  style: kSmallerTitleR),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: kWhite,
                          ),
                          child: QrImageView(
                            size: 285,
                            data: 'https://admin.hef.com/user/${user.uid}',
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (user.phone != null)
                          Row(
                            children: [
                              const Icon(Icons.phone, color: kPrimaryColor),
                              const SizedBox(width: 10),
                              Text(user.phone?.toString() ?? ''),
                            ],
                          ),
                        const SizedBox(height: 10),
                        if (user.email != null)
                          Row(
                            children: [
                              const Icon(Icons.email, color: kPrimaryColor),
                              const SizedBox(width: 10),
                              Text(user.email ?? ''),
                            ],
                          ),
                        const SizedBox(height: 10),
                        if (user.address != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: kPrimaryColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  user.address ?? '',
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  const Center(child: Text('Error loading user')),
            );
          },
        ),
      ),
    ),
  );

  // Create an OverlayEntry to render the widget
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (_) => Material(
      color: Colors.transparent,
      child: Center(child: widgetToCapture),
    ),
  );

  // Add the widget to the overlay
  overlay.insert(overlayEntry);

  // Allow time for rendering
  await Future.delayed(const Duration(milliseconds: 500));

  // Capture the screenshot
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    overlayEntry.remove(); // Clean up the overlay
    return;
  }

  // Convert to image
  final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  overlayEntry.remove(); // Clean up the overlay

  if (byteData == null) return;

  final Uint8List pngBytes = byteData.buffer.asUint8List();

  // Save the image as a temporary file
  final tempDir = await getTemporaryDirectory();
  final file =
      await File('${tempDir.path}/screenshot.png').writeAsBytes(pngBytes);

  // Share the screenshot
  Share.shareXFiles(
    [XFile(file.path)],
    text:
        'Check out my profile on HEF!:\n https://admin.hef.com/user/${userId}',
  );
}
