import 'dart:io';

import 'package:hef/src/data/api_routes/business_api/business_api.dart';

import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/interface/components/DropDown/addBusiness_type.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class ShowAdddBusinessSheet extends StatefulWidget {
  final Future<File?> Function() pickImage;
  final TextEditingController textController;

  const ShowAdddBusinessSheet({
    Key? key,
    required this.pickImage,
    required this.textController,
  }) : super(key: key);

  @override
  State<ShowAdddBusinessSheet> createState() => _ShowAdddBusinessSheetState();
}

class _ShowAdddBusinessSheetState extends State<ShowAdddBusinessSheet> {
  File? selectedImage;
  String? selectedType;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? mediaUrl;

  Future<void> _handleImagePick() async {
    final File? pickedImage = await widget.pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    SnackbarService snackbarService = SnackbarService();
    return PopScope(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          // Added this widget
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Business',
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
                // AddbusinessTypeDropDown(
                //   onValueChanged: (value) {
                //     setState(() {
                //       selectedType = value;
                //     });
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please select a type';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 20),
                FormField<File>(
                  initialValue: selectedImage,
                  builder: (FormFieldState<File> state) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: _handleImagePick,
                          child: Container(
                            width: double.infinity,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: state.hasError
                                  ? Border.all(color: Colors.red)
                                  : null,
                            ),
                            child: selectedImage == null
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add,
                                            size: 27, color: kPrimaryColor),
                                        SizedBox(height: 10),
                                        Text(
                                          'Upload Image',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 102, 101, 101)),
                                        ),
                                      ],
                                    ),
                                  )
                                : Image.file(
                                    selectedImage!,
                                    fit: BoxFit.contain,
                                    width: 120,
                                    height: 120,
                                  ),
                          ),
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: widget.textController,
                  maxLines: ((MediaQuery.sizeOf(context).height) / 150).toInt(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Add content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: LoadingAnimation()),
                      );

                      try {
                        print(selectedType);

                        if (selectedImage != null) {
                          mediaUrl = await imageUpload(
                            selectedImage!.path,
                          );
                        }

                        await BusinessApiService. uploadBusiness(
                          media: mediaUrl,
                          content: widget.textController.text,
                        );
                        widget.textController.clear();
                        selectedImage = null;

                        navigationService
                            .pop(); // Close the dialog after completion
                        snackbarService.showSnackBar(
                            'Your Post Will Be Reviewed By Admin');
                      } finally {
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // Ensure dialog is dismissed
                      }
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        WidgetStateProperty.all<Color>(kPrimaryColor),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(kPrimaryColor),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  child: const Text(
                    'ADD POST',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
