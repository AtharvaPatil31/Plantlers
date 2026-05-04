part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String email;
  const ForgotPasswordOtpSent({required this.email});
  @override
  List<Object?> get props => [email];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String email;
  final String otp;
  const ForgotPasswordOtpVerified({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess();
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;
  const ForgotPasswordFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
