import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/command.dart';

/// E-mail and password typed on the login screen.
typedef Credentials = ({String email, String password});

/// State and actions of the login screen.
///
/// Validates the form locally first (no request for an empty field), then
/// signs in through the [AuthRepository]. The repository stores the session
/// on success, so the next launch skips this screen.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    login = Command1<Session, Credentials>(_login);
  }

  final AuthRepository _authRepository;

  /// Calls the API. The view listens to it: spinner while running, message
  /// on failure, navigation on success.
  late final Command1<Session, Credentials> login;

  String? _emailError;
  String? _passwordError;

  /// Message under the e-mail field, or null.
  String? get emailError => _emailError;

  /// Message under the password field, or null.
  String? get passwordError => _passwordError;

  /// Message for the whole form when the sign in failed (wrong password,
  /// server down, no connection), or null.
  String? get errorMessage => login.result?.errorOrNull?.message;

  /// Validates and, when the form is valid, runs [login].
  Future<void> submit({required String email, required String password}) {
    _emailError = validateEmail(email);
    _passwordError = validatePassword(password);
    notifyListeners();
    if (_emailError != null || _passwordError != null) {
      login.clearResult();
      return Future.value();
    }
    return login.execute((email: email.trim(), password: password));
  }

  /// The user is typing again: hide the stale messages.
  void onEdited() {
    if (_emailError == null && _passwordError == null && !login.error) return;
    _emailError = null;
    _passwordError = null;
    login.clearResult();
    notifyListeners();
  }

  Future<Result<Session>> _login(Credentials credentials) {
    return _authRepository.login(
      email: credentials.email,
      password: credentials.password,
    );
  }

  @override
  void dispose() {
    login.dispose();
    super.dispose();
  }
}
