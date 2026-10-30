import '../../models/session.dart';
import '../../models/user.dart';
import '../../result/app_error.dart';
import '../../result/result.dart';
import '../../storage/in_memory_session_storage.dart';
import '../../storage/session_storage.dart';
import '../auth_repository.dart';
import 'sample_data.dart';

/// Accepts one known user. No network involved.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({
    User? user,
    this._password = SampleData.password,
    SessionStorage? storage,
    this.delay = Duration.zero,
  }) : _user = user ?? SampleData.user,
       _storage = storage ?? InMemorySessionStorage();

  final User _user;
  final String _password;
  final SessionStorage _storage;
  final Duration delay;

  Session? _session;

  @override
  Session? get currentSession => _session;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final matches =
        email.trim().toLowerCase() == _user.email.toLowerCase() &&
        password == _password;
    if (!matches) {
      return const Failure(UnauthorizedError(invalidCredentials: true));
    }
    final session = Session(
      token: 'tok_${DateTime.now().millisecondsSinceEpoch}',
      user: _user,
    );
    _session = session;
    await _storage.write(session);
    return Ok(session);
  }

  @override
  Future<Result<void>> logout() async {
    await Future<void>.delayed(delay);
    _session = null;
    await _storage.clear();
    return const Ok(null);
  }

  @override
  Future<Result<Session?>> restore() async {
    await Future<void>.delayed(delay);
    _session = await _storage.read();
    return Ok(_session);
  }
}
