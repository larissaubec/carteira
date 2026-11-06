import 'dart:async';

import 'package:carteira_app/utils/command.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes running while the action is in flight', () async {
    final gate = Completer<Result<int>>();
    final command = Command0<int>(() => gate.future);

    final run = command.execute();
    expect(command.running, isTrue);
    expect(command.result, isNull);

    gate.complete(const Ok(1));
    await run;
    expect(command.running, isFalse);
    expect(command.completed, isTrue);
    expect(command.result, const Ok(1));
  });

  test('ignores a second execute while running', () async {
    var calls = 0;
    final gate = Completer<Result<void>>();
    final command = Command0<void>(() {
      calls++;
      return gate.future;
    });

    final first = command.execute();
    final second = command.execute();
    gate.complete(const Ok(null));
    await Future.wait([first, second]);

    expect(calls, 1);
  });

  test('records a failure and clears it on demand', () async {
    final command = Command1<int, int>(
      (value) async => const Failure(NetworkError()),
    );

    await command.execute(3);
    expect(command.error, isTrue);
    expect(command.result?.errorOrNull, const NetworkError());

    command.clearResult();
    expect(command.result, isNull);
    expect(command.error, isFalse);
  });

  test('passes the argument to the action', () async {
    final command = Command1<int, int>((value) async => Ok(value * 2));
    await command.execute(21);
    expect(command.result?.valueOrNull, 42);
  });
}
