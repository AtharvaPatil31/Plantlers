import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  ForgotPasswordBloc({
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _forgotPasswordUseCase = forgotPasswordUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSendOtpRequested>(_onSendOtp);
    on<ForgotPasswordVerifyOtpRequested>(_onVerifyOtp);
    on<ForgotPasswordResetRequested>(_onResetPassword);
  }

  Future<void> _onSendOtp(
    ForgotPasswordSendOtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(ForgotPasswordFailure(message: failure.message)),
      (_) => emit(ForgotPasswordOtpSent(email: event.email)),
    );
  }

  Future<void> _onVerifyOtp(
    ForgotPasswordVerifyOtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _verifyOtpUseCase(
      VerifyOtpParams(email: event.email, otp: event.otp),
    );
    result.fold(
      (failure) => emit(ForgotPasswordFailure(message: failure.message)),
      (_) => emit(ForgotPasswordOtpVerified(email: event.email, otp: event.otp)),
    );
  }

  Future<void> _onResetPassword(
    ForgotPasswordResetRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _resetPasswordUseCase(
      ResetPasswordParams(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(ForgotPasswordFailure(message: failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }
}
