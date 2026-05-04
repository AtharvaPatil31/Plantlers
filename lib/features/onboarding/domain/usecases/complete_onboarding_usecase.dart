import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase extends UseCase<void, NoParams> {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.completeOnboarding();
  }
}
