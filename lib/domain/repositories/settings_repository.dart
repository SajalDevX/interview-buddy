import '../entities/user_profile.dart';
import '../entities/enums.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

abstract class SettingsRepository {
  /// Get user profile
  Future<Either<Failure, UserProfile?>> getUserProfile();

  /// Save user profile
  Future<Either<Failure, void>> saveUserProfile(UserProfile profile);

  /// Get user settings
  Future<Either<Failure, UserSettings>> getSettings();

  /// Update settings
  Future<Either<Failure, void>> updateSettings(UserSettings settings);

  /// Get API key
  Future<Either<Failure, String?>> getApiKey();

  /// Save API key
  Future<Either<Failure, void>> saveApiKey(String apiKey);

  /// Get selected TTS voice
  Future<Either<Failure, TTSVoice>> getSelectedVoice();

  /// Set selected TTS voice
  Future<Either<Failure, void>> setSelectedVoice(TTSVoice voice);

  /// Get dark mode setting
  Future<Either<Failure, bool>> isDarkMode();

  /// Set dark mode
  Future<Either<Failure, void>> setDarkMode(bool enabled);

  /// Clear all settings
  Future<Either<Failure, void>> clearSettings();
}
