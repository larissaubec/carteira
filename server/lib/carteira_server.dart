/// API REST simulada do app Carteira.
///
/// Exponha o handler com [createHandler] para servir via `shelf_io` ou para
/// testar em processo, sem abrir sockets.
library;

export 'src/api_error.dart' show ApiError;
export 'src/handler.dart' show createHandler, serverVersion;
export 'src/latency.dart' show LatencyConfig;
export 'src/seed.dart' show Seed, SeedUser;
export 'src/store.dart' show SessionData, SessionStore;
