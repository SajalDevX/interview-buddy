import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/enums.dart';
import '../../entities/progress_record.dart';
import '../../repositories/progress_repository.dart';

class UpdateProgressUseCase {
  final ProgressRepository repository;

  UpdateProgressUseCase({required this.repository});

  Future<Either<Failure, ProgressRecord>> call({
    required int questionsAnswered,
    required Map<QuestionCategory, double> categoryScores,
    required double sessionScore,
  }) {
    return repository.updateProgress(
      questionsAnswered: questionsAnswered,
      categoryScores: categoryScores,
      sessionScore: sessionScore,
    );
  }
}
