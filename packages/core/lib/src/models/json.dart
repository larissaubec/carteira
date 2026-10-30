/// A decoded JSON object.
typedef Json = Map<String, Object?>;

/// Helpers to read JSON fields tolerantly.
///
/// The server always sends optional fields (with `null` when empty), but the
/// client must also accept a missing key, so every reader treats "absent" and
/// "null" the same way.
extension JsonReader on Json {
  String readString(String key) {
    final value = this[key];
    if (value is String) return value;
    throw FormatException('Field "$key" must be a string, got: $value');
  }

  String? readOptionalString(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    throw FormatException('Field "$key" must be a string or null, got: $value');
  }

  double readDouble(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    throw FormatException('Field "$key" must be a number, got: $value');
  }

  int readInt(String key, {int? fallback}) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null && fallback != null) return fallback;
    throw FormatException('Field "$key" must be an integer, got: $value');
  }

  bool readBool(String key, {bool? fallback}) {
    final value = this[key];
    if (value is bool) return value;
    if (value == null && fallback != null) return fallback;
    throw FormatException('Field "$key" must be a boolean, got: $value');
  }

  DateTime readDateTime(String key) {
    final value = this[key];
    if (value is String) return DateTime.parse(value).toUtc();
    throw FormatException(
      'Field "$key" must be an ISO 8601 string, got: $value',
    );
  }

  Json readObject(String key) {
    final value = this[key];
    if (value is Map<String, Object?>) return value;
    if (value is Map) return Map<String, Object?>.from(value);
    throw FormatException('Field "$key" must be an object, got: $value');
  }
}

/// Converts any decoded JSON map into a typed [Json].
Json asJson(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);
  throw FormatException('Expected a JSON object, got: $value');
}
