import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/storage/shared_preferences_session_storage.dart';
import 'environment.dart';

/// Every object the app shares between screens, built once in `main`.
///
/// Views never see this class: the router takes the repositories from here
/// and hands them to each ViewModel through its constructor.
class AppDependencies {
  AppDependencies({
    required this.authRepository,
    required this.transactionRepository,
    required this.userRepository,
    ThemeMode themeMode = ThemeMode.system,
  }) : themeMode = ValueNotifier(themeMode);

  /// Talks to the API at [Environment.apiBaseUrl].
  factory AppDependencies.remote({required SessionStorage storage}) {
    final client = ApiClient(baseUrl: Environment.apiBaseUrl);
    return AppDependencies(
      authRepository: RemoteAuthRepository(client: client, storage: storage),
      transactionRepository: RemoteTransactionRepository(client: client),
      userRepository: RemoteUserRepository(client: client),
    );
  }

  /// No network: the in-memory repositories of `carteira_core`. Used with
  /// `--dart-define=USE_IN_MEMORY=true` and by the widget tests.
  factory AppDependencies.inMemory({
    SessionStorage? storage,
    Duration delay = const Duration(milliseconds: 400),
  }) {
    return AppDependencies(
      authRepository: InMemoryAuthRepository(storage: storage, delay: delay),
      transactionRepository: InMemoryTransactionRepository(delay: delay),
      userRepository: InMemoryUserRepository(delay: delay),
    );
  }

  final AuthRepository authRepository;
  final TransactionRepository transactionRepository;
  final UserRepository userRepository;

  /// Light, dark or follow the system. Changed by the button on the home
  /// app bar.
  final ValueNotifier<ThemeMode> themeMode;

  /// Builds the dependencies chosen by [Environment] and restores the stored
  /// session before the first frame, so the router already knows whether to
  /// start on the login or on the home screen.
  static Future<AppDependencies> create() async {
    final storage = SharedPreferencesSessionStorage(
      await SharedPreferences.getInstance(),
    );
    final dependencies = Environment.useInMemory
        ? AppDependencies.inMemory(storage: storage)
        : AppDependencies.remote(storage: storage);
    await dependencies.authRepository.restore();
    return dependencies;
  }
}
