import 'dart:convert';

import 'package:carteira_core/carteira_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the [Session] (token and user) on the device, so the app opens
/// straight on the home screen after the first sign in.
///
/// This is the Flutter implementation of the [SessionStorage] interface that
/// lives in `carteira_core`: the core says *what* must be stored, the app
/// decides *where*.
class SharedPreferencesSessionStorage implements SessionStorage {
  SharedPreferencesSessionStorage(this._preferences);

  /// Key under which the session JSON is saved.
  static const key = 'carteira.session';

  final SharedPreferences _preferences;

  @override
  Future<Session?> read() async {
    final raw = _preferences.getString(key);
    if (raw == null) return null;
    try {
      return Session.fromJson(asJson(jsonDecode(raw)));
    } on Object {
      // Corrupted or from an older version of the app: behave as signed out.
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    await _preferences.setString(key, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(key);
  }
}
