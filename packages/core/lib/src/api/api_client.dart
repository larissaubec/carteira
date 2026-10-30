import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/json.dart';
import '../result/app_error.dart';
import '../result/result.dart';

/// Thin HTTP client that speaks the API contract.
///
/// It knows three things: where the server is, which token to send and how to
/// turn an HTTP response into a [Result]. It knows nothing about transactions
/// or users; that is the job of the remote repositories.
class ApiClient {
  ApiClient({
    required String baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _baseUrl = Uri.parse(baseUrl),
       _client = client ?? http.Client();

  final Uri _baseUrl;
  final http.Client _client;
  final Duration timeout;

  /// Bearer token sent on every request when set.
  String? token;

  Future<Result<Object?>> get(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) => _send('GET', path, query: query, headers: headers);

  Future<Result<Object?>> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => _send('POST', path, body: body, headers: headers);

  Future<Result<Object?>> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => _send('PUT', path, body: body, headers: headers);

  Future<Result<Object?>> patch(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => _send('PATCH', path, body: body, headers: headers);

  Future<Result<Object?>> delete(String path, {Map<String, String>? headers}) =>
      _send('DELETE', path, headers: headers);

  void close() => _client.close();

  Future<Result<Object?>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _baseUrl.replace(
      path: '${_baseUrl.path}$path'.replaceAll('//', '/'),
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    final request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (headers != null) request.headers.addAll(headers);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    try {
      final streamed = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } on TimeoutException {
      return const Failure(TimeoutError());
    } on SocketException {
      return const Failure(NetworkError());
    } on http.ClientException {
      return const Failure(NetworkError());
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }

  Result<Object?> _decode(http.Response response) {
    final status = response.statusCode;
    final text = utf8.decode(response.bodyBytes);
    Object? decoded;
    if (text.isNotEmpty) {
      try {
        decoded = jsonDecode(text);
      } on FormatException catch (e) {
        return Failure(UnknownError(e));
      }
    }
    if (status >= 200 && status < 300) return Ok(decoded);
    return Failure(mapError(status, decoded));
  }

  /// Maps a status code and the contract's error body to an [AppError].
  static AppError mapError(int status, Object? body) {
    Json? error;
    if (body is Map) {
      final raw = body['error'];
      if (raw is Map) error = Map<String, Object?>.from(raw);
    }
    final code = error?['code'] as String?;
    final message = error?['message'] as String?;

    switch (status) {
      case 401:
        return UnauthorizedError(
          expired: code == 'token_expired',
          invalidCredentials: code == 'invalid_credentials',
        );
      case 404:
        return NotFoundError(message);
      case 422:
        final rawFields = error?['fields'];
        final fields = <String, String>{
          if (rawFields is Map)
            for (final entry in rawFields.entries)
              '${entry.key}': '${entry.value}',
        };
        return ValidationError(fields, detail: message);
      case >= 500:
        return ServerError(status);
      default:
        return UnknownError(
          'HTTP $status ${code ?? ''} ${message ?? ''}'.trim(),
        );
    }
  }
}
