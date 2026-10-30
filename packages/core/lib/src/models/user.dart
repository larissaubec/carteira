import 'json.dart';

/// The person using the app.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.avatarUrl,
  });

  factory User.fromJson(Json json) => User(
    id: json.readString('id'),
    name: json.readString('name'),
    email: json.readString('email'),
    avatarUrl: json.readOptionalString('avatarUrl'),
    createdAt: json.readDateTime('createdAt'),
  );

  final String id;
  final String name;
  final String email;

  /// Optional: the user may not have picked a picture yet.
  final String? avatarUrl;
  final DateTime createdAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Json toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  User copyWith({String? name, String? Function()? avatarUrl}) => User(
    id: id,
    name: name ?? this.name,
    email: email,
    avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.avatarUrl == avatarUrl &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, name, email, avatarUrl, createdAt);

  @override
  String toString() => 'User($id, $name, $email)';
}
