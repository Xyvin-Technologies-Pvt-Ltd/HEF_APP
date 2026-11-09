import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hef/src/data/api_routes/level_role_upload_api/level_role_upload_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/level_role_upload_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MarUploadPage extends StatefulWidget {
  const MarUploadPage({super.key});

  @override
  State<MarUploadPage> createState() => _MarUploadPageState();
}

class _MarUploadPageState extends State<MarUploadPage> {
  final List<LevelRoleUpload> _uploads = [];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  File? _file;
  bool _loading = true;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await LevelRoleUploadApi.fetchMyUploads(limit: 50);
      if (!mounted) return;
      setState(() {
        _uploads
          ..clear()
          ..addAll(items);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _clean(error);
        _loading = false;
      });
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12),
      helpText: 'Report month',
    );
    if (picked == null || !mounted) return;
    setState(() => _month = DateTime(picked.year, picked.month));
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: LevelRoleUploadApi.allowedExtensions.toList(),
      allowMultiple: false,
    );
    final picked = result?.files.single;
    final path = picked?.path;
    log(
      'Picked file: name=${picked?.name}, path=$path, size=${picked?.size}, extension=${picked?.extension}',
      name: 'MAR Upload',
    );
    if (path == null || !mounted) return;
    final file = File(path);
    if (await file.length() > 15 * 1024 * 1024) {
      _message('File must be 15 MB or smaller');
      return;
    }
    setState(() => _file = file);
  }

  Future<void> _upload() async {
    final file = _file;
    if (file == null) {
      _message('Choose the MAR document first');
      return;
    }
    setState(() => _uploading = true);
    try {
      final month = DateFormat('MMMM yyyy').format(_month);
      final title = 'MAR - $month';
      log(
        'Starting MAR upload: title=$title, path=${file.path}, exists=${await file.exists()}, size=${await file.length()}',
        name: 'MAR Upload',
      );
      await LevelRoleUploadApi.uploadMar(
        file: file,
        title: title,
        description: 'Monthly Analysis Report for $month',
      );
      if (!mounted) return;
      setState(() => _file = null);
      _message('Monthly Analysis Report uploaded');
      await _load();
    } catch (error, stackTrace) {
      log('MAR upload failed: $error', name: 'MAR Upload', stackTrace: stackTrace);
      _message(_clean(error));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _delete(LevelRoleUpload item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete report'),
        content: Text('Delete ${item.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await LevelRoleUploadApi.deleteUpload(item.id);
      if (!mounted) return;
      setState(() => _uploads.removeWhere((upload) => upload.id == item.id));
      _message('Report deleted');
    } catch (error) {
      _message(_clean(error));
    }
  }

  Future<void> _open(LevelRoleUpload item) async {
    final uri = Uri.tryParse(item.fileUrl);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _message('Could not open this file');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: kPrimaryColor),
    );
  }

  String _fileName(String path) {
    final name = path.replaceAll('\\', '/').split('/').last;
    return name.isEmpty ? 'Document' : name;
  }

  String _clean(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_month);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        title: const Text('MAR', style: TextStyle(fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: kGrey),
        ),
      ),
      body: RefreshIndicator(
        color: kPrimaryColor,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Monthly Analysis Report',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload the MAR for your chapter, district, zone, or state. PDF, Word, Excel, and image files up to 15 MB are accepted.',
              style: TextStyle(color: kGreyDark, height: 1.4),
            ),
            const SizedBox(height: 20),
            _field(
              label: 'Report month',
              value: monthLabel,
              icon: Icons.calendar_month,
              onTap: _pickMonth,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Document',
              value: _file == null ? 'Choose a file' : _fileName(_file!.path),
              icon: Icons.upload_file,
              onTap: _pickFile,
            ),
            const SizedBox(height: 20),
            customButton(
              label: 'Upload MAR',
              isLoading: _uploading,
              onPressed: _uploading ? null : _upload,
            ),
            const SizedBox(height: 28),
            const Text(
              'Uploaded reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: LoadingAnimation()),
              )
            else if (_error != null)
              _empty(_error!, action: 'Retry', onTap: _load)
            else if (_uploads.isEmpty)
              _empty('No Monthly Analysis Reports uploaded yet')
            else
              ..._uploads.map(_uploadTile),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF7F7FC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: kGreyDark, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadTile(LevelRoleUpload item) {
    final date = item.createdAt == null
        ? ''
        : DateFormat('d MMM yyyy').format(item.createdAt!.toLocal());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEF1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => _open(item),
        leading: const Icon(Icons.description_outlined, color: kPrimaryColor),
        title: Text(item.title),
        subtitle: Text(
          [item.fileName, if (date.isNotEmpty) date].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: kRed),
          onPressed: () => _delete(item),
        ),
      ),
    );
  }

  Widget _empty(String text, {String? action, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: kGreyDark)),
          if (action != null && onTap != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onTap, child: Text(action)),
          ],
        ],
      ),
    );
  }
}
