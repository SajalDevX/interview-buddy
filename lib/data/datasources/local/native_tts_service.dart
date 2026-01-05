import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class NativeTtsService {
  static const MethodChannel _channel = MethodChannel('interview_buddy/tts');
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final result = await _channel.invokeMethod('initialize');
      _isInitialized = result == true;
      developer.log('NativeTtsService initialized: $_isInitialized', name: 'NativeTtsService');
    } catch (e) {
      developer.log('Failed to initialize TTS: $e', name: 'NativeTtsService');
      _isInitialized = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      developer.log('Speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...', name: 'NativeTtsService');
      await _channel.invokeMethod('speak', {'text': text});
    } catch (e) {
      developer.log('TTS speak error: $e', name: 'NativeTtsService');
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (e) {
      developer.log('TTS stop error: $e', name: 'NativeTtsService');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _channel.invokeMethod('setSpeechRate', {'rate': rate});
    } catch (e) {
      developer.log('TTS setSpeechRate error: $e', name: 'NativeTtsService');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _channel.invokeMethod('setPitch', {'pitch': pitch});
    } catch (e) {
      developer.log('TTS setPitch error: $e', name: 'NativeTtsService');
    }
  }

  void dispose() {
    try {
      _channel.invokeMethod('shutdown');
    } catch (e) {
      developer.log('TTS dispose error: $e', name: 'NativeTtsService');
    }
  }
}
