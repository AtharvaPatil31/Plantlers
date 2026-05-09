import '../../../home/data/datasources/home_local_datasource.dart';
import '../../../home/data/models/plant_model.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/explore_section_entity.dart';

abstract class ExploreLocalDataSource {
  List<PlantModel> getTrendingPlants();
  List<PlantModel> getNewArrivals();
  List<PlantModel> getAllPlants();
  List<PlantModel> filterByCategory(PlantCategory category);
  List<PlantModel> searchPlants(String query);
  List<PlantModel> getPlantsByCareLevel(CareLevel level);
  List<PlantModel> getPlantsByRoom(RoomType room);
}

class ExploreLocalDataSourceImpl implements ExploreLocalDataSource {
  // Reuse the same mock data from home — single source of truth
  final HomeLocalDataSource _homeDataSource;

  ExploreLocalDataSourceImpl({required HomeLocalDataSource homeDataSource})
      : _homeDataSource = homeDataSource;

  @override
  List<PlantModel> getAllPlants() => _homeDataSource.getPlants();

  @override
  List<PlantModel> getTrendingPlants() {
    // Trending = tropical + office plants (first 4)
    final all = _homeDataSource.getPlants();
    return all
        .where((p) =>
            p.categories.contains(PlantCategory.tropical) ||
            p.categories.contains(PlantCategory.office))
        .take(4)
        .toList();
  }

  @override
  List<PlantModel> getNewArrivals() {
    // New arrivals = last 4 in the catalogue
    final all = _homeDataSource.getPlants();
    return all.reversed.take(4).toList();
  }

  @override
  List<PlantModel> filterByCategory(PlantCategory category) {
    return _homeDataSource
        .getPlants()
        .where((p) => p.categories.contains(category))
        .toList();
  }

  @override
  List<PlantModel> searchPlants(String query) {
    final q = query.toLowerCase();
    return _homeDataSource
        .getPlants()
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.subtitle.toLowerCase().contains(q) ||
            p.tag.toLowerCase().contains(q))
        .toList();
  }

  @override
  List<PlantModel> getPlantsByCareLevel(CareLevel level) {
    final all = _homeDataSource.getPlants();
    switch (level) {
      case CareLevel.easy:
        // Easy = pet friendly + low light
        return all
            .where((p) =>
                p.categories.contains(PlantCategory.petFriendly) ||
                p.categories.contains(PlantCategory.lowLight))
            .toList();
      case CareLevel.medium:
        // Medium = office + air purifier
        return all
            .where((p) =>
                p.categories.contains(PlantCategory.office) ||
                p.categories.contains(PlantCategory.airPurifier))
            .toList();
      case CareLevel.expert:
        // Expert = tropical
        return all
            .where((p) => p.categories.contains(PlantCategory.tropical))
            .toList();
    }
  }

  @override
  List<PlantModel> getPlantsByRoom(RoomType room) {
    final all = _homeDataSource.getPlants();
    switch (room) {
      case RoomType.bedroom:
        return all
            .where((p) =>
                p.categories.contains(PlantCategory.lowLight) ||
                p.categories.contains(PlantCategory.airPurifier))
            .toList();
      case RoomType.office:
        return all
            .where((p) => p.categories.contains(PlantCategory.office))
            .toList();
      case RoomType.livingRoom:
        return all
            .where((p) =>
                p.categories.contains(PlantCategory.tropical) ||
                p.categories.contains(PlantCategory.office))
            .toList();
      case RoomType.balcony:
        return all
            .where((p) => p.categories.contains(PlantCategory.tropical))
            .toList();
    }
  }
}
