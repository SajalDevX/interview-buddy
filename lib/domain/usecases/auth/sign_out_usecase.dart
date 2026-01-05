import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
