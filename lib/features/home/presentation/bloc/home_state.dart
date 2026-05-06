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
  final PlantCategory? activeCategory; // null = All
  final String searchQuery;

  const HomeLoaded({
    required this.plants,
    this.activeCategory,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [plants, activeCategory, searchQuery];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object?> get props => [message];
}
