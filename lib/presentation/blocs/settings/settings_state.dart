part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;
  final String? apiKey;

  const SettingsLoaded({
    required this.settings,
    this.apiKey,
  });

  @override
  List<Object?> get props => [settings, apiKey];

  SettingsLoaded copyWith({
    UserSettings? settings,
    String? apiKey,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CacheCleared extends SettingsState {}
