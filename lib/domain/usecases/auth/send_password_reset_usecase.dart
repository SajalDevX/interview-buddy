import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  final AuthRepository repository;

  SendPasswordResetUseCase({required this.repository});

  Future<Either<Failure, void>> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}
