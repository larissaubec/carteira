import 'dart:convert';
import 'dart:io';

import 'json.dart';

/// Um usuário do seed, com senha e os dados iniciais da sua sessão.
class SeedUser {
  const SeedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatarUrl,
    required this.createdAt,
    required this.transactions,
  });

  factory SeedUser.fromJson(JsonMap json) {
    return SeedUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map((item) => JsonMap.from(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String name;
  final String email;
  final String password;
  final String? avatarUrl;
  final String createdAt;
  final List<JsonMap> transactions;

  /// Representação pública, sem a senha.
  JsonMap toPublicJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt,
  };
}

/// Dados iniciais carregados de `seed.json`.
class Seed {
  const Seed(this.users);

  factory Seed.fromJson(JsonMap json) {
    return Seed(
      (json['users'] as List<dynamic>)
          .map((item) => SeedUser.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory Seed.fromString(String contents) {
    return Seed.fromJson(jsonDecode(contents) as Map<String, dynamic>);
  }

  factory Seed.fromFile(File file) => Seed.fromString(file.readAsStringSync());

  final List<SeedUser> users;

  SeedUser? findByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in users) {
      if (user.email.toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  /// Maior número usado em ids `tx_NNNN`, para gerar os próximos.
  int get maxTransactionNumber {
    var max = 0;
    for (final user in users) {
      for (final transaction in user.transactions) {
        final id = transaction['id'] as String;
        final number = int.tryParse(id.replaceFirst('tx_', '')) ?? 0;
        if (number > max) {
          max = number;
        }
      }
    }
    return max;
  }
}
