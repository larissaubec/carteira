import '../models/session.dart';
import 'session_storage.dart';

/// Keeps the session only while the process lives. Good for the CLI and tests.
class InMemorySessionStorage implements SessionStorage {
  InMemorySessionStorage([this._session]);

  Session? _session;

  @override
  Future<Session?> read() async => _session;

  @override
  Future<void> write(Session session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}
