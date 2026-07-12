import '../../domain/entities/google_auth_entity.dart';

/// Data model — maps your Node.js backend's /auth/google response.
/// Data model — Firebase/Google SDK types stay here, never leak into domain.
class GoogleAuthModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String idToken;       // your backend's JWT access token
  final String refreshToken;  // your backend's refresh token

  const GoogleAuthModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.idToken,
    required this.refreshToken,
  });

  /// Parses the response from POST /auth/google
  /// { id, email, name, avatar_url, access_token, refresh_token }
  factory GoogleAuthModel.fromJson(Map<String, dynamic> json) =>
      GoogleAuthModel(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['name'] as String?,
        photoUrl: json['avatar_url'] as String?,
        idToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': displayName,
        'avatar_url': photoUrl,
        'access_token': idToken,
        'refresh_token': refreshToken,
      };

  GoogleAuthEntity toEntity() => GoogleAuthEntity(
        id: id,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        idToken: idToken,
      );
}

