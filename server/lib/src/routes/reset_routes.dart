import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../json.dart';
import '../middleware/auth.dart';
import '../store.dart';

void registerResetRoutes(Router router, SessionStore store) {
  router.post('/reset', (Request request) {
    store.reset(request.token);
    return noContent();
  });
}
