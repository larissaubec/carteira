import '../../api/api_client.dart';
import '../../models/json.dart';
import '../../models/session.dart';
import '../../result/result.dart';
import '../../storage/session_storage.dart';
import '../auth_repository.dart';

/// Authentication against the API. Keeps the [ApiClient] token in sync with
/// the session and persists it through [SessionStorage].
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({required this._client, required this._storage});

  final ApiClient _client;
  final SessionStorage _storage;

  Session? _session;

  @override
  Session? get currentSession => _session;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    final result = await _client.post(
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    return result
        .map((json) => Session.fromJson(asJson(json)))
        .when(
          ok: (session) async {
            await _apply(session);
            return Ok(session);
          },
          failure: (error) async => Failure(error),
        );
  }

  @override
  Future<Result<void>> logout() async {
    final result = await _client.post('/auth/logout');
    // Even if the server says the token is already gone, the local session
    // must be cleared; the user asked to leave.
    await _apply(null);
    return result.map((_) {});
  }

  @override
  Future<Result<Session?>> restore() async {
    final stored = await _storage.read();
    if (stored == null) return const Ok(null);
    _session = stored;
    _client.token = stored.token;
    return Ok(stored);
  }

  Future<void> _apply(Session? session) async {
    _session = session;
    _client.token = session?.token;
    if (session == null) {
      await _storage.clear();
    } else {
      await _storage.write(session);
    }
  }
}
