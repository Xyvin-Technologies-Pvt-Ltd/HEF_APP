import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';

class MemberCreationTextfield extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLines;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final String? Function(String?)? validator; // Add validator

  const MemberCreationTextfield({
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    super.key,
    required this.textEditingController,
    this.textInputType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: TextFormField(
              keyboardType: textInputType,
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: kBodyTitleR.copyWith(color: kInputFieldcolor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: kGreyLight), // Default border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kGreyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kGreyLight),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kGreyLight),
                ),
              ),
              maxLines: maxLines,
              validator: validator, // Apply validator
            ),
          ),
        ],
      ),
    );
  }
}

