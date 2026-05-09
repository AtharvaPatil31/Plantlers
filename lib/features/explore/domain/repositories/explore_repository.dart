import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../entities/explore_section_entity.dart';

abstract class ExploreRepository {
  Future<Either<Failure, ExploreEntity>> getExploreData();
  Future<Either<Failure, List<PlantEntity>>> filterByCategory(PlantCategory category);
  Future<Either<Failure, List<PlantEntity>>> searchPlants(String query);
  Future<Either<Failure, List<PlantEntity>>> getPlantsByCareLevel(CareLevel level);
  Future<Either<Failure, List<PlantEntity>>> getPlantsByRoom(RoomType room);
}
