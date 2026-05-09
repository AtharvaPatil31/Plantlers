import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/explore_section_entity.dart';
import '../repositories/explore_repository.dart';

class GetExploreDataUseCase extends UseCase<ExploreEntity, NoParams> {
  final ExploreRepository _repository;
  GetExploreDataUseCase(this._repository);

  @override
  Future<Either<Failure, ExploreEntity>> call(NoParams params) =>
      _repository.getExploreData();
}
