import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/explore_section_entity.dart';
import '../../domain/usecases/get_explore_data_usecase.dart';
import '../../domain/usecases/filter_explore_usecase.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetExploreDataUseCase          _getExploreData;
  final FilterExploreByCategoryUseCase _filterByCategory;
  final SearchExploreUseCase           _searchPlants;
  final GetPlantsByCareLevelUseCase    _getByLevel;
  final GetPlantsByRoomUseCase         _getByRoom;

  ExploreBloc({
    required GetExploreDataUseCase          getExploreData,
    required FilterExploreByCategoryUseCase filterByCategory,
    required SearchExploreUseCase           searchPlants,
    required GetPlantsByCareLevelUseCase    getByLevel,
    required GetPlantsByRoomUseCase         getByRoom,
  })  : _getExploreData  = getExploreData,
        _filterByCategory = filterByCategory,
        _searchPlants     = searchPlants,
        _getByLevel       = getByLevel,
        _getByRoom        = getByRoom,
        super(const ExploreInitial()) {
    on<ExploreLoadRequested>(_onLoad);
    on<ExploreCategorySelected>(_onCategorySelected);
    on<ExploreSearchChanged>(_onSearchChanged);
    on<ExploreCareLevelSelected>(_onCareLevelSelected);
    on<ExploreRoomSelected>(_onRoomSelected);
    on<ExploreClearFilter>(_onClearFilter);
    on<ExploreAdvanceSearchHint>(_onAdvanceHint);
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _onLoad(
    ExploreLoadRequested event,
    Emitter<ExploreState> emit,
  ) async {
    emit(const ExploreLoading());
    final result = await _getExploreData(const NoParams());
    result.fold(
      (failure) => emit(ExploreError(message: failure.message)),
      (data)    => emit(ExploreLoaded(
        data: data,
        // Reuse the same search suggestions as home
        searchSuggestions: const [
          'Monstera Deliciosa', 'Snake Plant', 'Peace Lily',
          'Fiddle Leaf Fig',    'Pothos Golden', 'ZZ Plant',
          'Spider Plant',       'Air Purifier Plants',
          'Pet Friendly Plants','Low Light Plants',
          'Indoor Trees',       'Rubber Plant',
        ],
      )),
    );
  }

  // ── Category filter ───────────────────────────────────────────────────────
  Future<void> _onCategorySelected(
    ExploreCategorySelected event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoaded) return;
    final loaded = state as ExploreLoaded;

    if (event.category == null) {
      emit(loaded.copyWith(
          data: loaded.data.copyWith(clearFilter: true, filteredPlants: [])));
      return;
    }

    final result = await _filterByCategory(
        FilterExploreCategoryParams(event.category!));
    result.fold(
      (failure) => emit(ExploreError(message: failure.message)),
      (plants)  => emit(loaded.copyWith(
        data: loaded.data.copyWith(
          filteredPlants: plants,
          activeFilter:   event.category,
        ),
      )),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<void> _onSearchChanged(
    ExploreSearchChanged event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoaded) return;
    final loaded = state as ExploreLoaded;

    if (event.query.isEmpty) {
      emit(loaded.copyWith(
          data: loaded.data.copyWith(
              filteredPlants: [], clearFilter: true, searchQuery: '')));
      return;
    }

    final result = await _searchPlants(SearchExploreParams(event.query));
    result.fold(
      (failure) => emit(ExploreError(message: failure.message)),
      (plants)  => emit(loaded.copyWith(
        data: loaded.data.copyWith(
          filteredPlants: plants,
          searchQuery:    event.query,
        ),
      )),
    );
  }

  // ── Care level ────────────────────────────────────────────────────────────
  Future<void> _onCareLevelSelected(
    ExploreCareLevelSelected event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoaded) return;
    final loaded = state as ExploreLoaded;

    final result = await _getByLevel(CareLevelParams(event.level));
    result.fold(
      (failure) => emit(ExploreError(message: failure.message)),
      (plants)  => emit(loaded.copyWith(
        data: loaded.data.copyWith(filteredPlants: plants),
      )),
    );
  }

  // ── Room ──────────────────────────────────────────────────────────────────
  Future<void> _onRoomSelected(
    ExploreRoomSelected event,
    Emitter<ExploreState> emit,
  ) async {
    if (state is! ExploreLoaded) return;
    final loaded = state as ExploreLoaded;

    final result = await _getByRoom(RoomParams(event.room));
    result.fold(
      (failure) => emit(ExploreError(message: failure.message)),
      (plants)  => emit(loaded.copyWith(
        data: loaded.data.copyWith(filteredPlants: plants),
      )),
    );
  }

  // ── Clear ─────────────────────────────────────────────────────────────────
  void _onClearFilter(
    ExploreClearFilter event,
    Emitter<ExploreState> emit,
  ) {
    if (state is! ExploreLoaded) return;
    final loaded = state as ExploreLoaded;
    emit(loaded.copyWith(
        data: loaded.data.copyWith(
            filteredPlants: [], clearFilter: true, searchQuery: '')));
  }

  // ── Advance animated search hint ──────────────────────────────────────────
  void _onAdvanceHint(
    ExploreAdvanceSearchHint event,
    Emitter<ExploreState> emit,
  ) {
    if (state is! ExploreLoaded) return;
    final current = state as ExploreLoaded;
    if (current.searchSuggestions.isEmpty) return;
    final nextIndex = (current.hintIndex + 1) % current.searchSuggestions.length;
    emit(current.copyWith(hintIndex: nextIndex));
  }
}
