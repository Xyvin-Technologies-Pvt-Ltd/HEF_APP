import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:intl/intl.dart';

class DateFilterSheet extends StatefulWidget {
  final Function(String?, String?) onApply;

  const DateFilterSheet({
    Key? key,
    required this.onApply,
  }) : super(key: key);

  @override
  State<DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<DateFilterSheet> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // iOS-style handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter by Date',
            style: kSubHeadingB.copyWith(color: kTextHeadColor),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildDateSelector(
                  label: 'Start Date',
                  value: startDate,
                  onSelect: (date) {
                    setState(() {
                      startDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  label: 'End Date',
                  value: endDate,
                  onSelect: (date) {
                    setState(() {
                      endDate = date;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: customButton(
              label: 'APPLY',
              onPressed: () {
                String? formattedStartDate = startDate != null
                    ? DateFormat('yyyy-MM-dd').format(startDate!)
                    : null;
                String? formattedEndDate = endDate != null
                    ? DateFormat('yyyy-MM-dd').format(endDate!)
                    : null;
                widget.onApply(formattedStartDate, formattedEndDate);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: kBodyTitleR.copyWith(color: kTextHeadColor),
            ),
            Text(
              value != null
                  ? DateFormat('dd MMM yyyy').format(value)
                  : 'Select Date',
              style: kBodyTitleR.copyWith(
                color: value != null ? kTextHeadColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
