import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/home_repository.dart';

class SearchPlantsParams extends Equatable {
  final String query;
  const SearchPlantsParams(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchPlantsUseCase extends UseCase<List<PlantEntity>, SearchPlantsParams> {
  final HomeRepository _repository;
  SearchPlantsUseCase(this._repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(SearchPlantsParams params) =>
      _repository.searchPlants(params.query);
}
