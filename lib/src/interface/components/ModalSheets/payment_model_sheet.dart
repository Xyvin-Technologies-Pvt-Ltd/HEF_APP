import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class ShowPaymentUploadSheet extends StatefulWidget {
  final Future<File?> Function({required String imageType}) pickImage;

  final String imageType;
  File? paymentImage;
  final String subscriptionType;

  ShowPaymentUploadSheet({
    super.key,
    required this.pickImage,
    required this.imageType,
    this.paymentImage,
    required this.subscriptionType,
  });

  @override
  State<ShowPaymentUploadSheet> createState() => _ShowPaymentUploadSheetState();
}

class _ShowPaymentUploadSheetState extends State<ShowPaymentUploadSheet> {
  String? selectedYearId; // Variable to store the selected academic year ID
  TextEditingController amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final pickedFile = await widget.pickImage(imageType: 'payment');
              if (pickedFile == null) {
                Navigator.pop(context);
              }
              setState(() {
                widget.paymentImage = pickedFile;
              });
            },
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: widget.paymentImage == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 27, color: Color(0xFF004797)),
                          SizedBox(height: 10),
                          Text(
                            'Upload Image',
                            style: TextStyle(
                                color: Color.fromARGB(255, 102, 101, 101)),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Image.file(
                        widget.paymentImage!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, ref, child) {
              final asyncPaymentYears = ref.watch(getPaymentYearsProvider);
              return asyncPaymentYears.when(
                data: (paymentYears) {
                  return DropdownButtonFormField<String>(
                    value: selectedYearId,
                    hint: const Text('Select Year'),
                    items: paymentYears
                        .map(
                          (year) => DropdownMenuItem<String>(
                            value: year.id,
                            child: Text(year.academicYear ?? 'Unknown Year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYearId = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) {
                  return const Center(
                    child: LoadingAnimation(),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.numberWithOptions(),
            controller: amountController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          customButton(
            label: 'SAVE',
            onPressed: () async {
              log(selectedYearId.toString());
              log(amountController.text.toString());

              if (selectedYearId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select an academic year'),
                  ),
                );
                return;
              }

              // Check if an image is uploaded
              if (widget.paymentImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please upload an image'),
                  ),
                );
                return;
              }

              // Check if the amount is provided and valid
              if (amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter the amount'),
                  ),
                );
                return;
              }
              final String paymentImageUrl = await imageUpload(
                widget.paymentImage!.path,
              );
              // Attempt to upload the payment details
              String? success = await uploadPayment(
                  parentSub: selectedYearId ?? '',
                  catergory: widget.subscriptionType,
                  amount: amountController.text,
                  image: paymentImageUrl);

              if (success != null) {
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to upload payment details'),
                  ),
                );
              }
            },
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
