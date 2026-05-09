part of 'explore_bloc.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();
  @override
  List<Object?> get props => [];
}

/// Initial load — fetches trending + new arrivals
class ExploreLoadRequested extends ExploreEvent {
  const ExploreLoadRequested();
}

/// User tapped a category pill
class ExploreCategorySelected extends ExploreEvent {
  final PlantCategory? category; // null = clear filter
  const ExploreCategorySelected(this.category);
  @override
  List<Object?> get props => [category];
}

/// User typed in the search bar
class ExploreSearchChanged extends ExploreEvent {
  final String query;
  const ExploreSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// User tapped a care level card
class ExploreCareLevelSelected extends ExploreEvent {
  final CareLevel level;
  const ExploreCareLevelSelected(this.level);
  @override
  List<Object?> get props => [level];
}

/// User tapped a room card
class ExploreRoomSelected extends ExploreEvent {
  final RoomType room;
  const ExploreRoomSelected(this.room);
  @override
  List<Object?> get props => [room];
}

/// Clear any active filter / search
class ExploreClearFilter extends ExploreEvent {
  const ExploreClearFilter();
}

/// Fired by the UI timer to advance the animated hint to the next keyword
class ExploreAdvanceSearchHint extends ExploreEvent {
  const ExploreAdvanceSearchHint();
}
