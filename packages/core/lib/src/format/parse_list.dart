import '../models/json.dart';

/// Turns a decoded JSON list into typed objects.
///
/// Generic on purpose: the same function parses users or transactions, as
/// long as each has a `fromJson`.
List<T> parseList<T>(Object? json, T Function(Json) fromJson) {
  if (json == null) return const [];
  if (json is! List) throw FormatException('Expected a JSON list, got: $json');
  return [for (final item in json) fromJson(asJson(item))];
}
