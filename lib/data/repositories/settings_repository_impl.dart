import 'package:uuid/uuid.dart';

import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/hive_service.dart';
import '../models/user_profile_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final HiveService hiveService;
  final _uuid = const Uuid();

  SettingsRepositoryImpl({required this.hiveService});

  @override
  Future<Either<Failure, UserProfile?>> getUserProfile() async {
    try {
      final model = hiveService.getCurrentUser();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserProfile(UserProfile profile) async {
    try {
      await hiveService.saveUserProfile(UserProfileModel.fromEntity(profile));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserSettings>> getSettings() async {
    try {
      final model = hiveService.getCurrentUser();
      if (model != null) {
        return Right(model.toEntity().settings);
      }
      return const Right(UserSettings());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(UserSettings settings) async {
    try {
      final model = hiveService.getCurrentUser();
      if (model != null) {
        final updatedProfile = model.toEntity().copyWith(settings: settings);
        await hiveService.saveUserProfile(UserProfileModel.fromEntity(updatedProfile));
      } else {
        // Create new profile with settings
        final newProfile = UserProfile(
          id: _uuid.v4(),
          name: 'User',
          createdAt: DateTime.now(),
          settings: settings,
        );
        await hiveService.saveUserProfile(UserProfileModel.fromEntity(newProfile));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getApiKey() async {
    try {
      final apiKey = hiveService.getApiKey();
      return Right(apiKey);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveApiKey(String apiKey) async {
    try {
      await hiveService.saveApiKey(apiKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TTSVoice>> getSelectedVoice() async {
    try {
      final settingsResult = await getSettings();
      return settingsResult.fold(
        (failure) => const Right(TTSVoice.fritz),
        (settings) {
          final voiceName = settings.selectedVoice.toLowerCase().replaceAll('-playai', '');
          return Right(
            TTSVoice.values.firstWhere(
              (v) => v.name.toLowerCase() == voiceName,
              orElse: () => TTSVoice.fritz,
            ),
          );
        },
      );
    } catch (e) {
      return const Right(TTSVoice.fritz);
    }
  }

  @override
  Future<Either<Failure, void>> setSelectedVoice(TTSVoice voice) async {
    try {
      final settingsResult = await getSettings();
      return settingsResult.fold(
        (failure) => Left(failure),
        (settings) async {
          final updatedSettings = settings.copyWith(selectedVoice: voice.apiName);
          return updateSettings(updatedSettings);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isDarkMode() async {
    try {
      final settingsResult = await getSettings();
      return settingsResult.fold(
        (failure) => const Right(false),
        (settings) => Right(settings.isDarkMode),
      );
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> setDarkMode(bool enabled) async {
    try {
      final settingsResult = await getSettings();
      return settingsResult.fold(
        (failure) => Left(failure),
        (settings) async {
          final updatedSettings = settings.copyWith(isDarkMode: enabled);
          return updateSettings(updatedSettings);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearSettings() async {
    try {
      // Reset to default settings
      final defaultProfile = UserProfile(
        id: _uuid.v4(),
        name: 'User',
        createdAt: DateTime.now(),
        settings: const UserSettings(),
      );
      await hiveService.saveUserProfile(UserProfileModel.fromEntity(defaultProfile));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
