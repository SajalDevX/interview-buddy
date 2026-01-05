import '../../../core/utils/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase({required this.repository});

  Future<Either<Failure, AuthUser>> call() {
    return repository.signInWithGoogle();
  }
}
