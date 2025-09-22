import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/data/services/document_service.dart';
import 'package:hef/src/interface/components/common/voice_message_player.dart';

class AttachmentViewer extends StatelessWidget {
  final Attachment attachment;
  final String heroTag;

  const AttachmentViewer({
    Key? key,
    required this.attachment,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (attachment.type == 'file')
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _downloadFile(context),
            ),
          if (attachment.type == 'file')
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              onPressed: () => _openFile(context),
            ),
        ],
      ),
      body: Center(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (attachment.type) {
      case 'image':
        return _buildImageViewer(context);
      case 'voice':
        return _buildVoiceViewer(context);
      case 'file':
      default:
        return _buildFileViewer(context);
    }
  }

  Widget _buildImageViewer(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          attachment.url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFileViewer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_drive_file,
            size: 120,
            color: Colors.white70,
          ),
          const SizedBox(height: 24),
          Text(
            _getFileName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _downloadFile(context),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _openFile(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    final uri = Uri.parse(attachment.url);
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      return segments.last;
    }
    return 'Document';
  }

  Widget _buildVoiceViewer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.audiotrack,
            size: 120,
            color: Colors.white70,
          ),
          const SizedBox(height: 24),
          const Text(
            'Voice Message',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: VoiceMessagePlayer(
              audioUrl: attachment.url,
              backgroundColor: Colors.transparent,
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    await DocumentService.downloadAndOpenDocument(
      url: attachment.url,
      context: context,
    );
  }

  Future<void> _openFile(BuildContext context) async {
    await DocumentService.downloadAndOpenDocument(
      url: attachment.url,
      context: context,
    );
  }
}