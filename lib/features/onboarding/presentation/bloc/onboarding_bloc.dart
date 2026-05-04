import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  OnboardingBloc({required CompleteOnboardingUseCase completeOnboardingUseCase})
      : _completeOnboardingUseCase = completeOnboardingUseCase,
        super(const OnboardingInitial()) {
    on<OnboardingCompleted>(_onCompleted);
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    final result = await _completeOnboardingUseCase(const NoParams());
    result.fold(
      (failure) => emit(OnboardingFailure(message: failure.message)),
      (_) => emit(const OnboardingSuccess()),
    );
  }
}
