import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'api_error.dart';
import 'latency.dart';
import 'middleware/auth.dart';
import 'middleware/cors.dart';
import 'middleware/error_handler.dart';
import 'middleware/failure.dart';
import 'middleware/latency.dart';
import 'routes/auth_routes.dart';
import 'routes/health_routes.dart';
import 'routes/me_routes.dart';
import 'routes/reset_routes.dart';
import 'routes/summary_routes.dart';
import 'routes/transaction_routes.dart';
import 'seed.dart';
import 'store.dart';

/// Versão informada em `GET /health`.
const serverVersion = '0.1.0';

/// Monta o handler completo da API.
///
/// [store] pode ser passado para inspecionar sessões em testes.
Handler createHandler({
  required Seed seed,
  LatencyConfig latency = const LatencyConfig(),
  SessionStore? store,
}) {
  final sessions = store ?? SessionStore(seed);

  Response notFound(Request request) =>
      ApiError.notFound('Route ${request.url.path} not found').toResponse();

  final protectedRouter = Router(notFoundHandler: notFound);
  final publicRouter = Router(notFoundHandler: notFound);

  registerHealthRoutes(publicRouter, version: serverVersion);
  registerAuthRoutes(
    publicRouter: publicRouter,
    protectedRouter: protectedRouter,
    store: sessions,
  );
  registerMeRoutes(protectedRouter);
  registerTransactionRoutes(protectedRouter);
  registerSummaryRoutes(protectedRouter);
  registerResetRoutes(protectedRouter, sessions);

  publicRouter.mount(
    '/',
    const Pipeline()
        .addMiddleware(authMiddleware(sessions))
        .addHandler(protectedRouter.call),
  );

  return const Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(errorHandlerMiddleware())
      .addMiddleware(failureMiddleware(latency))
      .addMiddleware(latencyMiddleware(latency))
      .addHandler(publicRouter.call);
}
