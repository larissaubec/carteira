import 'dart:math';

import 'json.dart';
import 'seed.dart';

/// Dados de uma sessão: cópia exclusiva do seed do usuário logado.
class SessionData {
  SessionData._({
    required this.user,
    required this.transactions,
    required int nextTransactionNumber,
  }) : _next = nextTransactionNumber;

  /// Copia os dados do [seedUser]. Alterações nunca chegam ao seed.
  factory SessionData.fromSeed(SeedUser seedUser, {required int nextNumber}) {
    return SessionData._(
      user: seedUser.toPublicJson(),
      transactions: seedUser.transactions
          .map((transaction) => JsonMap.from(transaction))
          .toList(),
      nextTransactionNumber: nextNumber,
    );
  }

  JsonMap user;
  final List<JsonMap> transactions;

  int _next;

  String nextTransactionId() {
    final id = 'tx_${_next.toString().padLeft(4, '0')}';
    _next++;
    return id;
  }

  JsonMap? findTransaction(String id) {
    for (final transaction in transactions) {
      if (transaction['id'] == id) {
        return transaction;
      }
    }
    return null;
  }
}

/// Guarda as sessões ativas, uma por token.
class SessionStore {
  SessionStore(this.seed, {Random? random})
    : _random = random ?? Random.secure();

  final Seed seed;
  final Random _random;
  final Map<String, SessionData> _sessions = {};

  int get activeSessions => _sessions.length;

  /// Valida as credenciais e abre uma sessão. Devolve o token ou `null`.
  String? login(String email, String password) {
    final user = seed.findByEmail(email);
    if (user == null || user.password != password) {
      return null;
    }
    final token = _newToken();
    _sessions[token] = _fresh(user);
    return token;
  }

  SessionData? find(String token) => _sessions[token];

  void logout(String token) => _sessions.remove(token);

  /// Volta os dados da sessão ao estado do seed.
  void reset(String token) {
    final current = _sessions[token];
    if (current == null) {
      return;
    }
    final user = seed.findByEmail(current.user['email'] as String);
    if (user != null) {
      _sessions[token] = _fresh(user);
    }
  }

  SessionData _fresh(SeedUser user) =>
      SessionData.fromSeed(user, nextNumber: seed.maxTransactionNumber + 1);

  String _newToken() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer('tok_');
    for (var i = 0; i < 24; i++) {
      buffer.write(alphabet[_random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }
}
