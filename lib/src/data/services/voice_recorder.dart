import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(Duration duration);
typedef StopCallback = void Function(File file);

class VoiceRecorder {
  FlutterSoundRecorder? _recorder;
  String? _filePath;
  ProgressCallback? onProgress;
  StopCallback? onStop;

  VoiceRecorder({this.onProgress, this.onStop}) {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> init() async {
    // Request mic permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception("Microphone permission not granted");
    }

    await _recorder!.openRecorder();

    // Subscribe to progress updates
    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    _recorder!.onProgress?.listen((event) {
      if (onProgress != null) {
        onProgress!(event.duration);
      }
    });
  }

  Future<void> startRecording() async {
  if (_recorder == null) {
    throw Exception("Recorder instance is null. Did you call init()?");
  }

  if (!_recorder!.isStopped) {
    throw Exception("Recorder is busy. Stop before starting a new recording.");
  }

  final dir = await getTemporaryDirectory();
  _filePath =
      '${dir.path}/recorded_${DateTime.now().millisecondsSinceEpoch}.aac';

  await _recorder!.startRecorder(
    toFile: _filePath,
    codec: Codec.aacADTS,
  );
}

  Future<File> stopRecording() async {
    final path = await _recorder!.stopRecorder();
    final file = File(path!);
    if (onStop != null) onStop!(file);
    return file;
  }

  Future<void> cancel() async {
    await _recorder!.stopRecorder();
    if (_filePath != null) {
      File(_filePath!).delete(); // delete canceled file
    }
  }

  Future<void> dispose() async {
    await _recorder!.closeRecorder();
  }
}
