import 'package:hive/hive.dart';
import '../../domain/entities/progress_record.dart';
import '../../domain/entities/enums.dart';

part 'progress_model.g.dart';

@HiveType(typeId: 9)
class ProgressRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int totalSessions;

  @HiveField(3)
  final int totalQuestions;

  @HiveField(4)
  final Map<int, double> categoryScores;

  @HiveField(5)
  final double overallAverage;

  @HiveField(6)
  final int currentStreak;

  @HiveField(7)
  final int longestStreak;

  @HiveField(8)
  final List<int> unlockedAchievements;

  @HiveField(9)
  final int skillLevelIndex;

  @HiveField(10)
  final Map<String, int> weeklyActivity;

  ProgressRecordModel({
    required this.id,
    required this.date,
    required this.totalSessions,
    required this.totalQuestions,
    required this.categoryScores,
    required this.overallAverage,
    required this.currentStreak,
    required this.longestStreak,
    required this.unlockedAchievements,
    required this.skillLevelIndex,
    required this.weeklyActivity,
  });

  factory ProgressRecordModel.fromEntity(ProgressRecord entity) {
    return ProgressRecordModel(
      id: entity.id,
      date: entity.date,
      totalSessions: entity.totalSessions,
      totalQuestions: entity.totalQuestions,
      categoryScores: entity.categoryScores.map(
        (key, value) => MapEntry(key.index, value),
      ),
      overallAverage: entity.overallAverage,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      unlockedAchievements: entity.unlockedAchievements
          .map((a) => a.index)
          .toList(),
      skillLevelIndex: entity.skillLevel.index,
      weeklyActivity: entity.weeklyActivity,
    );
  }

  ProgressRecord toEntity() {
    return ProgressRecord(
      id: id,
      date: date,
      totalSessions: totalSessions,
      totalQuestions: totalQuestions,
      categoryScores: categoryScores.map(
        (key, value) => MapEntry(QuestionCategory.values[key], value),
      ),
      overallAverage: overallAverage,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      unlockedAchievements: unlockedAchievements
          .map((i) => AchievementType.values[i])
          .toList(),
      skillLevel: SkillLevel.values[skillLevelIndex],
      weeklyActivity: weeklyActivity,
    );
  }
}
