import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:carteira_core/carteira_core.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// Replaces the network: every request goes to [handler].
class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) handler;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _text(int status, String text) => ResponseBody.fromString(
  text,
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ResponseBody _json(int status, Object? body) =>
    _text(status, body == null ? '' : jsonEncode(body));

ResponseBody _error(int status, String code, {Map<String, String>? fields}) =>
    _json(status, {
      'error': {'code': code, 'message': 'msg $code', 'fields': ?fields},
    });

DioException _dioError(DioExceptionType type) =>
    DioException(requestOptions: RequestOptions(), type: type);

void main() {
  late _Adapter adapter;

  ApiClient client(
    FutureOr<ResponseBody> Function(RequestOptions) handler, {
    String baseUrl = 'http://localhost:8080',
    Map<String, String> headers = const {},
  }) {
    adapter = _Adapter(handler);
    return ApiClient(baseUrl: baseUrl, headers: headers, adapter: adapter);
  }

  group('request building', () {
    test('sends method, path, token, fixed headers and JSON body', () async {
      final api = client(
        (_) => _json(200, {'ok': true}),
        headers: {'X-Delay-Ms': '10'},
      )..token = 'tok_1';
      await api.post('/transactions', body: {'a': 1});
      final sent = adapter.captured!;
      expect(sent.method, 'POST');
      expect(sent.uri.toString(), 'http://localhost:8080/transactions');
      expect(sent.headers['Authorization'], 'Bearer tok_1');
      expect(sent.headers['X-Delay-Ms'], '10');
      expect(sent.contentType, contains('application/json'));
      expect(sent.data, {'a': 1});
    });

    test('omits the token when not set and encodes the query', () async {
      final api = client((_) => _json(200, []));
      await api.get('/transactions', query: {'month': '2026-09', 'q': 'a b'});
      final sent = adapter.captured!;
      expect(sent.headers.containsKey('Authorization'), isFalse);
      expect(sent.uri.queryParameters, {'month': '2026-09', 'q': 'a b'});
    });

    test('supports a base URL with a path prefix', () async {
      final api = client(
        (_) => _json(200, null),
        baseUrl: 'https://example.com/api/v1',
      );
      await api.get('/me');
      expect(adapter.captured!.uri.toString(), 'https://example.com/api/v1/me');
    });
  });

  group('success mapping', () {
    test('200 returns the decoded body', () async {
      final api = client((_) => _json(200, {'id': 1}));
      expect((await api.get('/x')).valueOrNull, {'id': 1});
    });

    test('201 returns the decoded body', () async {
      final api = client((_) => _json(201, {'id': 'tx_1'}));
      expect((await api.post('/x')).valueOrNull, {'id': 'tx_1'});
    });

    test('204 returns null', () async {
      final api = client((_) => _text(204, ''));
      expect(await api.delete('/x'), const Ok<Object?>(null));
    });

    test('put is sent', () async {
      final api = client((_) => _json(200, {}));
      await api.put('/x', body: {});
      expect(adapter.captured!.method, 'PUT');
    });
  });

  group('error mapping', () {
    test('401 invalid_credentials', () async {
      final api = client((_) => _error(401, 'invalid_credentials'));
      expect(
        await api.post('/auth/login'),
        const Failure<Object?>(UnauthorizedError(invalidCredentials: true)),
      );
    });

    test('401 token_expired', () async {
      final api = client((_) => _error(401, 'token_expired'));
      expect(
        (await api.get('/me')).errorOrNull,
        const UnauthorizedError(expired: true),
      );
    });

    test('401 unauthorized', () async {
      final api = client((_) => _error(401, 'unauthorized'));
      expect((await api.get('/me')).errorOrNull, const UnauthorizedError());
    });

    test('404 carries the server message', () async {
      final api = client((_) => _error(404, 'not_found'));
      final error = (await api.get('/transactions/x')).errorOrNull;
      expect(error, isA<NotFoundError>());
      expect((error! as NotFoundError).resource, 'msg not_found');
    });

    test('422 carries the fields', () async {
      final api = client(
        (_) => _error(422, 'validation', fields: {'amount': 'must be > 0'}),
      );
      final error = (await api.post('/transactions')).errorOrNull;
      expect(
        error,
        const ValidationError({
          'amount': 'must be > 0',
        }, detail: 'msg validation'),
      );
    });

    test('500 becomes ServerError', () async {
      final api = client((_) => _error(500, 'internal'));
      expect((await api.get('/x')).errorOrNull, const ServerError(500));
    });

    test('other statuses become UnknownError', () async {
      final api = client((_) => ResponseBody.fromString('teapot', 418));
      expect((await api.get('/x')).errorOrNull, isA<UnknownError>());
    });

    test('malformed JSON becomes UnknownError', () async {
      final api = client((_) => _text(200, '{not json'));
      expect((await api.get('/x')).errorOrNull, isA<UnknownError>());
    });

    test('timeouts become TimeoutError', () async {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final api = client((_) => throw _dioError(type));
        expect(await api.get('/x'), const Failure<Object?>(TimeoutError()));
      }
    });

    test('a connection error becomes NetworkError', () async {
      final api = client(
        (_) => throw _dioError(DioExceptionType.connectionError),
      );
      expect(await api.get('/x'), const Failure<Object?>(NetworkError()));
    });
  });

  test('mapError tolerates bodies without the error envelope', () {
    expect(ApiClient.mapError(404, null), isA<NotFoundError>());
    expect(ApiClient.mapError(422, 'text'), const ValidationError({}));
    expect(ApiClient.mapError(503, {'x': 1}), const ServerError(503));
  });
}
