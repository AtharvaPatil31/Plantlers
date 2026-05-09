import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/plant_entity.dart';

// ── Care level ────────────────────────────────────────────────────────────────
enum CareLevel { easy, medium, expert }

extension CareLevelX on CareLevel {
  String get label {
    switch (this) {
      case CareLevel.easy:   return 'Easy';
      case CareLevel.medium: return 'Medium';
      case CareLevel.expert: return 'Expert';
    }
  }

  String get subtitle {
    switch (this) {
      case CareLevel.easy:   return 'Set & forget companions';
      case CareLevel.medium: return 'Some effort required';
      case CareLevel.expert: return 'Plant parent elite';
    }
  }
}

// ── Room type ─────────────────────────────────────────────────────────────────
enum RoomType { bedroom, office, livingRoom, balcony }

extension RoomTypeX on RoomType {
  String get label {
    switch (this) {
      case RoomType.bedroom:    return 'Bedroom';
      case RoomType.office:     return 'Office';
      case RoomType.livingRoom: return 'Living Room';
      case RoomType.balcony:    return 'Balcony';
    }
  }

  String get imageUrl {
    switch (this) {
      case RoomType.bedroom:
        return 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=400&q=80';
      case RoomType.office:
        return 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400&q=80';
      case RoomType.livingRoom:
        return 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80';
      case RoomType.balcony:
        return 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&q=80';
    }
  }
}

// ── Explore data entity ───────────────────────────────────────────────────────
class ExploreEntity extends Equatable {
  final List<PlantEntity> trendingPlants;
  final List<PlantEntity> newArrivals;
  final List<PlantEntity> filteredPlants;
  final PlantCategory? activeFilter;
  final String searchQuery;

  const ExploreEntity({
    required this.trendingPlants,
    required this.newArrivals,
    this.filteredPlants = const [],
    this.activeFilter,
    this.searchQuery = '',
  });

  ExploreEntity copyWith({
    List<PlantEntity>? trendingPlants,
    List<PlantEntity>? newArrivals,
    List<PlantEntity>? filteredPlants,
    PlantCategory? activeFilter,
    bool clearFilter = false,
    String? searchQuery,
  }) {
    return ExploreEntity(
      trendingPlants:  trendingPlants  ?? this.trendingPlants,
      newArrivals:     newArrivals     ?? this.newArrivals,
      filteredPlants:  filteredPlants  ?? this.filteredPlants,
      activeFilter:    clearFilter ? null : (activeFilter ?? this.activeFilter),
      searchQuery:     searchQuery     ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [trendingPlants, newArrivals, filteredPlants, activeFilter, searchQuery];
}
