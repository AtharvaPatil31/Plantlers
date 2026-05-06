import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/usecases/filter_plants_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/search_plants_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPlantsUseCase _getPlantsUseCase;
  final FilterPlantsUseCase _filterPlantsUseCase;
  final SearchPlantsUseCase _searchPlantsUseCase;

  HomeBloc({
    required GetPlantsUseCase getPlantsUseCase,
    required FilterPlantsUseCase filterPlantsUseCase,
    required SearchPlantsUseCase searchPlantsUseCase,
  })  : _getPlantsUseCase = getPlantsUseCase,
        _filterPlantsUseCase = filterPlantsUseCase,
        _searchPlantsUseCase = searchPlantsUseCase,
        super(const HomeInitial()) {
    on<HomeLoadPlants>(_onLoadPlants);
    on<HomeFilterByCategory>(_onFilterByCategory);
    on<HomeSearchPlants>(_onSearchPlants);
  }

  Future<void> _onLoadPlants(
    HomeLoadPlants event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await _getPlantsUseCase(const NoParams());
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (plants) => emit(HomeLoaded(plants: plants)),
    );
  }

  Future<void> _onFilterByCategory(
    HomeFilterByCategory event,
    Emitter<HomeState> emit,
  ) async {
    if (event.category == null) {
      // Show all
      final result = await _getPlantsUseCase(const NoParams());
      result.fold(
        (failure) => emit(HomeError(message: failure.message)),
        (plants) => emit(HomeLoaded(plants: plants, activeCategory: null)),
      );
      return;
    }
    final result = await _filterPlantsUseCase(FilterPlantsParams(event.category!));
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (plants) => emit(HomeLoaded(plants: plants, activeCategory: event.category)),
    );
  }

  Future<void> _onSearchPlants(
    HomeSearchPlants event,
    Emitter<HomeState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const HomeLoadPlants());
      return;
    }
    final result = await _searchPlantsUseCase(SearchPlantsParams(event.query));
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (plants) => emit(HomeLoaded(
        plants: plants,
        searchQuery: event.query,
      )),
    );
  }
}
