import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/progress_record.dart';
import '../../repositories/progress_repository.dart';

class GetProgressUseCase {
  final ProgressRepository repository;

  GetProgressUseCase({required this.repository});

  Future<Either<Failure, ProgressRecord>> call() {
    return repository.getCurrentProgress();
  }
}
