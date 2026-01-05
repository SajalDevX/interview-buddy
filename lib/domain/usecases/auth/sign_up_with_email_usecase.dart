import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository repository;

  SignUpWithEmailUseCase({required this.repository});

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
