import 'package:flutter/foundation.dart';

/// Build-time settings, read from `--dart-define`.
///
/// ```sh
/// flutter run                                         # local server
/// flutter run --dart-define=USE_IN_MEMORY=true        # no server
/// flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
/// ```
abstract final class Environment {
  /// Use the in-memory repositories of `carteira_core` instead of the API.
  static const useInMemory = bool.fromEnvironment('USE_IN_MEMORY');

  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Address of the API. Without `API_BASE_URL`, the Android emulator reaches
  /// the computer at `10.0.2.2`; every other target uses `localhost`.
  static String get apiBaseUrl {
    if (_apiBaseUrl.isNotEmpty) return _apiBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
