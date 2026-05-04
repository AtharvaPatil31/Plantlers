import 'package:equatable/equatable.dart';

/// Pure Dart — no Firebase, no Google SDK types.
class GoogleAuthEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String idToken;

  const GoogleAuthEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.idToken,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, idToken];
}
