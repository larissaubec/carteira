import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/command.dart';

/// State and actions of the profile tab.
///
/// Shows the user stored with the session right away, then refreshes it
/// from `GET /me`.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _user = authRepository.currentSession?.user {
    load = Command0<User>(_load);
    signOut = Command0<void>(_authRepository.logout);
  }

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  /// Refreshes [user] from the API.
  late final Command0<User> load;

  /// Ends the session. The local session is cleared even when the server
  /// call fails, so the view leaves on any outcome.
  late final Command0<void> signOut;

  User? _user;

  /// The signed-in user, or null before anything is known.
  User? get user => _user;

  Future<Result<User>> _load() async {
    final result = await _userRepository.getProfile();
    if (result case Ok(:final value)) {
      _user = value;
      notifyListeners();
    }
    return result;
  }

  @override
  void dispose() {
    load.dispose();
    signOut.dispose();
    super.dispose();
  }
}
