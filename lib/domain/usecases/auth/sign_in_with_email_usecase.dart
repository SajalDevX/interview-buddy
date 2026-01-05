import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;

  SignInWithEmailUseCase({required this.repository});

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(email: email, password: password);
  }
}
