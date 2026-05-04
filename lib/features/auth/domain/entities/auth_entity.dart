import 'package:equatable/equatable.dart';

/// Pure Dart — no Flutter, no JSON, no external deps.
/// Only carries user identity — tokens are infrastructure, not domain.
class AuthEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  const AuthEntity({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, name, avatarUrl];
}
