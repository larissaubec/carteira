import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('every error has a Portuguese message', () {
    const errors = <AppError>[
      NetworkError(),
      TimeoutError(),
      UnauthorizedError(),
      UnauthorizedError(expired: true),
      UnauthorizedError(invalidCredentials: true),
      NotFoundError('tx_1'),
      ValidationError({'amount': 'x'}),
      ServerError(503),
      UnknownError('boom'),
    ];
    for (final error in errors) {
      expect(error.message, isNotEmpty, reason: '$error');
    }
    expect(const UnauthorizedError(expired: true).message, contains('expirou'));
    expect(
      const UnauthorizedError(invalidCredentials: true).message,
      contains('senha'),
    );
    expect(const ServerError(503).message, contains('503'));
  });

  test('equality is structural', () {
    expect(const NetworkError(), const NetworkError());
    expect(const NotFoundError('a'), isNot(const NotFoundError('b')));
    expect(
      const ValidationError({'a': '1'}),
      const ValidationError({'a': '1'}),
    );
  });

  test('switch over AppError is exhaustive', () {
    int code(AppError e) => switch (e) {
      NetworkError() => 0,
      TimeoutError() => 1,
      UnauthorizedError() => 401,
      NotFoundError() => 404,
      ValidationError() => 422,
      ServerError(:final statusCode) => statusCode,
      UnknownError() => -1,
    };
    expect(code(const ServerError(500)), 500);
    expect(code(const NotFoundError()), 404);
  });
}
