import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/explore_section_entity.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_local_datasource.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreLocalDataSource _dataSource;

  ExploreRepositoryImpl({required ExploreLocalDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, ExploreEntity>> getExploreData() async {
    try {
      final trending   = _dataSource.getTrendingPlants().map((m) => m.toEntity()).toList();
      final newArrivals = _dataSource.getNewArrivals().map((m) => m.toEntity()).toList();
      return Right(ExploreEntity(
        trendingPlants: trending,
        newArrivals:    newArrivals,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlantEntity>>> filterByCategory(
      PlantCategory category) async {
    try {
      final plants = _dataSource.filterByCategory(category).map((m) => m.toEntity()).toList();
      return Right(plants);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlantEntity>>> searchPlants(String query) async {
    try {
      final plants = _dataSource.searchPlants(query).map((m) => m.toEntity()).toList();
      return Right(plants);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlantEntity>>> getPlantsByCareLevel(
      CareLevel level) async {
    try {
      final plants = _dataSource.getPlantsByCareLevel(level).map((m) => m.toEntity()).toList();
      return Right(plants);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlantEntity>>> getPlantsByRoom(
      RoomType room) async {
    try {
      final plants = _dataSource.getPlantsByRoom(room).map((m) => m.toEntity()).toList();
      return Right(plants);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
