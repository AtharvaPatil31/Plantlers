part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthEntity user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthGoogleAuthenticated extends AuthState {
  final GoogleAuthEntity googleUser;

  const AuthGoogleAuthenticated({required this.googleUser});

  const AuthGoogleAuthenticated({required this.googleUser});
  @override
  List<Object?> get props => [googleUser];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Fired after signup when Supabase requires email confirmation.
/// The user exists but has no session yet — they must click the email link.
class AuthEmailConfirmationRequired extends AuthState {
  final String email;
  const AuthEmailConfirmationRequired({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
