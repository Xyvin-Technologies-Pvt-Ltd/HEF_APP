import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';

class SelectionDropDown extends StatefulWidget {
  final String? hintText;
  final String? label;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const SelectionDropDown({
    this.label,
    required this.items,
    this.value,
    required this.onChanged,
    Key? key,
    this.hintText,
    this.validator,
  }) : super(key: key);

  @override
  _SelectionDropDownState createState() => _SelectionDropDownState();
}

class _SelectionDropDownState extends State<SelectionDropDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.label ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              DropdownButtonFormField<String>(
                hint: Text(
                  widget.hintText ?? '',
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 14,
                  ),
                ),
                value: widget.value,
                items: widget.items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.value,
                    child: Text(
                      item.child.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _isOpen = false);
                  widget.onChanged(value);
                },
                validator: widget.validator,
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isOpen ? 0.5 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF718096),
                  ),
                ),
                onTap: () {
                  setState(() => _isOpen = !_isOpen);
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kGreyLight, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kGreyLight, width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                dropdownColor: Colors.white,
                elevation: 3,
                isExpanded: true,
                menuMaxHeight: 300,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                ),
                iconSize: 20,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
