import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  /// Generate PDF from analytics data
  static Future<File?> generateAnalyticsPDF(
    Map<String, dynamic> downloadResponse, {
    String? customTitle,
  }) async {
    try {
      final pdf = pw.Document();

      // Add title
      final title = customTitle ?? 'Analytics Report';

      // Get data with proper null checking
      final data = downloadResponse['data'];
      log('PDF Service - Raw download response keys: ${downloadResponse.keys}');
      log('PDF Service - Data section: $data');
      log('PDF Service - Data type: ${data.runtimeType}');

      if (data == null) {
        throw Exception('Data is null in download response');
      }

      final headers = data['headers'];
      final body = data['body'];

      log('PDF Service - Headers: $headers');
      log('PDF Service - Body length: ${body?.length}');
      log('PDF Service - Body type: ${body?.runtimeType}');

      if (headers == null || body == null) {
        throw Exception('Headers or body is null in download response');
      }

      if (headers is! List<dynamic> || body is! List<dynamic>) {
        throw Exception('Headers or body is not a list in download response');
      }

      // Create table data
      final tableData = <List<String>>[];

      // Add headers
      if (headers.isEmpty) {
        throw Exception('Headers list is empty');
      }

      log('PDF Service - Processing ${headers.length} headers');
      final headerRow = headers.map((h) {
        if (h is! Map<String, dynamic> || h['header'] == null) {
          log('PDF Service - Warning: Invalid header structure: $h');
          return 'Unknown Header';
        }
        final headerText = h['header'].toString();
        log('PDF Service - Header: $headerText');
        return headerText;
      }).toList();
      tableData.add(headerRow);

      log('PDF Service - Header row created: $headerRow');

      // Add data rows
      log('PDF Service - Processing ${body.length} data rows');
      int validRowCount = 0;
      for (int i = 0; i < body.length; i++) {
        final item = body[i];
        if (item is! Map<String, dynamic>) {
          log('Warning: Skipping invalid row data at index $i: $item');
          continue;
        }

        final row = <String>[];
        for (int j = 0; j < headers.length; j++) {
          final header = headers[j];
          if (header is! Map<String, dynamic> || header['key'] == null) {
            row.add('');
            continue;
          }
          final key = header['key'].toString();
          final value = item[key]?.toString() ?? '';
          row.add(value);
        }

        // Only add non-empty rows
        if (row.any((cell) => cell.isNotEmpty)) {
          tableData.add(row);
          validRowCount++;
        }
      }

      log('PDF Service - Total table rows created: ${tableData.length}');
      log('PDF Service - Valid data rows: $validRowCount');

      if (tableData.length > 1) {
        log('PDF Service - First data row: ${tableData[1]}');
        log('PDF Service - Sample row: ${tableData[tableData.length > 2 ? 2 : 1]}');
      }

      if (tableData.length <= 1) {
        throw Exception('No valid data rows found in the response');
      }

      // Enhanced table with better formatting
      final tableWidget = pw.Table(
        border: pw.TableBorder.all(width: 1.0),
        children: tableData.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final row = entry.value;

          // Make header row bold
          final isHeader = rowIndex == 0;

          return pw.TableRow(
            decoration: isHeader
                ? pw.BoxDecoration(
                    color: PdfColors.grey300,
                  )
                : null,
            children: row.map((cell) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  cell,
                  style: pw.TextStyle(
                    fontSize: isHeader ? 12 : 10,
                    fontWeight:
                        isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: isHeader ? PdfColors.black : PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.left,
                ),
              );
            }).toList(),
          );
        }).toList(),
      );

      // Add title and table to PDF
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateTime.now().toString().split(' ')[0]} | Total Records: ${tableData.length - 1}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: tableWidget,
                ),
              ),
            ],
          ),
        ),
      );

      // Save PDF
      final bytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final fileName =
          'analytics_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      log('PDF generated successfully: ${file.path}');
      log('PDF size: ${bytes.length} bytes');
      return file;
    } catch (e, stackTrace) {
      log('Error generating PDF: $e');
      log('Stack trace: $stackTrace');

      // Provide more specific error messages
      if (e is Exception) {
        rethrow;
      }

      return null;
    }
  }

  /// Share PDF file
  static Future<void> sharePDF(File pdfFile, {String? message}) async {
    try {
      final xFile = XFile(pdfFile.path, mimeType: 'application/pdf');
      await Share.shareXFiles(
        [xFile],
        subject: 'Analytics Report',
        text: message ?? 'Please find attached analytics report.',
      );
    } catch (e) {
      log('Error sharing PDF: $e');
    }
  }

  /// Preview PDF
  static Future<void> previewPDF(File pdfFile) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
        name: 'Analytics Report',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      log('Error previewing PDF: $e');
    }
  }

  /// Generate and open PDF
  static Future<void> generateAndOpenPDF(
    Map<String, dynamic> downloadResponse, {
    String? title,
    bool shareImmediately = false,
  }) async {
    final pdfFile = await generateAnalyticsPDF(
      downloadResponse,
      customTitle: title,
    );
    if (pdfFile != null) {
      if (shareImmediately) {
        await sharePDF(pdfFile);
      } else {
        await previewPDF(pdfFile);
      }
    }
  }
}
