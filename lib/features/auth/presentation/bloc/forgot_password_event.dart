part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordSendOtpRequested extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordSendOtpRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class ForgotPasswordVerifyOtpRequested extends ForgotPasswordEvent {
  final String email;
  final String otp;
  const ForgotPasswordVerifyOtpRequested({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

class ForgotPasswordResetRequested extends ForgotPasswordEvent {
  final String email;
  final String otp;
  final String newPassword;
  const ForgotPasswordResetRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [email, otp, newPassword];
}
