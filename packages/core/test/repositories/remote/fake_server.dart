import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A tiny in-test HTTP handler: records requests and replays canned
/// responses keyed by `METHOD /path`.
class FakeServer {
  final requests = <http.Request>[];
  final _routes = <String, http.Response Function(http.Request)>{};

  void on(String method, String path, int status, [Object? body]) {
    _routes['$method $path'] = (_) => http.Response(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  void onError(String method, String path, int status, String code) =>
      on(method, path, status, {
        'error': {'code': code, 'message': code},
      });

  http.Client get client => MockClient((request) async {
    requests.add(request);
    final handler = _routes['${request.method} ${request.url.path}'];
    if (handler == null) {
      return http.Response('{"error":{"code":"not_found"}}', 404);
    }
    return handler(request);
  });

  http.Request get last => requests.last;

  Map<String, Object?> get lastBody =>
      jsonDecode(last.body) as Map<String, Object?>;
}
