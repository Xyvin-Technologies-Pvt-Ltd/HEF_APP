import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/level_models/level_model.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path/path.dart' as Path;

class CreateNotificationPage extends ConsumerStatefulWidget {
  final String level;
  final String? levelId;
  const CreateNotificationPage({
    super.key,
    required this.level,
    this.levelId,
  });

  @override
  ConsumerState<CreateNotificationPage> createState() =>
      _CreateNotificationPageState();
}

class _CreateNotificationPageState
    extends ConsumerState<CreateNotificationPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  List<LevelModel> _selectedItems = [];
  List<String> _selectedItemsId = [];
  File? notificationImage;
  String? notificationImageUrl;
  void _showMultiSelect(List<LevelModel> items, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: items.map((e) => MultiSelectItem(e, e.name)).toList(),
          initialValue: _selectedItems,
          onConfirm: (values) {
            setState(() {
              _selectedItems = values.cast<LevelModel>();
              // Extract ids from selected LevelModel objects
              _selectedItemsId = _selectedItems.map((item) => item.id).toList();
            });
          },
          title: Text(
            "Select ${widget.level}",
            style: const TextStyle(
                color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          selectedColor: kPrimaryColor,
          checkColor: Colors.white,
          searchable: true,
          confirmText: const Text(
            "CONFIRM",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
          cancelText: const Text(
            "CANCEL",
            style: TextStyle(color: Color.fromARGB(255, 130, 130, 130)),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  Future<File?> _pickFile({required String imageType}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
      ],
    );

    if (result != null) {
      notificationImage = File(result.files.single.path!);
      return notificationImage;
    }
    return null;
  }

  AsyncValue<List<LevelModel>>? asyncLevelValues;
  @override
  Widget build(BuildContext context) {
    log('level:${widget.levelId.toString()}');
    if (widget.levelId == null) {
      asyncLevelValues = ref.watch(fetchStatesProvider);
    } else {
      asyncLevelValues =
          ref.watch(fetchLevelDataProvider(widget.levelId ?? '', widget.level));
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Create Notification"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown
            const Text(
              'Send to',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (asyncLevelValues != null)
              asyncLevelValues!.when(
                data: (selectionValues) {
                  return GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _showMultiSelect(selectionValues, context);
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: kWhite,
                        border: Border.all(color: kGreyLight),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select",
                            style: TextStyle(color: kGreyDark),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => const SizedBox(),
              ),

            SizedBox(
              height: 10,
            ),
            MultiSelectChipDisplay(
              items: _selectedItems
                  .map((e) => MultiSelectItem(e, e.name))
                  .toList(),
              onTap: (value) {
                setState(() {
                  _selectedItems.remove(value);
                  // Update IDs dynamically when items are removed
                  _selectedItemsId =
                      _selectedItems.map((item) => item.id).toList();
                });
              },
              icon: const Icon(Icons.close),
              chipColor: const Color.fromARGB(255, 224, 224, 224),
              textStyle: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 16),

            // Title Field
            const Text(
              'Title',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              labelText: 'Notification Title',
              textController: titleController,
            ),
            const SizedBox(height: 16),

            // Message Field
            const Text(
              'Message',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              maxLines: 3,
              labelText: 'Message',
              textController: messageController,
            ),
            const SizedBox(height: 16),

            // Upload Image
            const Text(
              'Upload Image',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: LoadingAnimation(),
                    );
                  },
                );

                final pickedFile = await _pickFile(imageType: 'product');
                if (pickedFile == null) {
                  Navigator.pop(context);
                }

                setState(() {
                  notificationImage = pickedFile;
                });

                Navigator.of(context).pop();
              },
              child: DottedBorder(
                color: Colors.grey,
                strokeWidth: 1,
                dashPattern: [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  color: kWhite,
                  child: Center(
                      child: notificationImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Upload Image',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  if (notificationImage != null)
                                    Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        height: double.infinity,
                                        width: 60,
                                        child: Image.file(notificationImage!)),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        notificationImage = null;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                        'assets/svg/icons/delete_account.svg'),
                                  ),
                                ],
                              ),
                            )),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add Link
            const Text(
              'Add Link',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              labelText: 'Link',
              textController: linkController,
            ),
            const SizedBox(height: 24),

            // Submit Button
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: customButton(
                label: 'Send Notification',
                onPressed: () async {
                  if (notificationImage != null) {
                    notificationImageUrl = await imageUpload(

                        notificationImage!.path);
                  }
                  createLevelNotification(
                      level: widget.level,
                      id: _selectedItemsId,
                      subject: titleController.text,
                      content: messageController.text,
                      media: notificationImageUrl);
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
