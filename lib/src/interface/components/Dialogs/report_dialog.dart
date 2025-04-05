
import 'package:flutter/material.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';

class ReportPersonDialog extends StatelessWidget {
  final String? userId;
  final VoidCallback onReportStatusChanged;
  final String reportType;
  final String reportedItemId;

  ReportPersonDialog({
    this.userId,
    required this.onReportStatusChanged,
    super.key,
    required this.reportType,
    required this.reportedItemId,
  });

  TextEditingController reasonController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 12,
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to report this ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 30.0),
            TextFormField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color(0xFFE30613),
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Reason is required'; // Error message when the field is empty
                }
                return null; // Return null if the input is valid
              },
            ),
            const SizedBox(height: 20.0),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFFE30613),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () async {
        
     UserService.        createReport(
                reportedItemId: reportedItemId,
         
                reportType: reportType);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFE30613),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
            shadowColor: Color(0xFFE30613),
            elevation: 6,
          ),
          child: Text(
            'Report',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}

// Function to show the BlockPersonDialog
void showReportPersonDialog({
  required BuildContext context,
  String? userId,
  required VoidCallback onReportStatusChanged,
  required String reportType,
  required String reportedItemId,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ReportPersonDialog(
        reportType: reportType,
        userId: userId,
        onReportStatusChanged: onReportStatusChanged,
        reportedItemId: reportedItemId,
      );
    },
  );
}
