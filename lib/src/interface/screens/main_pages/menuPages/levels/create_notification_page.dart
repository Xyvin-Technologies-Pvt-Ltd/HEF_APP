import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/level_models/level_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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

  AsyncValue<List<LevelModel>>? asyncLevelValues;
  @override
  Widget build(BuildContext context) {
    switch (widget.level) {
      case 'state':
        asyncLevelValues = ref.watch(fetchStatesProvider);
        break;
      default:
        asyncLevelValues = ref
            .watch(fetchLevelDataProvider(widget.levelId ?? '', widget.level));
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
                            "Select ${widget.level}",
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
              onTap: () {},
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
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
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
                onPressed: () {
                  createLevelNotification(
                      level: widget.level,
                      id: _selectedItemsId,
                      subject: titleController.text,
                      content: messageController.text);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
