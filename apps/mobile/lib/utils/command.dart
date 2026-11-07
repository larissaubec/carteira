import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

/// An action the UI can trigger, with its state exposed for binding.
///
/// A ViewModel exposes one [Command] per user action (sign in, load, load
/// more). The view listens to it to show a spinner while [running], an error
/// when the [result] is a [Failure], or to navigate when it [completed].
/// Calling it again while it runs is ignored, so a double tap on a button
/// does not fire two requests.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;

  /// True while the action is in flight.
  bool get running => _running;

  /// Outcome of the last run, or null before the first run or after
  /// [clearResult].
  Result<T>? get result => _result;

  /// The last run finished with [Ok].
  bool get completed => _result is Ok<T>;

  /// The last run finished with [Failure].
  bool get error => _result is Failure<T>;

  /// Forgets the last outcome, e.g. after the view showed the error.
  void clearResult() {
    if (_result == null) return;
    _result = null;
    notifyListeners();
  }

  Future<void> _run(Future<Result<T>> Function() action) async {
    if (_running) return;
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// A [Command] without arguments.
class Command0<T> extends Command<T> {
  Command0(this._action);

  final Future<Result<T>> Function() _action;

  Future<void> execute() => _run(_action);
}

/// A [Command] that takes one argument.
class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final Future<Result<T>> Function(A argument) _action;

  Future<void> execute(A argument) => _run(() => _action(argument));
}
