import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/google_auth_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase extends UseCase<GoogleAuthEntity, NoParams> {
  final AuthRepository _repository;
  GoogleSignInUseCase(this._repository);

  @override
  Future<Either<Failure, GoogleAuthEntity>> call(NoParams params) =>
      _repository.signInWithGoogle();
}
