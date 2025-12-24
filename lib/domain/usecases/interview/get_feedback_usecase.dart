import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/enums.dart';
import '../../entities/interview_session.dart';
import '../../repositories/interview_repository.dart';

class GetFeedbackUseCase {
  final InterviewRepository repository;

  GetFeedbackUseCase({required this.repository});

  Future<Either<Failure, ResponseScore>> call({
    required String question,
    required String answer,
    required QuestionCategory category,
    required String targetRole,
  }) {
    return repository.getFeedback(
      question: question,
      answer: answer,
      category: category,
      targetRole: targetRole,
    );
  }
}
