import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/home_repository.dart';

class GetPlantsUseCase extends UseCase<List<PlantEntity>, NoParams> {
  final HomeRepository _repository;
  GetPlantsUseCase(this._repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(NoParams params) =>
      _repository.getPlants();
}
