part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingSuccess extends OnboardingState {
  const OnboardingSuccess();
}

class OnboardingFailure extends OnboardingState {
  final String message;
  const OnboardingFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
