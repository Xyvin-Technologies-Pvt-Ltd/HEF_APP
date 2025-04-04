import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/activity_model.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
part 'activity_api.g.dart';

// @riverpod
// Future<List<ActivityModel>> fetchActivity(
//     FetchActivityRef ref, String? chapterId) async {
//   Uri url = Uri.parse('$baseUrl/analytic/chapter/$chapterId');

//   print('Requesting URL: $url');
//   final response = await http.get(
//     url,
//     headers: {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer $token"
//     },
//   );

//   print(json.decode(response.body)['status']);
//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body)['data'];
//     print(response.body);
//     List<ActivityModel> promotions = [];

//     for (var item in data) {
//       promotions.add(ActivityModel.fromJson(item));
//     }
//     print(promotions);
//     return promotions;
//   } else {
//     print(json.decode(response.body)['message']);

//     throw Exception(json.decode(response.body)['message']);
//   }
// }

// Future<String?> downloadAndSaveExcel(String chapterId,
//     {BuildContext? context}) async {
//   final snackbarService = SnackbarService();

//   // Optional loading indicator if context is provided
//   OverlayEntry? loadingOverlay;
//   if (context != null) {
//     loadingOverlay = _createLoadingOverlay();
//     Overlay.of(context).insert(loadingOverlay);
//   }

//   try {
//     final apiUrl = "$baseUrl/analytic/download?chapter=$chapterId";
//     final response = await http.get(
//       Uri.parse(apiUrl),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token"
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       final headers = jsonData['data']['headers'];
//       final body = jsonData['data']['body'];

//       // Create Excel document
//       final excel = Excel.createExcel();
//       final sheet = excel['Activity Report'];

//       // Add header row - explicitly create TextCellValue objects
//       List<CellValue> headerRow = headers
//           .map<CellValue>(
//               (header) => TextCellValue(header['header'].toString()))
//           .toList();
//       sheet.appendRow(headerRow);

//       // Add data rows - explicitly create TextCellValue objects
//       for (var entry in body) {
//         List<CellValue> row = headers.map<CellValue>((header) {
//           String key = header['key'];
//           var value = entry[key] ?? '';

//           // Format date values
//           if (key == 'date' && value.toString().isNotEmpty) {
//             try {
//               final dateTime = DateTime.parse(value.toString());
//               value = DateFormat('yyyy-MM-dd').format(dateTime);
//             } catch (e) {
//               // Keep original value if parsing fails
//             }
//           }

//           // Format amount values
//           if (key == 'amount' && value.toString().isNotEmpty) {
//             try {
//               final amount = double.parse(value.toString());
//               return TextCellValue('${amount.toStringAsFixed(2)}');
//             } catch (e) {
//               // Keep original value if parsing fails
//             }
//           }

//           return TextCellValue(value.toString());
//         }).toList();

//         sheet.appendRow(row);
//       }

//       // Save file with timestamp in filename
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = 'activity_report_$timestamp.xlsx';

//       // Get the path to the Downloads folder
//       String? filePath;

//       if (Platform.isAndroid) {
//         // On Android, we need to use the Downloads directory
//         Directory? downloadsDir;

//         // First try to get the Downloads directory using path_provider
//         try {
//           // For newer Android versions with scoped storage
//           downloadsDir = await getExternalStorageDirectory();
//           // Navigate up to find the Download folder
//           final pathParts = downloadsDir!.path.split('/');
//           final downloadPathParts = pathParts.sublist(0, pathParts.length - 4);
//           downloadPathParts.add('Download');
//           final downloadPath = downloadPathParts.join('/');

//           // Check if the directory exists, create it if not
//           final downloadDir = Directory(downloadPath);
//           if (!await downloadDir.exists()) {
//             await downloadDir.create(recursive: true);
//           }

//           filePath = '$downloadPath/$fileName';
//         } catch (e) {
//           log("Error accessing Downloads directory: $e");

//           // Fallback to app-specific directory
//           downloadsDir = await getExternalStorageDirectory();
//           filePath = '${downloadsDir!.path}/$fileName';
//         }
//       } else if (Platform.isIOS) {
//         // On iOS, we use the Documents directory
//         final documentsDir = await getApplicationDocumentsDirectory();
//         filePath = '${documentsDir.path}/$fileName';
//       } else {
//         throw PlatformException(
//             code: 'UNSUPPORTED_PLATFORM',
//             message: 'This platform is not supported');
//       }

//       // Write file
//       List<int> bytes = excel.encode()!;
//       File file = File(filePath!);
//       await file.writeAsBytes(bytes);

//       // Remove loading overlay if it exists
//       loadingOverlay?.remove();

//       snackbarService.showSnackBar('Report downloaded to Downloads folder');
//       return filePath;
//     } else {
//       final errorMessage =
//           json.decode(response.body)['message'] ?? 'Unknown error';
//       log("Error ${response.statusCode}: $errorMessage");

//       // Remove loading overlay if it exists
//       loadingOverlay?.remove();

//       snackbarService.showSnackBar('Download Failed: $errorMessage');
//       return null;
//     }
//   } catch (e) {
//     log("Download error: $e");

//     // Remove loading overlay if it exists
//     loadingOverlay?.remove();

//     snackbarService.showSnackBar('Download Failed: ${e.toString()}');
//     return null;
//   }
// }

// // Helper function to create a loading overlay
// OverlayEntry _createLoadingOverlay() {
//   return OverlayEntry(
//     builder: (context) => Container(
//       color: Colors.black.withOpacity(0.5),
//       child: Center(
//         child: Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Downloading report...',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }




class ActivityApiService {
  static final _baseUrl = Uri.parse('$baseUrl/analytic');

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };

  /// Fetch Analytics
 static Future<List<ActivityModel>> fetchActivity(
   {required String chapterId}) async {
  Uri url = Uri.parse('$_baseUrl/chapter/$chapterId');

  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: _headers(),
  );

  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    print(response.body);
    List<ActivityModel> promotions = [];

    for (var item in data) {
      promotions.add(ActivityModel.fromJson(item));
    }
    print(promotions);
    return promotions;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

 Future<String?> downloadAndSaveExcel(String chapterId,
    {BuildContext? context}) async {
  final snackbarService = SnackbarService();


  OverlayEntry? loadingOverlay;
  if (context != null) {
    loadingOverlay = _createLoadingOverlay();
    Overlay.of(context).insert(loadingOverlay);
  }

  try {
    final apiUrl = "$_baseUrl/download?chapter=$chapterId";
    final response = await http.get(
      Uri.parse(apiUrl),
      headers:_headers()
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final headers = jsonData['data']['headers'];
      final body = jsonData['data']['body'];


      final excel = Excel.createExcel();
      final sheet = excel['Activity Report'];


      List<CellValue> headerRow = headers
          .map<CellValue>(
              (header) => TextCellValue(header['header'].toString()))
          .toList();
      sheet.appendRow(headerRow);

 
      for (var entry in body) {
        List<CellValue> row = headers.map<CellValue>((header) {
          String key = header['key'];
          var value = entry[key] ?? '';

    
          if (key == 'date' && value.toString().isNotEmpty) {
            try {
              final dateTime = DateTime.parse(value.toString());
              value = DateFormat('yyyy-MM-dd').format(dateTime);
            } catch (e) {
      
            }
          }

          if (key == 'amount' && value.toString().isNotEmpty) {
            try {
              final amount = double.parse(value.toString());
              return TextCellValue('${amount.toStringAsFixed(2)}');
            } catch (e) {
     
            }
          }

          return TextCellValue(value.toString());
        }).toList();

        sheet.appendRow(row);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'activity_report_$timestamp.xlsx';

      String? filePath;

      if (Platform.isAndroid) {
        Directory? downloadsDir;
        try {

          downloadsDir = await getExternalStorageDirectory();
    
          final pathParts = downloadsDir!.path.split('/');
          final downloadPathParts = pathParts.sublist(0, pathParts.length - 4);
          downloadPathParts.add('Download');
          final downloadPath = downloadPathParts.join('/');


          final downloadDir = Directory(downloadPath);
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }

          filePath = '$downloadPath/$fileName';
        } catch (e) {
          log("Error accessing Downloads directory: $e");


          downloadsDir = await getExternalStorageDirectory();
          filePath = '${downloadsDir!.path}/$fileName';
        }
      } else if (Platform.isIOS) {
      
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = '${documentsDir.path}/$fileName';
      } else {
        throw PlatformException(
            code: 'UNSUPPORTED_PLATFORM',
            message: 'This platform is not supported');
      }

 
      List<int> bytes = excel.encode()!;
      File file = File(filePath);
      await file.writeAsBytes(bytes);


      loadingOverlay?.remove();

      snackbarService.showSnackBar('Report downloaded to Downloads folder');
      return filePath;
    } else {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Unknown error';
      log("Error ${response.statusCode}: $errorMessage");

   
      loadingOverlay?.remove();

      snackbarService.showSnackBar('Download Failed: $errorMessage');
      return null;
    }
  } catch (e) {
    log("Download error: $e");


    loadingOverlay?.remove();

    snackbarService.showSnackBar('Download Failed: ${e.toString()}');
    return null;
  }
}

OverlayEntry _createLoadingOverlay() {
  return OverlayEntry(
    builder: (context) => Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Downloading report...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}


@riverpod
Future<List<ActivityModel>> fetchActivity(
  Ref ref, {
 required String? chapterId
}) {
  return ActivityApiService.fetchActivity(
    chapterId:  chapterId??''
  );
}