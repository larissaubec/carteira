import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../api_error.dart';
import '../json.dart';
import '../middleware/auth.dart';
import '../store.dart';

void registerAuthRoutes({
  required Router publicRouter,
  required Router protectedRouter,
  required SessionStore store,
}) {
  publicRouter.post('/auth/login', (Request request) async {
    final body = await readJsonObject(request);
    final email = body['email'];
    final password = body['password'];
    final errors = <String, String>{
      if (email is! String || email.trim().isEmpty)
        'email': 'must not be empty',
      if (password is! String || password.isEmpty)
        'password': 'must not be empty',
    };
    if (errors.isNotEmpty) {
      throw ApiError.validation('Invalid credentials payload', errors);
    }
    final token = store.login(email as String, password as String);
    if (token == null) {
      throw const ApiError.invalidCredentials();
    }
    return jsonResponse({'token': token, 'user': store.find(token)!.user});
  });

  protectedRouter.post('/auth/logout', (Request request) {
    store.logout(request.token);
    return noContent();
  });
}
