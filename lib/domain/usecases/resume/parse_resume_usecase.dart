import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/parsed_resume.dart';
import '../../repositories/resume_repository.dart';

class ParseResumeUseCase {
  final ResumeRepository repository;

  ParseResumeUseCase({required this.repository});

  Future<Either<Failure, ParsedResume>> call(String filePath) {
    return repository.parseResume(filePath);
  }

  Future<Either<Failure, ParsedResume>> fromImage(String imagePath) {
    return repository.parseResumeFromImage(imagePath);
  }
}
