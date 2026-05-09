part of 'explore_bloc.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();
  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExploreLoaded extends ExploreState {
  final ExploreEntity data;
  final List<String>  searchSuggestions;
  final int           hintIndex;

  const ExploreLoaded({
    required this.data,
    this.searchSuggestions = const [],
    this.hintIndex = 0,
  });

  ExploreLoaded copyWith({
    ExploreEntity?  data,
    List<String>?   searchSuggestions,
    int?            hintIndex,
  }) =>
      ExploreLoaded(
        data:              data              ?? this.data,
        searchSuggestions: searchSuggestions ?? this.searchSuggestions,
        hintIndex:         hintIndex         ?? this.hintIndex,
      );

  @override
  List<Object?> get props => [data, searchSuggestions, hintIndex];
}

class ExploreError extends ExploreState {
  final String message;
  const ExploreError({required this.message});
  @override
  List<Object?> get props => [message];
}
