part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadPlants extends HomeEvent {
  const HomeLoadPlants();
}

class HomeFilterByCategory extends HomeEvent {
  final PlantCategory? category; // null = show all
  const HomeFilterByCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class HomeSearchPlants extends HomeEvent {
  final String query;
  const HomeSearchPlants(this.query);
  @override
  List<Object?> get props => [query];
}

/// Fired by the UI timer to advance the animated hint to the next keyword.
class HomeAdvanceSearchHint extends HomeEvent {
  const HomeAdvanceSearchHint();
}
