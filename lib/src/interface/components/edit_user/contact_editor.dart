import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';

class ContactEditor extends StatefulWidget {
  final String value;
  final String label;
  final IconData icon;
  final void Function(String value) onSave;

  const ContactEditor({
    Key? key,
    required this.value,
    required this.icon,
    required this.onSave,
    required this.label,
  }) : super(key: key);

  @override
  _ContactEditorState createState() => _ContactEditorState();
}

class _ContactEditorState extends State<ContactEditor> {
  String? currentValue;
  NavigationService navigationService = NavigationService();
  @override
  void initState() {
    super.initState();
    // Fetch the existing value for the platform, if it exists
    final existing = widget.value != null;
    if (existing) currentValue = widget.value;
  }

  void _showEditModal() {
    TextEditingController textController =
        TextEditingController(text: currentValue);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Enable proper resizing when keyboard appears
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                          color: kGreyDarker,
                          borderRadius: BorderRadius.circular(16)),
                      width: 70, // Width of the line
                      height: 4, // Thickness of the line
                      // Line color
                    ),
                  ),
                ),
                CustomTextFormField(
                  labelText: 'Enter ${widget.label}',
                  textController: textController,
                ),
                const SizedBox(height: 16),
                customButton(
                  label: 'Save',
                  onPressed: () {
                    widget.onSave(textController.text.trim());
                    setState(() {
                      currentValue = textController.text.trim().isNotEmpty
                          ? textController.text.trim()
                          : null;
                    });
                    navigationService.pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValuePresent = currentValue != null && currentValue!.isNotEmpty;

    return GestureDetector(
      onTap: _showEditModal,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            shape: BoxShape.rectangle,
            color: isValuePresent ? kPrimaryColor : kWhite),
        padding: const EdgeInsets.all(16),
        child: Icon(
          widget.icon,
          color: isValuePresent ? kWhite : kPrimaryColor,
        ),
      ),
    );
  }
}
