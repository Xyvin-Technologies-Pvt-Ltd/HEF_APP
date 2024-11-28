
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class AddbusinessTypeDropDown extends StatefulWidget {
  final ValueChanged<String?> onValueChanged;
  final FormFieldValidator<String?>?
      validator; // Added validator as a parameter

  const AddbusinessTypeDropDown({
    Key? key,
    required this.onValueChanged,
    required this.validator, // Added validator here
  }) : super(key: key);

  @override
  _AddbusinessTypeDropDownState createState() => _AddbusinessTypeDropDownState();
}

class _AddbusinessTypeDropDownState extends State<AddbusinessTypeDropDown> {
  String? _selectedValue;

  final List<String> _dropdownValues = [
    "Information",
    "Job",
    "Funding",
    "Requirement",
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      value: _selectedValue,
      hint:
          const Text('Select type'), // Show the label when no value is selected
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Circular border
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 212, 209, 209),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Circular border
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 223, 220, 220),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Circular border
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Circular border
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),

      onChanged: (String? newValue) {
        setState(() {
          _selectedValue = newValue;
        });

        // Notify parent about the value change
        widget.onValueChanged(newValue);
      },
      validator: widget.validator, // Apply the validator here
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Circular dropdown menu
          color: Colors.white, // Dropdown menu background color
        ),
        elevation: 8,
      ),
      menuItemStyleData: MenuItemStyleData(
        customHeights: List<double>.filled(_dropdownValues.length, 48.0),
        padding: const EdgeInsets.only(right: 10),
      ),
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.only(right: 10),
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Circular dropdown button
          color: Colors.white,
        ),
      ),
      items: _dropdownValues
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12), // Circular menu item border
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(value),
              ),
            ),
          )
          .toList(),
    );
  }
}