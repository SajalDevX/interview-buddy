part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdateTTSVoiceEvent extends SettingsEvent {
  final TTSVoice voice;

  const UpdateTTSVoiceEvent(this.voice);

  @override
  List<Object?> get props => [voice];
}

class UpdateSpeechSpeedEvent extends SettingsEvent {
  final double speed;

  const UpdateSpeechSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

class ToggleDarkModeEvent extends SettingsEvent {
  final bool isDarkMode;

  const ToggleDarkModeEvent(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class UpdateApiKeyEvent extends SettingsEvent {
  final String apiKey;

  const UpdateApiKeyEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class ClearCacheEvent extends SettingsEvent {}

class ResetSettingsEvent extends SettingsEvent {}
