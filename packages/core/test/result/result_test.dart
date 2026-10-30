import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  const ok = Ok<int>(2);
  const failure = Failure<int>(NotFoundError('x'));

  test('map transforms only the value', () {
    expect(ok.map((v) => v * 2), const Ok<int>(4));
    expect(failure.map((v) => v * 2), failure);
  });

  test('flatMap chains results', () {
    expect(ok.flatMap((v) => Ok('$v')), const Ok<String>('2'));
    expect(
      ok.flatMap<String>((_) => const Failure(TimeoutError())),
      const Failure<String>(TimeoutError()),
    );
  });

  test('when handles both branches', () {
    expect(ok.when(ok: (v) => 'v$v', failure: (e) => 'e'), 'v2');
    expect(
      failure.when(ok: (v) => 'v', failure: (e) => e.message),
      contains('x'),
    );
  });

  test('valueOrNull and errorOrNull', () {
    expect(ok.valueOrNull, 2);
    expect(ok.errorOrNull, isNull);
    expect(failure.valueOrNull, isNull);
    expect(failure.errorOrNull, isA<NotFoundError>());
    expect(ok.isOk, isTrue);
    expect(failure.isFailure, isTrue);
  });

  test('guard wraps values and exceptions', () async {
    expect(await Result.guard(() async => 1), const Ok<int>(1));
    final thrown = await Result.guard<int>(
      () async => throw const AppException(NetworkError()),
    );
    expect(thrown, const Failure<int>(NetworkError()));
    final unknown = await Result.guard<int>(() async => throw StateError('x'));
    expect(unknown.errorOrNull, isA<UnknownError>());
  });

  test('pattern matching works on the sealed type', () {
    const Result<int> result = failure;
    final label = switch (result) {
      Ok(:final value) => 'ok $value',
      Failure(:final error) => 'fail ${error.runtimeType}',
    };
    expect(label, 'fail NotFoundError');
  });
}
