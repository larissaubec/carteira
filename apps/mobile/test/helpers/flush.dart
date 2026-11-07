/// Lets pending timers and futures with zero delay run, e.g. the search
/// debounce and the in-memory repositories.
Future<void> flush() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
