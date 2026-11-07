import 'package:go_router/go_router.dart';

import '../config/dependencies.dart';
import '../features/auth/view/login_view.dart';
import '../features/auth/view_model/login_view_model.dart';
import '../features/home/view/home_view.dart';
import '../features/home/view_model/home_view_model.dart';
import '../features/profile/view/profile_view.dart';
import '../features/profile/view_model/profile_view_model.dart';
import 'app_shell.dart';
import 'routes.dart';

/// Every screen of the app and the rule that guards them.
///
/// The router is also where ViewModels are built: it is the only place that
/// sees [AppDependencies], so views receive a ready ViewModel and never
/// touch a repository.
GoRouter createRouter(AppDependencies dependencies) {
  final auth = dependencies.authRepository;
  final viewModels = _SessionViewModels(dependencies);

  return GoRouter(
    // The session was restored in `main`: open where the user belongs.
    initialLocation: auth.currentSession == null ? Routes.login : Routes.home,
    // Guard: without a session only the login screen exists; with one, the
    // login screen is skipped.
    redirect: (context, state) {
      final signedIn = auth.currentSession != null;
      final atLogin = state.matchedLocation == Routes.login;
      if (!signedIn && !atLogin) return Routes.login;
      if (signedIn && atLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => LoginView(viewModel: viewModels.login),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => HomeView(
                  viewModel: viewModels.home,
                  themeMode: dependencies.themeMode,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) =>
                    ProfileView(viewModel: viewModels.profile),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Keeps one ViewModel per screen for the current session.
///
/// go_router may call a page builder again on any navigation; building a
/// new ViewModel each time would reload the home screen and lose filters
/// and scroll. A new session (sign out, then sign in) gets fresh ones, so
/// nothing from the previous user survives.
class _SessionViewModels {
  _SessionViewModels(this._dependencies);

  final AppDependencies _dependencies;

  Object? _session;
  LoginViewModel? _login;
  HomeViewModel? _home;
  ProfileViewModel? _profile;

  LoginViewModel get login {
    _checkSession();
    return _login ??= LoginViewModel(
      authRepository: _dependencies.authRepository,
    );
  }

  HomeViewModel get home {
    _checkSession();
    return _home ??= HomeViewModel(
      transactionRepository: _dependencies.transactionRepository,
      authRepository: _dependencies.authRepository,
    );
  }

  ProfileViewModel get profile {
    _checkSession();
    return _profile ??= ProfileViewModel(
      userRepository: _dependencies.userRepository,
      authRepository: _dependencies.authRepository,
    );
  }

  void _checkSession() {
    final session = _dependencies.authRepository.currentSession;
    if (identical(session, _session)) return;
    _session = session;
    _login = null;
    _home = null;
    _profile = null;
  }
}
