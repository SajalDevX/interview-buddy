import 'package:equatable/equatable.dart';
import 'enums.dart';

class ProgressRecord extends Equatable {
  final String id;
  final DateTime date;
  final int totalSessions;
  final int totalQuestions;
  final Map<QuestionCategory, double> categoryScores;
  final double overallAverage;
  final int currentStreak;
  final int longestStreak;
  final List<AchievementType> unlockedAchievements;
  final SkillLevel skillLevel;
  final Map<String, int> weeklyActivity;

  const ProgressRecord({
    required this.id,
    required this.date,
    this.totalSessions = 0,
    this.totalQuestions = 0,
    this.categoryScores = const {},
    this.overallAverage = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.unlockedAchievements = const [],
    this.skillLevel = SkillLevel.beginner,
    this.weeklyActivity = const {},
  });

  bool hasAchievement(AchievementType type) => unlockedAchievements.contains(type);

  double getCategoryScore(QuestionCategory category) => categoryScores[category] ?? 0;

  ProgressRecord copyWith({
    DateTime? date,
    int? totalSessions,
    int? totalQuestions,
    Map<QuestionCategory, double>? categoryScores,
    double? overallAverage,
    int? currentStreak,
    int? longestStreak,
    List<AchievementType>? unlockedAchievements,
    SkillLevel? skillLevel,
    Map<String, int>? weeklyActivity,
  }) {
    return ProgressRecord(
      id: id,
      date: date ?? this.date,
      totalSessions: totalSessions ?? this.totalSessions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      categoryScores: categoryScores ?? this.categoryScores,
      overallAverage: overallAverage ?? this.overallAverage,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      skillLevel: skillLevel ?? this.skillLevel,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        totalSessions,
        totalQuestions,
        categoryScores,
        overallAverage,
        currentStreak,
        longestStreak,
        unlockedAchievements,
        skillLevel,
        weeklyActivity,
      ];
}

class DailyProgress extends Equatable {
  final DateTime date;
  final int sessionsCompleted;
  final int questionsAnswered;
  final double averageScore;
  final Duration totalPracticeTime;

  const DailyProgress({
    required this.date,
    this.sessionsCompleted = 0,
    this.questionsAnswered = 0,
    this.averageScore = 0,
    this.totalPracticeTime = Duration.zero,
  });

  @override
  List<Object?> get props => [
        date,
        sessionsCompleted,
        questionsAnswered,
        averageScore,
        totalPracticeTime,
      ];
}
