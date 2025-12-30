import 'package:flutter/foundation.dart';

/// Represents a registered user or guest in the system.
///
/// Mirrors the backend `User` entity structure defined in `user.types.ts`.
@immutable
class User {
  /// Unique identifier for the user (Firebase Auth UID).
  final String id;

  /// User's email address.
  /// Required for registered users, null for anonymous guests.
  final String? email;

  /// Display name for UI greeting.
  final String? displayName;

  /// Indicates if this is an anonymous guest account.
  final bool isGuest;

  /// Denormalized count of documents owned by this user.
  final int documentCount;

  /// User preferences.
  final UserSettings settings;

  /// Timestamp of account creation.
  final DateTime createdAt;

  /// Timestamp of last profile update.
  final DateTime updatedAt;

  const User({
    required this.id,
    this.email,
    this.displayName,
    required this.isGuest,
    required this.documentCount,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [User] instance from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      isGuest: json['isGuest'] as bool,
      documentCount: (json['documentCount'] as num?)?.toInt() ?? 0,
      settings: UserSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the [User] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isGuest': isGuest,
      'documentCount': documentCount,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [User] but with the given fields replaced with the new values.
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isGuest,
    int? documentCount,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      documentCount: documentCount ?? this.documentCount,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.isGuest == isGuest &&
        other.documentCount == documentCount &&
        other.settings == settings &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        isGuest.hashCode ^
        documentCount.hashCode ^
        settings.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, isGuest: $isGuest, documents: $documentCount)';
  }
}

/// User-configurable application settings.
@immutable
class UserSettings {
  /// UI Theme preference ('light', 'dark', or 'system').
  final String theme;

  const UserSettings({required this.theme});

  /// Creates a [UserSettings] instance from a JSON map.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(theme: json['theme'] as String? ?? 'system');
  }

  /// Converts the [UserSettings] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'theme': theme};
  }

  /// Creates a copy of this [UserSettings] but with the given fields replaced with the new values.
  UserSettings copyWith({String? theme}) {
    return UserSettings(theme: theme ?? this.theme);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettings && other.theme == theme;
  }

  @override
  int get hashCode => theme.hashCode;

  @override
  String toString() => 'UserSettings(theme: $theme)';
}
