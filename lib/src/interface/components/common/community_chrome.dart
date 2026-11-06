import 'package:flutter/material.dart';

const Color kCommunityOrange = Color(0xFFFF6D00);
const Color kCommunityOrangeSoft = Color(0xFFFFF3E8);
const Color kCommunityBorder = Color(0xFFE6E8EC);
const Color kCommunityMuted = Color(0xFF9AA1AB);
const Color kCommunityHint = Color(0xFFB7BDC6);
const Color kCommunityText = Color(0xFF1C1F26);
const Color kCommunitySub = Color(0xFF8B939E);
const Color kCommunityNavy = Color(0xFF18016A);

class CommunitySearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const CommunitySearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 14, color: kCommunityText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kCommunityHint, fontSize: 13.5),
          prefixIcon:
              const Icon(Icons.search, color: kCommunityHint, size: 22),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: _border(kCommunityBorder),
          enabledBorder: _border(kCommunityBorder),
          focusedBorder: _border(kCommunityOrange),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }
}

class CommunityFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool active;

  const CommunityFilterButton({
    super.key,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: kCommunityOrange, width: 1.4),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onPressed,
              child: const Center(
                child: Icon(Icons.tune, color: kCommunityOrange, size: 22),
              ),
            ),
          ),
          if (active)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: kCommunityOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CommunitySearchRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onFilter;
  final bool filterActive;

  const CommunitySearchRow({
    super.key,
    required this.controller,
    required this.hint,
    required this.onFilter,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: CommunitySearchField(
              controller: controller,
              focusNode: focusNode,
              hint: hint,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          const SizedBox(width: 10),
          CommunityFilterButton(onPressed: onFilter, active: filterActive),
        ],
      ),
    );
  }
}
