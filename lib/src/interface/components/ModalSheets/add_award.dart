import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

import '../Buttons/primary_button.dart';

class ShowEnterAwardSheet extends StatefulWidget {
  final TextEditingController textController1;
  final TextEditingController textController2;
  final Future<void> Function()? addAwardCard;
  final Future<void> Function()? editAwardCard;
  final String imageType;
  final Future<File?> Function({required String imageType}) pickImage;
  final String? imageUrl;
  const ShowEnterAwardSheet({
    required this.textController1,
    required this.textController2,
    this.addAwardCard,
    required this.pickImage,
    required this.imageType,
    super.key,
    this.editAwardCard,
    this.imageUrl,
  });

  @override
  State<ShowEnterAwardSheet> createState() => _ShowEnterAwardSheetState();
}

class _ShowEnterAwardSheetState extends State<ShowEnterAwardSheet> {
  final _formKey = GlobalKey<FormState>();
  File? awardImage; // Moved awardImage to State
  bool get isEditMode => widget.editAwardCard != null;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        widget.textController1.text = '';
        widget.textController2.text = '';
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
                    'Add Awards',
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
              FormField<File>(
                initialValue: awardImage,
                validator: (value) {
                  if (!isEditMode && value == null && widget.imageUrl == null) {
                    return 'Please upload an image';
                  }
                  return null;
                },
                builder: (FormFieldState<File> state) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final pickedFile = await widget.pickImage(
                              imageType: widget.imageType);
                          if (pickedFile == null) {
                            return; // Don't pop if no image selected
                          }
                          setState(() {
                            awardImage = pickedFile;
                            state.didChange(
                                pickedFile); // Update form field state
                          });
                        },
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: state.hasError
                                ? Border.all(color: Colors.red)
                                : null,
                          ),
                          child: awardImage == null
                              ? widget.imageUrl != null
                                  ? Center(
                                      child:
                                          Image.network(widget.imageUrl ?? ''),
                                    )
                                  : const Center(
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
                              : Center(
                                  child: Image.file(
                                  awardImage!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )),
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
              ModalSheetTextFormField(
                label: 'Add name',
                textController: widget.textController1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ModalSheetTextFormField(
                label: 'Add Authority name',
                textController: widget.textController2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the authority name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              customButton(
                label: isEditMode ? 'UPDATE' : 'SAVE',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: LoadingAnimation()),
                    );

                    try {
                      if (widget.addAwardCard != null) {
                        await widget.addAwardCard!();
                      } else {
                        await widget.editAwardCard!();
                      }
                      widget.textController1.clear();
                      widget.textController2.clear();

                      if (awardImage != null) {
                        setState(() {
                          awardImage = null; // Clear the image after saving
                        });
                      }
                    } finally {
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    }
                  }
                },
                fontSize: 16,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
