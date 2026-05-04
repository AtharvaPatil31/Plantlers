import '../../domain/entities/auth_entity.dart';

/// Data model — handles JSON serialization.
/// Tokens live here (data layer) and are persisted via StorageService.
/// Only identity fields are mapped to AuthEntity.
class AuthModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String accessToken;
  final String refreshToken;

  const AuthModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };

  /// Only identity fields cross into domain — tokens stay in data layer.
  AuthEntity toEntity() => AuthEntity(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
      );
}
