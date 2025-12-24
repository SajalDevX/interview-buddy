import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/parsed_resume.dart';
import '../../repositories/resume_repository.dart';

class SaveResumeUseCase {
  final ResumeRepository repository;

  SaveResumeUseCase({required this.repository});

  Future<Either<Failure, void>> call(ParsedResume resume) {
    return repository.saveResume(resume);
  }
}
