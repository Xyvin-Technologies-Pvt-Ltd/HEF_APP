import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AnalyticsPdfService {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFFFF5722);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF757575);
  static const PdfColor successColor = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor errorColor = PdfColor.fromInt(0xFFF44336);
  static const PdfColor infoColor = PdfColor.fromInt(0xFF2196F3);

  static Future<File> generateAnalyticsPdf({
    required List<AnalyticsModel> analyticsData,
    required String reportType, // 'received', 'sent', 'history'
    String? startDate,
    String? endDate,
    String? requestType,
  }) async {
    final pdf = pw.Document();

    // Load logo image
    final logoBytes = (await rootBundle.load('assets/pngs/splash_logo.png'))
        .buffer
        .asUint8List();

    // Add content to PDF
    pdf.addPage(
      await _buildReportPage(analyticsData, reportType, startDate, endDate,
          requestType, logoBytes),
    );

    // Save the document
    final bytes = await pdf.save();

    // Get directory for saving
    final directory = await _getDirectory();
    final fileName =
        'analytics_${reportType}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(bytes);
    log('PDF saved to: ${file.path}', name: 'Analytics PDF Service');

    return file;
  }

  static Future<pw.Page> _buildReportPage(
    List<AnalyticsModel> analyticsData,
    String reportType,
    String? startDate,
    String? endDate,
    String? requestType,
    Uint8List? logoBytes,
  ) async {
    final font =
        await pw.Font.ttf(await rootBundle.load('assets/fonts/Helvetica.ttf'));

    // Sort analytics data by date (oldest first)
    final sortedAnalyticsData = [...analyticsData];
    sortedAnalyticsData.sort((a, b) {
      // Handle null dates - put them at the end
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HEF Analytics Report',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _getReportTitle(reportType),
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 16,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
              pw.Container(
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: primaryColor, width: 2),
                ),
                child: pw.Center(
                  child: logoBytes != null
                      ? pw.Image(
                          pw.MemoryImage(logoBytes),
                          width: 60,
                          height: 60,
                          fit: pw.BoxFit.contain,
                        )
                      : pw.Text(
                          'HEF',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Report Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF5F5F5),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Report Summary',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Report Type:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(_getReportTitle(reportType),
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Records:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${analyticsData.length}',
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                if (startDate != null || endDate != null) ...[
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Date Range:',
                              style: pw.TextStyle(
                                  font: font, fontWeight: pw.FontWeight.bold)),
                          pw.Text(_formatDateRange(startDate, endDate),
                              style: pw.TextStyle(font: font)),
                        ],
                      ),
                      if (requestType != null)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Request Type:',
                                style: pw.TextStyle(
                                    font: font,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(requestType,
                                style: pw.TextStyle(font: font)),
                          ],
                        ),
                    ],
                  ),
                ],
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Generated:',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            DateFormat('MMM d, yyyy - h:mm a')
                                .format(DateTime.now()),
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Data Table
          if (analyticsData.isEmpty)
            pw.Center(
              child: pw.Text(
                'No data available for the selected criteria.',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 16,
                  color: secondaryColor,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            )
          else
            pw.Column(
              children: [
                // Table Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(8),
                      topRight: pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Date',
                          style: pw.TextStyle(
                            font: font,
                            color: PdfColor.fromInt(0xFFFFFFFF),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Member Name',
                          style: pw.TextStyle(
                            font: font,
                            color: PdfColor.fromInt(0xFFFFFFFF),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Type',
                          style: pw.TextStyle(
                            font: font,
                            color: PdfColor.fromInt(0xFFFFFFFF),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'Title/Description',
                          style: pw.TextStyle(
                            font: font,
                            color: PdfColor.fromInt(0xFFFFFFFF),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Amount',
                          style: pw.TextStyle(
                            font: font,
                            color: PdfColor.fromInt(0xFFFFFFFF),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Status',
                          style: pw.TextStyle(
                            font: font,
                            color: PdfColor.fromInt(0xFFFFFFFF),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Data
                ...sortedAnalyticsData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final analytic = entry.value;
                  final isEven = index % 2 == 0;

                  return pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: isEven
                          ? PdfColor.fromInt(0xFFFAFAFA)
                          : PdfColor.fromInt(0xFFFFFFFF),
                      border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0)),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            _formatDateTime(analytic.date, analytic.time),
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            analytic.username ?? 'N/A',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            analytic.type ?? 'N/A',
                            style: pw.TextStyle(font: font, fontSize: 10),
                            maxLines: 1,
                            overflow: pw.TextOverflow.clip,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            analytic.title ?? 'N/A',
                            style: pw.TextStyle(font: font, fontSize: 10),
                            maxLines: 2,
                            overflow: pw.TextOverflow.clip,
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            _formatAmount(analytic.amount),
                            style: pw.TextStyle(font: font, fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: _getStatusColor(analytic.status ?? ''),
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text(
                              (analytic.status ?? 'N/A').toUpperCase(),
                              style: pw.TextStyle(
                                font: font,
                                color: PdfColor.fromInt(0xFFFFFFFF),
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),

          pw.SizedBox(height: 24),

          // Footer
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Generated by HEF Analytics App',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: secondaryColor,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<Directory> _getDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      final downloadsPath = '${directory!.path}/Download/HEF_Analytics';
      final downloadsDirectory = Directory(downloadsPath);

      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }

      return downloadsDirectory;
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    }
  }

  static String _getReportTitle(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'received':
        return 'Received Requests Report';
      case 'sent':
        return 'Sent Requests Report';
      case 'history':
        return 'All Requests History Report';
      default:
        return 'Analytics Report';
    }
  }

  static String _formatDateRange(String? startDate, String? endDate) {
    if (startDate != null && endDate != null) {
      return '$startDate to $endDate';
    } else if (startDate != null) {
      return 'From $startDate';
    } else if (endDate != null) {
      return 'Until $endDate';
    } else {
      return 'All time';
    }
  }

  static String _formatAmount(double? amount) {
    if (amount != null) {
      return '\₹ ${amount.toStringAsFixed(2)}';
    }
    return 'N/A';
  }

  static String _formatDateTime(DateTime? date, String? time) {
    if (date == null && time == null) return 'N/A';

    final dateStr =
        date != null ? DateFormat('MMM d, yyyy').format(date.toLocal()) : 'N/A';
    final timeStr = time ?? '';

    return timeStr.isNotEmpty ? '$dateStr - $timeStr' : dateStr;
  }

  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return successColor;
      case 'completed':
        return successColor;
      case 'rejected':
        return errorColor;
      case 'meeting_scheduled':
        return infoColor;
      default:
        return secondaryColor;
    }
  }

  static Future<void> openPdfFile(File file) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      log('Error opening PDF file: $e', name: 'Analytics PDF Service');
      throw Exception('Failed to open PDF file: $e');
    }
  }
}
