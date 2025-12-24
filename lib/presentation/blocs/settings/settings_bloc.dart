import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateTTSVoiceEvent>(_onUpdateTTSVoice);
    on<UpdateSpeechSpeedEvent>(_onUpdateSpeechSpeed);
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
    on<UpdateApiKeyEvent>(_onUpdateApiKey);
    on<UpdateGeminiApiKeyEvent>(_onUpdateGeminiApiKey);
    on<UpdateAIProviderEvent>(_onUpdateAIProvider);
    on<ClearCacheEvent>(_onClearCache);
    on<ResetSettingsEvent>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final settingsResult = await settingsRepository.getSettings();
    final apiKeyResult = await settingsRepository.getApiKey();
    final geminiKeyResult = await settingsRepository.getGeminiApiKey();

    settingsResult.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) {
        String? apiKey;
        String? geminiApiKey;
        apiKeyResult.fold(
          (_) => apiKey = null,
          (key) => apiKey = key,
        );
        geminiKeyResult.fold(
          (_) => geminiApiKey = null,
          (key) => geminiApiKey = key,
        );
        emit(SettingsLoaded(
          settings: settings,
          apiKey: apiKey,
          geminiApiKey: geminiApiKey,
        ));
      },
    );
  }

  Future<void> _onUpdateTTSVoice(
    UpdateTTSVoiceEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        selectedVoice: event.voice.name,
      );

      final result = await settingsRepository.updateSettings(updatedSettings);

      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(currentState.copyWith(settings: updatedSettings)),
      );
    }
  }

  Future<void> _onUpdateSpeechSpeed(
    UpdateSpeechSpeedEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        playbackSpeed: event.speed,
      );

      final result = await settingsRepository.updateSettings(updatedSettings);

      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(currentState.copyWith(settings: updatedSettings)),
      );
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        isDarkMode: event.isDarkMode,
      );

      final result = await settingsRepository.updateSettings(updatedSettings);

      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(currentState.copyWith(settings: updatedSettings)),
      );
    }
  }

  Future<void> _onUpdateApiKey(
    UpdateApiKeyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      final result = await settingsRepository.saveApiKey(event.apiKey);

      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(currentState.copyWith(apiKey: event.apiKey)),
      );
    }
  }

  Future<void> _onUpdateGeminiApiKey(
    UpdateGeminiApiKeyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      final result = await settingsRepository.saveGeminiApiKey(event.apiKey);

      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(currentState.copyWith(geminiApiKey: event.apiKey)),
      );
    }
  }

  Future<void> _onUpdateAIProvider(
    UpdateAIProviderEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        aiProvider: event.provider,
      );

      final result = await settingsRepository.updateSettings(updatedSettings);

      result.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(currentState.copyWith(settings: updatedSettings)),
      );
    }
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await settingsRepository.clearSettings();

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        emit(CacheCleared());
        add(LoadSettingsEvent());
      },
    );
  }

  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    const defaultSettings = UserSettings();
    final result = await settingsRepository.updateSettings(defaultSettings);

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => emit(SettingsLoaded(settings: defaultSettings)),
    );
  }
}
