import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../entities/explore_section_entity.dart';
import '../repositories/explore_repository.dart';

// ── Filter by category ────────────────────────────────────────────────────────
class FilterExploreByCategoryUseCase
    extends UseCase<List<PlantEntity>, FilterExploreCategoryParams> {
  final ExploreRepository _repository;
  FilterExploreByCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(
          FilterExploreCategoryParams params) =>
      _repository.filterByCategory(params.category);
}

class FilterExploreCategoryParams extends Equatable {
  final PlantCategory category;
  const FilterExploreCategoryParams(this.category);
  @override
  List<Object?> get props => [category];
}

// ── Search ────────────────────────────────────────────────────────────────────
class SearchExploreUseCase
    extends UseCase<List<PlantEntity>, SearchExploreParams> {
  final ExploreRepository _repository;
  SearchExploreUseCase(this._repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(SearchExploreParams params) =>
      _repository.searchPlants(params.query);
}

class SearchExploreParams extends Equatable {
  final String query;
  const SearchExploreParams(this.query);
  @override
  List<Object?> get props => [query];
}

// ── Filter by care level ──────────────────────────────────────────────────────
class GetPlantsByCareLevelUseCase
    extends UseCase<List<PlantEntity>, CareLevelParams> {
  final ExploreRepository _repository;
  GetPlantsByCareLevelUseCase(this._repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(CareLevelParams params) =>
      _repository.getPlantsByCareLevel(params.level);
}

class CareLevelParams extends Equatable {
  final CareLevel level;
  const CareLevelParams(this.level);
  @override
  List<Object?> get props => [level];
}

// ── Filter by room ────────────────────────────────────────────────────────────
class GetPlantsByRoomUseCase
    extends UseCase<List<PlantEntity>, RoomParams> {
  final ExploreRepository _repository;
  GetPlantsByRoomUseCase(this._repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(RoomParams params) =>
      _repository.getPlantsByRoom(params.room);
}

class RoomParams extends Equatable {
  final RoomType room;
  const RoomParams(this.room);
  @override
  List<Object?> get props => [room];
}
