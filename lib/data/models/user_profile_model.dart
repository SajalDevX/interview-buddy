import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/enums.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 0)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? targetRole;

  @HiveField(4)
  final String? industry;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final UserSettingsModel settings;

  UserProfileModel({
    required this.id,
    required this.name,
    this.email,
    this.targetRole,
    this.industry,
    required this.createdAt,
    required this.settings,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      targetRole: entity.targetRole,
      industry: entity.industry,
      createdAt: entity.createdAt,
      settings: UserSettingsModel.fromEntity(entity.settings),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      targetRole: targetRole,
      industry: industry,
      createdAt: createdAt,
      settings: settings.toEntity(),
    );
  }
}

@HiveType(typeId: 1)
class UserSettingsModel extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String selectedVoice;

  @HiveField(2)
  final bool enableNotifications;

  @HiveField(3)
  final bool autoPlayAudio;

  @HiveField(4)
  final double playbackSpeed;

  @HiveField(5)
  final String aiProvider;

  UserSettingsModel({
    required this.isDarkMode,
    required this.selectedVoice,
    required this.enableNotifications,
    required this.autoPlayAudio,
    required this.playbackSpeed,
    this.aiProvider = 'gemini',
  });

  factory UserSettingsModel.fromEntity(UserSettings entity) {
    return UserSettingsModel(
      isDarkMode: entity.isDarkMode,
      selectedVoice: entity.selectedVoice,
      enableNotifications: entity.enableNotifications,
      autoPlayAudio: entity.autoPlayAudio,
      playbackSpeed: entity.playbackSpeed,
      aiProvider: entity.aiProvider.name,
    );
  }

  UserSettings toEntity() {
    return UserSettings(
      isDarkMode: isDarkMode,
      selectedVoice: selectedVoice,
      enableNotifications: enableNotifications,
      autoPlayAudio: autoPlayAudio,
      playbackSpeed: playbackSpeed,
      aiProvider: AIProvider.values.firstWhere(
        (e) => e.name == aiProvider,
        orElse: () => AIProvider.gemini,
      ),
    );
  }
}
