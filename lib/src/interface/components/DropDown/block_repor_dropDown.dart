import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/data/notifiers/business_notifier.dart';
import 'package:hef/src/interface/components/Dialogs/blockPersonDialog.dart';
import 'package:hef/src/interface/components/Dialogs/report_dialog.dart';

class BlockReportDropdown extends ConsumerWidget {
  final Business? feed;
  final Product? product;
  final MessageModel? msg;
  final String? userId;
  final VoidCallback? onBlockStatusChanged;
  final bool? isBlocked;
  final bool compact;

  const BlockReportDropdown({
    this.onBlockStatusChanged,
    this.userId,
    this.msg,
    super.key,
    this.feed,
    this.isBlocked,
    this.product,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Icon(
          Icons.more_vert,
          size: compact ? 16 : 24,
          color: compact ? const Color(0xFF3C4250) : null,
        ),
        items: [
          const DropdownMenuItem(
            value: 'report',
            child: const Text(
              'Report',
              style: TextStyle(color: Colors.red),
            ),
          ),
          DropdownMenuItem(
            value: 'block',
            child: isBlocked != null && isBlocked == false
                ? Text(
                    'Block',
                    style: TextStyle(color: Colors.red),
                  )
                : Text(
                    'Unblock',
                    style: TextStyle(color: Colors.red),
                  ),
          ),
        ],
        onChanged: (value) async {
          if (value == 'report') {
            String reportType = '';
            if (feed != null) {
              reportType = 'Feeds';
              showReportPersonDialog(
                  reportedItemId: feed?.id ?? '',
                  context: context,
                  onReportStatusChanged: () {},
                  reportType: reportType);
            } else if (userId != null) {
              log(userId.toString());
              reportType = 'User';
              showReportPersonDialog(
                  reportedItemId: userId ?? '',
                  context: context,
                  userId: userId ?? '',
                  onReportStatusChanged: () {},
                  reportType: reportType);
            } else if (product != null) {
              log(product.toString());
              reportType = 'Product';
              showReportPersonDialog(
                  reportedItemId: product?.id ?? '',
                  context: context,
                  userId: userId ?? '',
                  onReportStatusChanged: () {},
                  reportType: reportType);
            } else {
              reportType = 'Message';
              showReportPersonDialog(
                  reportedItemId: msg?.id ?? '',
                  context: context,
                  onReportStatusChanged: () {},
                  reportType: reportType);
            }
          } else if (value == 'block') {
            if (feed != null) {
              showBlockPersonDialog(
                  context: context,
                  userId: feed?.author ?? '',
                  onBlockStatusChanged: () {
                    ref.invalidate(businessNotifierProvider);
                  });
            } else if (userId != null) {
              showBlockPersonDialog(
                  context: context,
                  userId: userId ?? '',
                  onBlockStatusChanged: () {
                    onBlockStatusChanged;
                  });
            }
          }
        },
        buttonStyleData: ButtonStyleData(
          height: compact ? 28 : null,
          width: compact ? 28 : null,
          padding: compact ? EdgeInsets.zero : null,
          decoration: BoxDecoration(
            color: compact ? Colors.white : null,
            borderRadius: BorderRadius.circular(compact ? 14 : 10),
            boxShadow: compact
                ? const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          width: 180,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          offset: const Offset(0, 0),
        ),
      ),
    );
  }
}
