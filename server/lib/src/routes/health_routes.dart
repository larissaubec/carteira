import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../json.dart';

void registerHealthRoutes(Router router, {required String version}) {
  router.get('/health', (Request request) {
    return jsonResponse({'status': 'ok', 'version': version});
  });
}
