/// Groups [items] by the key returned by [keyOf], preserving order of first
/// appearance.
Map<K, List<T>> groupBy<K, T>(Iterable<T> items, K Function(T item) keyOf) {
  final groups = <K, List<T>>{};
  for (final item in items) {
    groups.putIfAbsent(keyOf(item), () => []).add(item);
  }
  return groups;
}
