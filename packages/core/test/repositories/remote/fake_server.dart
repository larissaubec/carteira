import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// What the fake saw of one request.
typedef FakeRequest = ({
  String method,
  Uri url,
  Map<String, dynamic> headers,
  Object? body,
});

/// A tiny in-test server: plugged into [ApiClient] as its network adapter, it
/// records requests and replays canned responses keyed by `METHOD /path`.
class FakeServer implements HttpClientAdapter {
  final requests = <FakeRequest>[];
  final _routes = <String, ResponseBody Function()>{};

  void on(String method, String path, int status, [Object? body]) {
    _routes['$method $path'] = () => ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  void onError(String method, String path, int status, String code) =>
      on(method, path, status, {
        'error': {'code': code, 'message': code},
      });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add((
      method: options.method,
      url: options.uri,
      headers: options.headers,
      body: options.data,
    ));
    final url = options.uri;
    final route = _routes['${options.method} ${url.path}'];
    return route?.call() ??
        ResponseBody.fromString('{"error":{"code":"not_found"}}', 404);
  }

  @override
  void close({bool force = false}) {}

  FakeRequest get last => requests.last;

  Map<String, Object?> get lastBody => last.body! as Map<String, Object?>;
}
