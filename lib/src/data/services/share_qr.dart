import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> captureAndShareWidgetScreenshot(BuildContext context) async {
  // // Create a GlobalKey to hold the widget's RepaintBoundary
  // final boundaryKey = GlobalKey();
  // String userId = '';
  // // Define the widget to capture
  // final widgetToCapture = RepaintBoundary(
  //   key: boundaryKey,
  //   child: MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: Scaffold(
  //       body: Consumer(
  //         builder: (context, ref, child) {
  //           final asyncUser = ref.watch(userProvider);
  //           return asyncUser.when(
  //             data: (user) {
  //               userId = user.uid ?? '';
  //               return Container(
  //                 color: Colors.white,
  //                 padding: const EdgeInsets.symmetric(horizontal: 25),
  //                 child: Column(
  //                   children: [
  //                     const SizedBox(height: 100),
  //                     Row(
  //                       children: [
  //                         if (user.image == null ||
  //                             user.image == '')
  //                           Image.asset(
  //                             scale: 1.3,
  //                             'assets/icons/dummy_person_large.png',
  //                           )
  //                         else
  //                           CircleAvatar(
  //                             radius: 40,
  //                             backgroundImage:
  //                                 NetworkImage(user.image!),
  //                           ),
  //                         const SizedBox(width: 10),
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               // Text(
  //                               //   '${user.abbreviation ?? ''} ${user.name ?? ''}',
  //                               //   style: const TextStyle(
  //                               //     fontSize: 20,
  //                               //     fontWeight: FontWeight.bold,
  //                               //   ),
  //                               // ),
  //                               if (user.company?.designation != null)
  //                                 Text(
  //                                   user.company?.designation??'',
  //                                   style: const TextStyle(fontSize: 16),
  //                                 ),
  //                               if (user.company?.name!= null)
  //                                 Text(
  //                                   user.name!,
  //                                   style: const TextStyle(color: Colors.grey),
  //                                 ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 20),
  //                     QrImageView(
  //                       size: 250,
  //                       data: 'https://admin.kssiathrissur.com/user/${user.id}',
  //                     ),
  //                     const SizedBox(height: 20),
  //                     if (user.phone != null && user.phoneNumbers != '')
  //                       Row(
  //                         children: [
  //                           const Icon(Icons.phone, color: Color(0xFF004797)),
  //                           const SizedBox(width: 10),
  //                           Text(user.phoneNumbers?.personal ?? ''),
  //                         ],
  //                       ),
  //                     const SizedBox(height: 10),
  //                     if (user.email != null && user.email != '')
  //                       Row(
  //                         children: [
  //                           const Icon(Icons.email, color: Color(0xFF004797)),
  //                           const SizedBox(width: 10),
  //                           Text(user.email!),
  //                         ],
  //                       ),
  //                     const SizedBox(height: 10),
  //                     if (user.address != null && user.address != '')
  //                       Row(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Icon(Icons.location_on,
  //                               color: Color(0xFF004797)),
  //                           const SizedBox(width: 10),
  //                           Expanded(
  //                             child: Text(
  //                               user.address!,
  //                               overflow: TextOverflow.ellipsis,
  //                               maxLines: 2,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     const SizedBox(height: 30),
  //                   ],
  //                 ),
  //               );
  //             },
  //             loading: () => const Center(child: CircularProgressIndicator()),
  //             error: (error, stackTrace) =>
  //                 const Center(child: Text('Error loading user')),
  //           );
  //         },
  //       ),
  //     ),
  //   ),
  // );

  // // Create an OverlayEntry to render the widget
  // final overlay = Overlay.of(context);
  // final overlayEntry = OverlayEntry(
  //   builder: (_) => Material(
  //     color: Colors.transparent,
  //     child: Center(child: widgetToCapture),
  //   ),
  // );

  // // Add the widget to the overlay
  // overlay.insert(overlayEntry);

  // // Allow time for rendering
  // await Future.delayed(const Duration(milliseconds: 500));

  // // Capture the screenshot
  // final boundary =
  //     boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  // if (boundary == null) {
  //   overlayEntry.remove(); // Clean up the overlay
  //   return;
  // }

  // // Convert to image
  // final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
  // final ByteData? byteData =
  //     await image.toByteData(format: ui.ImageByteFormat.png);
  // overlayEntry.remove(); // Clean up the overlay

  // if (byteData == null) return;

  // final Uint8List pngBytes = byteData.buffer.asUint8List();

  // // Save the image as a temporary file
  // final tempDir = await getTemporaryDirectory();
  // final file =
  //     await File('${tempDir.path}/screenshot.png').writeAsBytes(pngBytes);

  // // Share the screenshot
  // Share.shareXFiles(
  //   [XFile(file.path)],
  //   text:
  //       'Check out my profile on HEF!:\n https://admin.hef.com/user/${userId}',
  // );
}
