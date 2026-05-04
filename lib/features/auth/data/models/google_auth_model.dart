import '../../domain/entities/google_auth_entity.dart';

/// Data model — Firebase/Google SDK types stay here, never leak into domain.
class GoogleAuthModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String idToken;

  const GoogleAuthModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.idToken,
  });

  GoogleAuthEntity toEntity() => GoogleAuthEntity(
        id: id,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        idToken: idToken,
      );
}
