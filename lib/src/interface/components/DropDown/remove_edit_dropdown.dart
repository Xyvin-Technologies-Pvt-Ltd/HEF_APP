import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class RemoveEditDropdown extends StatelessWidget {
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const RemoveEditDropdown({
    super.key,
    required this.onRemove,
    required this.onEdit,
  });

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
            value: 'remove',
            child: Text(
              'Remove',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
          const DropdownMenuItem<String>(
            value: 'edit',
            child: Text(
              'Edit',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          if (value == 'remove') {
            onRemove();
          } else if (value == 'edit') {
            onEdit();
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
