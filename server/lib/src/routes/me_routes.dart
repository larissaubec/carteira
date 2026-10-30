import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../api_error.dart';
import '../json.dart';
import '../middleware/auth.dart';
import '../validation.dart';

/// Perfil do usuário logado.
void registerMeRoutes(Router router) {
  router.get('/me', (Request request) {
    return jsonResponse(request.session.user);
  });

  router.put('/me', (Request request) async {
    final body = await readJsonObject(request);
    final errors = validateProfile(body);
    if (errors.isNotEmpty) {
      throw ApiError.validation('Invalid profile', errors);
    }
    final session = request.session;
    final avatarUrl = body['avatarUrl'] as String?;
    session.user = {
      ...session.user,
      'name': (body['name'] as String).trim(),
      'avatarUrl': avatarUrl == null || avatarUrl.trim().isEmpty
          ? null
          : avatarUrl.trim(),
    };
    return jsonResponse(session.user);
  });
}
