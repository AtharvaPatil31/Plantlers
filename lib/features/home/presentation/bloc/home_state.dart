part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<PlantEntity> plants;
  final PlantCategory? activeCategory;
  final String searchQuery;

  /// Keywords that cycle in the search bar placeholder.
  final List<String> searchSuggestions;

  /// Index of the currently displayed suggestion.
  final int hintIndex;

  const HomeLoaded({
    required this.plants,
    this.activeCategory,
    this.searchQuery = '',
    this.searchSuggestions = const [],
    this.hintIndex = 0,
  });

  HomeLoaded copyWith({
    List<PlantEntity>? plants,
    PlantCategory? activeCategory,
    bool clearCategory = false,
    String? searchQuery,
    List<String>? searchSuggestions,
    int? hintIndex,
  }) {
    return HomeLoaded(
      plants: plants ?? this.plants,
      activeCategory:
          clearCategory ? null : (activeCategory ?? this.activeCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
      hintIndex: hintIndex ?? this.hintIndex,
    );
  }

  @override
  List<Object?> get props =>
      [plants, activeCategory, searchQuery, searchSuggestions, hintIndex];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object?> get props => [message];
}
