import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DropDownMenu extends StatelessWidget {
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const DropDownMenu({super.key, required this.onRemove, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: const Icon(
          Icons.more_vert,
          color: Colors.black,
          size: 22,
        ),
        items: [
          const DropdownMenuItem<String>(
            value: 'edit',
            child: Text(
              'Edit',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          const DropdownMenuItem<String>(
            value: 'remove',
            child: Text(
              'Remove',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          if (value == 'edit') {
            onEdit();
          } else if (value == 'remove') {
            onRemove();
          }
        },
        dropdownStyleData: DropdownStyleData(
          width: 160,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}