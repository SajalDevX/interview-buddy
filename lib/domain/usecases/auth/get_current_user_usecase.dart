import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<Either<Failure, AuthUser?>> call() {
    return repository.getCurrentUser();
  }
}
