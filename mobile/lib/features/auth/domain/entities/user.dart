/// User entity representing an authenticated user
class User {
  final String uid;
  final bool isAnonymous;
  final String? email;
  final DateTime createdAt;

  const User({
    required this.uid,
    required this.isAnonymous,
    this.email,
    required this.createdAt,
  });

  /// Create a copy of this User with some fields replaced
  User copyWith({
    String? uid,
    bool? isAnonymous,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'User(uid: $uid, isAnonymous: $isAnonymous, email: $email, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          isAnonymous == other.isAnonymous &&
          email == other.email &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      uid.hashCode ^ isAnonymous.hashCode ^ email.hashCode ^ createdAt.hashCode;
}
