import '../models/session.dart';
import '../result/result.dart';

/// Authentication.
abstract interface class AuthRepository {
  /// Signs in and stores the session.
  Future<Result<Session>> login({
    required String email,
    required String password,
  });

  /// Invalidates the session on the server and clears it locally.
  Future<Result<void>> logout();

  /// Restores a previously stored session, or `null` when there is none.
  Future<Result<Session?>> restore();

  /// The current session, if signed in.
  Session? get currentSession;
}
