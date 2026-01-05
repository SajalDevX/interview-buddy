import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _currentRecordingPath;

  bool get isRecording => _recorder.isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        developer.log('Microphone permission denied', name: 'AudioRecorderService');
        throw Exception('Microphone permission is required for recording');
      }

      await _recorder.openRecorder();
      _isInitialized = true;
      developer.log('AudioRecorderService initialized', name: 'AudioRecorderService');
    } catch (e) {
      developer.log('Failed to initialize AudioRecorderService: $e', name: 'AudioRecorderService');
      rethrow;
    }
  }

  Future<String> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Generate unique file path
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${dir.path}/recording_$timestamp.wav';

      developer.log('Starting recording: $_currentRecordingPath', name: 'AudioRecorderService');

      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );

      return _currentRecordingPath!;
    } catch (e) {
      developer.log('Failed to start recording: $e', name: 'AudioRecorderService');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      developer.log('Stopping recording', name: 'AudioRecorderService');
      await _recorder.stopRecorder();

      final path = _currentRecordingPath;

      // Verify file exists
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          developer.log('Recording saved: $path (${size} bytes)', name: 'AudioRecorderService');
          return path;
        } else {
          developer.log('Recording file not found: $path', name: 'AudioRecorderService');
        }
      }

      return null;
    } catch (e) {
      developer.log('Failed to stop recording: $e', name: 'AudioRecorderService');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
      }

      // Delete the file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentRecordingPath = null;
    } catch (e) {
      developer.log('Failed to cancel recording: $e', name: 'AudioRecorderService');
    }
  }

  void dispose() {
    _recorder.closeRecorder();
    _isInitialized = false;
  }
}
