import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _localDataSource;

  HomeRepositoryImpl({required HomeLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<PlantEntity>>> getPlants() async {
    try {
      final models = _localDataSource.getPlants();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlantEntity>>> filterPlants(
      PlantCategory category) async {
    try {
      final models = _localDataSource.getPlants();
      final filtered = models
          .where((m) => m.categories.contains(category))
          .map((m) => m.toEntity())
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlantEntity>>> searchPlants(String query) async {
    try {
      final models = _localDataSource.getPlants();
      final q = query.toLowerCase();
      final results = models
          .where((m) =>
              m.name.toLowerCase().contains(q) ||
              m.tag.toLowerCase().contains(q) ||
              m.subtitle.toLowerCase().contains(q))
          .map((m) => m.toEntity())
          .toList();
      return Right(results);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions() async {
    try {
      return Right(_localDataSource.getSearchSuggestions());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
