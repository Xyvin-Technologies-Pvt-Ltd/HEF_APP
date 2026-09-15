import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/interface/components/Dialogs/report_dialog.dart';

enum MessageAction { copy, delete, report }

Future<MessageAction?> showMessageActionsSheet({
  required BuildContext context,
  required bool isOwnMessage,
  required bool canCopy,
  required bool canDelete,
  required bool canReport,
}) {
  return showModalBottomSheet<MessageAction>(
    context: context,
    backgroundColor: kWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              if (canCopy)
                ListTile(
                  leading: const Icon(Icons.copy, color: kPrimaryColor),
                  title: const Text('Copy'),
                  onTap: () => Navigator.pop(context, MessageAction.copy),
                ),
              if (isOwnMessage && canDelete)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: kRed),
                  title: const Text('Delete'),
                  onTap: () => Navigator.pop(context, MessageAction.delete),
                ),
              if (!isOwnMessage && canReport)
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: kPrimaryColor),
                  title: const Text('Report'),
                  onTap: () => Navigator.pop(context, MessageAction.report),
                ),
              ListTile(
                leading: const Icon(Icons.close, color: kGreyDarker),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> showDeleteMessageConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.question_mark_rounded, size: 70),
            const SizedBox(height: 20),
            const Text(
              'Delete this message?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'Are you sure?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF0E1877)),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEB5757),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result == true;
}

Future<void> copyMessageText(String text) async {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    try {
      SnackbarService().showSnackBar('Nothing to copy');
    } catch (_) {}
    return;
  }
  await Clipboard.setData(ClipboardData(text: trimmed));
  try {
    SnackbarService().showSnackBar('Message copied');
  } catch (_) {}
}

Future<void> handleMessageAction({
  required BuildContext context,
  required MessageAction? action,
  required String? messageId,
  required String? content,
  required Future<void> Function()? onDeleteConfirmed,
}) async {
  if (action == null) return;

  switch (action) {
    case MessageAction.copy:
      await copyMessageText(content ?? '');
      break;
    case MessageAction.delete:
      if (!context.mounted) return;
      final confirmed = await showDeleteMessageConfirmDialog(context);
      if (!context.mounted) return;
      if (confirmed && onDeleteConfirmed != null) {
        await onDeleteConfirmed();
      }
      break;
    case MessageAction.report:
      if (!context.mounted) return;
      showReportPersonDialog(
        reportedItemId: messageId ?? '',
        context: context,
        onReportStatusChanged: () {},
        reportType: 'Message',
      );
      break;
  }
}
