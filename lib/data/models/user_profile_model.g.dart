// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 0;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String?,
      targetRole: fields[3] as String?,
      industry: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      settings: fields[6] as UserSettingsModel,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.targetRole)
      ..writeByte(4)
      ..write(obj.industry)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserSettingsModelAdapter extends TypeAdapter<UserSettingsModel> {
  @override
  final int typeId = 1;

  @override
  UserSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingsModel(
      isDarkMode: fields[0] as bool,
      selectedVoice: fields[1] as String,
      enableNotifications: fields[2] as bool,
      autoPlayAudio: fields[3] as bool,
      playbackSpeed: fields[4] as double,
      aiProvider: (fields[5] as String?) ?? 'gemini',
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.selectedVoice)
      ..writeByte(2)
      ..write(obj.enableNotifications)
      ..writeByte(3)
      ..write(obj.autoPlayAudio)
      ..writeByte(4)
      ..write(obj.playbackSpeed)
      ..writeByte(5)
      ..write(obj.aiProvider);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
