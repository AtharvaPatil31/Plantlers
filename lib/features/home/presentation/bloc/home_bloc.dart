import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/usecases/filter_plants_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/get_search_suggestions_usecase.dart';
import '../../domain/usecases/search_plants_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPlantsUseCase _getPlantsUseCase;
  final FilterPlantsUseCase _filterPlantsUseCase;
  final SearchPlantsUseCase _searchPlantsUseCase;
  final GetSearchSuggestionsUseCase _getSuggestionsUseCase;

  HomeBloc({
    required GetPlantsUseCase getPlantsUseCase,
    required FilterPlantsUseCase filterPlantsUseCase,
    required SearchPlantsUseCase searchPlantsUseCase,
    required GetSearchSuggestionsUseCase getSuggestionsUseCase,
  })  : _getPlantsUseCase = getPlantsUseCase,
        _filterPlantsUseCase = filterPlantsUseCase,
        _searchPlantsUseCase = searchPlantsUseCase,
        _getSuggestionsUseCase = getSuggestionsUseCase,
        super(const HomeInitial()) {
    on<HomeLoadPlants>(_onLoadPlants);
    on<HomeFilterByCategory>(_onFilterByCategory);
    on<HomeSearchPlants>(_onSearchPlants);
    on<HomeAdvanceSearchHint>(_onAdvanceSearchHint);
  }

  Future<void> _onLoadPlants(
    HomeLoadPlants event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    // Load plants and suggestions in parallel
    final plantsResult = await _getPlantsUseCase(const NoParams());
    final suggestionsResult = await _getSuggestionsUseCase(const NoParams());

    plantsResult.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (plants) {
        final suggestions = suggestionsResult.getOrElse(() => []);
        emit(HomeLoaded(plants: plants, searchSuggestions: suggestions));
      },
    );
  }

  Future<void> _onFilterByCategory(
    HomeFilterByCategory event,
    Emitter<HomeState> emit,
  ) async {
    final current = state is HomeLoaded ? state as HomeLoaded : null;

    if (event.category == null) {
      final result = await _getPlantsUseCase(const NoParams());
      result.fold(
        (failure) => emit(HomeError(message: failure.message)),
        (plants) => emit(
          current?.copyWith(plants: plants, clearCategory: true) ??
              HomeLoaded(plants: plants),
        ),
      );
      return;
    }

    final result =
        await _filterPlantsUseCase(FilterPlantsParams(event.category!));
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (plants) => emit(
        current?.copyWith(plants: plants, activeCategory: event.category) ??
            HomeLoaded(plants: plants, activeCategory: event.category),
      ),
    );
  }

  Future<void> _onSearchPlants(
    HomeSearchPlants event,
    Emitter<HomeState> emit,
  ) async {
    final current = state is HomeLoaded ? state as HomeLoaded : null;

    if (event.query.isEmpty) {
      add(const HomeLoadPlants());
      return;
    }

    final result = await _searchPlantsUseCase(SearchPlantsParams(event.query));
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (plants) => emit(
        current?.copyWith(plants: plants, searchQuery: event.query) ??
            HomeLoaded(plants: plants, searchQuery: event.query),
      ),
    );
  }

  void _onAdvanceSearchHint(
    HomeAdvanceSearchHint event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    if (current.searchSuggestions.isEmpty) return;

    final nextIndex =
        (current.hintIndex + 1) % current.searchSuggestions.length;
    emit(current.copyWith(hintIndex: nextIndex));
  }
}
