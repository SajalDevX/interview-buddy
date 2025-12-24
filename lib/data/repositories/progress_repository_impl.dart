import 'package:uuid/uuid.dart';

import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/progress_record.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/local/hive_service.dart';
import '../models/progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final HiveService hiveService;
  final _uuid = const Uuid();

  ProgressRepositoryImpl({required this.hiveService});

  @override
  Future<Either<Failure, ProgressRecord>> getCurrentProgress() async {
    try {
      final model = hiveService.getLatestProgress();
      if (model != null) {
        return Right(model.toEntity());
      }

      // Create initial progress record
      final initialProgress = ProgressRecord(
        id: _uuid.v4(),
        date: DateTime.now(),
      );
      await hiveService.saveProgress(ProgressRecordModel.fromEntity(initialProgress));
      return Right(initialProgress);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgressRecord>> updateProgress({
    required int questionsAnswered,
    required Map<QuestionCategory, double> categoryScores,
    required double sessionScore,
  }) async {
    try {
      final currentResult = await getCurrentProgress();

      return currentResult.fold(
        (failure) => Left(failure),
        (current) async {
          // Update category scores with weighted average
          final newCategoryScores = Map<QuestionCategory, double>.from(current.categoryScores);
          for (final entry in categoryScores.entries) {
            final existingScore = newCategoryScores[entry.key] ?? 0;
            final existingCount = current.totalQuestions > 0 ? 1 : 0;
            newCategoryScores[entry.key] = existingCount > 0
                ? (existingScore + entry.value) / 2
                : entry.value;
          }

          // Calculate new overall average
          final newOverallAverage = current.totalQuestions > 0
              ? ((current.overallAverage * current.totalQuestions) + (sessionScore * questionsAnswered)) /
                  (current.totalQuestions + questionsAnswered)
              : sessionScore;

          // Update skill level based on new average
          final newSkillLevel = SkillLevel.fromScore(newOverallAverage);

          final updatedProgress = current.copyWith(
            date: DateTime.now(),
            totalSessions: current.totalSessions + 1,
            totalQuestions: current.totalQuestions + questionsAnswered,
            categoryScores: newCategoryScores,
            overallAverage: newOverallAverage,
            skillLevel: newSkillLevel,
          );

          await hiveService.saveProgress(ProgressRecordModel.fromEntity(updatedProgress));
          return Right(updatedProgress);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AchievementType>>> checkAchievements() async {
    try {
      final currentResult = await getCurrentProgress();

      return currentResult.fold(
        (failure) => Left(failure),
        (current) async {
          final newAchievements = <AchievementType>[];

          // Check each achievement
          if (!current.hasAchievement(AchievementType.firstSteps) &&
              current.totalSessions >= 1) {
            newAchievements.add(AchievementType.firstSteps);
          }

          if (!current.hasAchievement(AchievementType.streakMaster) &&
              current.currentStreak >= 7) {
            newAchievements.add(AchievementType.streakMaster);
          }

          if (!current.hasAchievement(AchievementType.marathonRunner) &&
              current.totalQuestions >= 100) {
            newAchievements.add(AchievementType.marathonRunner);
          }

          if (!current.hasAchievement(AchievementType.wellRounded) &&
              current.categoryScores.length >= QuestionCategory.values.length) {
            newAchievements.add(AchievementType.wellRounded);
          }

          if (newAchievements.isNotEmpty) {
            final updatedProgress = current.copyWith(
              unlockedAchievements: [
                ...current.unlockedAchievements,
                ...newAchievements,
              ],
            );
            await hiveService.saveProgress(ProgressRecordModel.fromEntity(updatedProgress));
          }

          return Right(newAchievements);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateStreak() async {
    try {
      final currentResult = await getCurrentProgress();

      return currentResult.fold(
        (failure) => Left(failure),
        (current) async {
          final today = DateTime.now();
          final lastActivity = current.date;

          int newStreak = current.currentStreak;
          int newLongestStreak = current.longestStreak;

          final daysDifference = today.difference(lastActivity).inDays;

          if (daysDifference == 0) {
            // Already practiced today, no change
          } else if (daysDifference == 1) {
            // Consecutive day, increment streak
            newStreak = current.currentStreak + 1;
            if (newStreak > newLongestStreak) {
              newLongestStreak = newStreak;
            }
          } else {
            // Streak broken
            newStreak = 1;
          }

          final updatedProgress = current.copyWith(
            date: today,
            currentStreak: newStreak,
            longestStreak: newLongestStreak,
          );

          await hiveService.saveProgress(ProgressRecordModel.fromEntity(updatedProgress));
          return Right(newStreak);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyProgress>>> getProgressHistory({int days = 30}) async {
    try {
      // Simplified - return empty list for now
      // In production, you'd track daily progress separately
      return const Right([]);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<QuestionCategory, double>>> getCategoryScores() async {
    try {
      final currentResult = await getCurrentProgress();
      return currentResult.fold(
        (failure) => Left(failure),
        (current) => Right(current.categoryScores),
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetProgress() async {
    try {
      final initialProgress = ProgressRecord(
        id: _uuid.v4(),
        date: DateTime.now(),
      );
      await hiveService.saveProgress(ProgressRecordModel.fromEntity(initialProgress));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
