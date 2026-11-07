import 'package:carteira_app/data/storage/shared_preferences_session_storage.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

void main() {
  Future<SharedPreferencesSessionStorage> storageWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferencesSessionStorage(
      await SharedPreferences.getInstance(),
    );
  }

  test('returns null when nothing was stored', () async {
    final storage = await storageWith({});
    expect(await storage.read(), isNull);
  });

  test('reads back the session it wrote', () async {
    final storage = await storageWith({});
    await storage.write(sampleSession);

    final restored = await storage.read();
    expect(restored, sampleSession);
    expect(restored?.token, 'tok_test');
  });

  test('clear removes the session', () async {
    final storage = await storageWith({});
    await storage.write(sampleSession);
    await storage.clear();
    expect(await storage.read(), isNull);
  });

  test('treats corrupted data as signed out', () async {
    final storage = await storageWith({
      SharedPreferencesSessionStorage.key: '{not json',
    });
    expect(await storage.read(), isNull);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(SharedPreferencesSessionStorage.key), isNull);
  });

  test('works with the remote auth repository restore', () async {
    final storage = await storageWith({});
    await storage.write(sampleSession);
    final client = ApiClient(baseUrl: 'http://localhost:8080');
    final auth = RemoteAuthRepository(client: client, storage: storage);

    final restored = await auth.restore();
    expect(restored.valueOrNull, sampleSession);
    expect(auth.currentSession, sampleSession);
    expect(client.token, 'tok_test');
  });
}
