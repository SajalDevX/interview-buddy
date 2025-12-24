import '../entities/enums.dart';
import '../entities/progress_record.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

abstract class ProgressRepository {
  /// Get current progress record
  Future<Either<Failure, ProgressRecord>> getCurrentProgress();

  /// Update progress after completing a session
  Future<Either<Failure, ProgressRecord>> updateProgress({
    required int questionsAnswered,
    required Map<QuestionCategory, double> categoryScores,
    required double sessionScore,
  });

  /// Check and unlock achievements
  Future<Either<Failure, List<AchievementType>>> checkAchievements();

  /// Update streak
  Future<Either<Failure, int>> updateStreak();

  /// Get progress history
  Future<Either<Failure, List<DailyProgress>>> getProgressHistory({int days = 30});

  /// Get category-wise scores
  Future<Either<Failure, Map<QuestionCategory, double>>> getCategoryScores();

  /// Reset progress
  Future<Either<Failure, void>> resetProgress();
}
