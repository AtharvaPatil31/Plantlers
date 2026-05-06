import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/plant_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<PlantEntity>>> getPlants();
  Future<Either<Failure, List<PlantEntity>>> filterPlants(PlantCategory category);
  Future<Either<Failure, List<PlantEntity>>> searchPlants(String query);
}
