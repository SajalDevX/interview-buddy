// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressRecordModelAdapter extends TypeAdapter<ProgressRecordModel> {
  @override
  final int typeId = 9;

  @override
  ProgressRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressRecordModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      totalSessions: fields[2] as int,
      totalQuestions: fields[3] as int,
      categoryScores: (fields[4] as Map).cast<int, double>(),
      overallAverage: fields[5] as double,
      currentStreak: fields[6] as int,
      longestStreak: fields[7] as int,
      unlockedAchievements: (fields[8] as List).cast<int>(),
      skillLevelIndex: fields[9] as int,
      weeklyActivity: (fields[10] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgressRecordModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalSessions)
      ..writeByte(3)
      ..write(obj.totalQuestions)
      ..writeByte(4)
      ..write(obj.categoryScores)
      ..writeByte(5)
      ..write(obj.overallAverage)
      ..writeByte(6)
      ..write(obj.currentStreak)
      ..writeByte(7)
      ..write(obj.longestStreak)
      ..writeByte(8)
      ..write(obj.unlockedAchievements)
      ..writeByte(9)
      ..write(obj.skillLevelIndex)
      ..writeByte(10)
      ..write(obj.weeklyActivity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
