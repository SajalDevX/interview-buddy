import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/enums.dart';
import '../../entities/interview_session.dart';
import '../../repositories/interview_repository.dart';

class StartInterviewUseCase {
  final InterviewRepository repository;

  StartInterviewUseCase({required this.repository});

  Future<Either<Failure, InterviewSession>> call({
    required String targetRole,
    required InterviewType type,
    String? resumeId,
  }) {
    return repository.startInterview(
      targetRole: targetRole,
      type: type,
      resumeId: resumeId,
    );
  }
}
