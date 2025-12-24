import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? targetRole;
  final String? industry;
  final DateTime createdAt;
  final UserSettings settings;

  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.targetRole,
    this.industry,
    required this.createdAt,
    required this.settings,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? targetRole,
    String? industry,
    UserSettings? settings,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      targetRole: targetRole ?? this.targetRole,
      industry: industry ?? this.industry,
      createdAt: createdAt,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [id, name, email, targetRole, industry, createdAt, settings];
}

class UserSettings extends Equatable {
  final bool isDarkMode;
  final String selectedVoice;
  final bool enableNotifications;
  final bool autoPlayAudio;
  final double playbackSpeed;

  const UserSettings({
    this.isDarkMode = false,
    this.selectedVoice = 'Fritz-PlayAI',
    this.enableNotifications = true,
    this.autoPlayAudio = true,
    this.playbackSpeed = 1.0,
  });

  UserSettings copyWith({
    bool? isDarkMode,
    String? selectedVoice,
    bool? enableNotifications,
    bool? autoPlayAudio,
    double? playbackSpeed,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, selectedVoice, enableNotifications, autoPlayAudio, playbackSpeed];
}
