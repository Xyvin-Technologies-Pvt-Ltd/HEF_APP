// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:hef/src/data/api_routes/events_api/events_api.dart';
// import 'package:hef/src/data/constants/color_constants.dart';
// import 'package:hef/src/interface/screens/main_pages/event/attendance_marked.dart';
// // import 'package:mobile_scanner/mobile_scanner.dart';

// class QRScannerPage extends StatefulWidget {
//   final String eventId;
//   const QRScannerPage({super.key, required this.eventId});

//   @override
//   _QRScannerPageState createState() => _QRScannerPageState();
// }

// class _QRScannerPageState extends State<QRScannerPage> {
//   final MobileScannerController scannerController = MobileScannerController();
//   bool _isNavigating = false; // Prevent multiple navigations

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scan QR Code'),
//         backgroundColor: kPrimaryColor,
//       ),
//       body: MobileScanner(
//         controller: scannerController,
//         onDetect: (capture) async {
//           if (_isNavigating) return; // Skip if already navigating

//           final List<Barcode> barcodes = capture.barcodes;
//           for (final barcode in barcodes) {
//             if (barcode.rawValue != null) {
//               final String link = barcode.rawValue!;
//               log('QR link: $link');
//               final String userId = link.split('/').last;
//               log('QR userId: $userId');

//               setState(() {
//                 _isNavigating = true;
//               });

//               // Stop the scanner
//               scannerController.stop();

//               final attendant = await markAttendanceEvent(
//                   eventId: widget.eventId, userId: userId);
//               log('attendant:$attendant');
//               // Navigate to the next page
//               if (attendant != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EventAttendanceSuccessPage(
//                       user: attendant,
//                     ),
//                   ),
//                 ).then((_) {
//                   // Reset navigating state when returning to this page
//                   setState(() {
                    
//                     _isNavigating = false;
//                   });

//                   // Resume scanning when back
//                   scannerController.start();
//                 });
//               } else {
//                 log('im in else condition');
//                 setState(() {
//                   _isNavigating = false;
//                 });
//               }
//               break;
//             }
//           }
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     scannerController.dispose();
//     super.dispose();
//   }
// }
