import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/home_repository.dart';

class FilterPlantsParams extends Equatable {
  final PlantCategory category;
  const FilterPlantsParams(this.category);
  @override
  List<Object?> get props => [category];
}

class FilterPlantsUseCase extends UseCase<List<PlantEntity>, FilterPlantsParams> {
  final HomeRepository _repository;
  FilterPlantsUseCase(this._repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(FilterPlantsParams params) =>
      _repository.filterPlants(params.category);
}
