import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carteira_core/carteira_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

http.Response _json(int status, Object? body) => http.Response(
  body == null ? '' : jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _error(int status, String code, {Map<String, String>? fields}) =>
    _json(status, {
      'error': {'code': code, 'message': 'msg $code', 'fields': ?fields},
    });

void main() {
  late http.Request? captured;

  ApiClient client(FutureOr<http.Response> Function(http.Request) handler) {
    captured = null;
    return ApiClient(
      baseUrl: 'http://localhost:8080',
      timeout: const Duration(milliseconds: 100),
      client: MockClient((request) async {
        captured = request;
        return handler(request);
      }),
    );
  }

  group('request building', () {
    test('sends method, path, query, token and JSON body', () async {
      final api = client((_) => _json(200, {'ok': true}))..token = 'tok_1';
      await api.post(
        '/transactions',
        body: {'a': 1},
        headers: {'X-Delay-Ms': '10'},
      );
      expect(captured!.method, 'POST');
      expect(captured!.url.toString(), 'http://localhost:8080/transactions');
      expect(captured!.headers['Authorization'], 'Bearer tok_1');
      expect(captured!.headers['X-Delay-Ms'], '10');
      expect(captured!.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(captured!.body), {'a': 1});
    });

    test('omits the token when not set and encodes the query', () async {
      final api = client((_) => _json(200, []));
      await api.get('/transactions', query: {'month': '2026-09', 'q': 'a b'});
      expect(captured!.headers.containsKey('Authorization'), isFalse);
      expect(captured!.url.queryParameters, {'month': '2026-09', 'q': 'a b'});
    });

    test('supports a base URL with a path prefix', () async {
      captured = null;
      final api = ApiClient(
        baseUrl: 'https://example.com/api/v1',
        client: MockClient((request) async {
          captured = request;
          return _json(200, null);
        }),
      );
      await api.get('/me');
      expect(captured!.url.toString(), 'https://example.com/api/v1/me');
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
      final api = client((_) => http.Response('', 204));
      expect(await api.delete('/x'), const Ok<Object?>(null));
    });

    test('put and patch are sent', () async {
      final api = client((_) => _json(200, {}));
      await api.put('/x', body: {});
      expect(captured!.method, 'PUT');
      await api.patch('/x', body: {});
      expect(captured!.method, 'PATCH');
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
      final api = client((_) => http.Response('teapot', 418));
      expect((await api.get('/x')).errorOrNull, isA<UnknownError>());
    });

    test('malformed JSON becomes UnknownError', () async {
      final api = client((_) => http.Response('{not json', 200));
      expect((await api.get('/x')).errorOrNull, isA<UnknownError>());
    });

    test('timeout becomes TimeoutError', () async {
      final api = client(
        (_) => Future.delayed(const Duration(seconds: 1), () => _json(200, {})),
      );
      expect(await api.get('/x'), const Failure<Object?>(TimeoutError()));
    });

    test('SocketException becomes NetworkError', () async {
      final api = client((_) => throw const SocketException('refused'));
      expect(await api.get('/x'), const Failure<Object?>(NetworkError()));
    });

    test('ClientException becomes NetworkError', () async {
      final api = client((_) => throw http.ClientException('closed'));
      expect(await api.get('/x'), const Failure<Object?>(NetworkError()));
    });
  });

  test('mapError tolerates bodies without the error envelope', () {
    expect(ApiClient.mapError(404, null), isA<NotFoundError>());
    expect(ApiClient.mapError(422, 'text'), const ValidationError({}));
    expect(ApiClient.mapError(503, {'x': 1}), const ServerError(503));
  });
}
