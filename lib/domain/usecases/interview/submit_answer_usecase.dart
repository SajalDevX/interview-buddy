import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/enums.dart';
import '../../entities/interview_session.dart';
import '../../repositories/interview_repository.dart';

class SubmitAnswerUseCase {
  final InterviewRepository repository;

  SubmitAnswerUseCase({required this.repository});

  Future<Either<Failure, QuestionResponse>> call({
    required String sessionId,
    required String question,
    required QuestionCategory category,
    required String transcript,
    String? audioPath,
  }) {
    return repository.submitAnswer(
      sessionId: sessionId,
      question: question,
      category: category,
      transcript: transcript,
      audioPath: audioPath,
    );
  }
}
