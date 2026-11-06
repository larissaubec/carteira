import 'package:dio/dio.dart';

import '../models/json.dart';
import '../result/app_error.dart';
import '../result/result.dart';

/// Thin HTTP client that speaks the API contract.
///
/// `dio` does the transport: base URL, timeouts and JSON in both directions.
/// This class adds what is ours: the token on every request and the mapping of
/// every outcome to a [Result]. It knows nothing about transactions or users;
/// that is the job of the remote repositories.
class ApiClient {
  /// [headers] go on every request; the demos use them to send `X-Fail` and
  /// `X-Delay-Ms`. [adapter] replaces the network in tests.
  ApiClient({
    required String baseUrl,
    Duration timeout = const Duration(seconds: 10),
    Map<String, String> headers = const {},
    HttpClientAdapter? adapter,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: timeout,
           receiveTimeout: timeout,
           headers: {'Accept': 'application/json', ...headers},
         ),
       ) {
    if (adapter != null) _dio.httpClientAdapter = adapter;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  /// Bearer token sent on every request when set.
  String? token;

  Future<Result<Object?>> get(String path, {Map<String, String>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<Result<Object?>> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body));

  Future<Result<Object?>> put(String path, {Object? body}) =>
      _send(() => _dio.put(path, data: body));

  Future<Result<Object?>> delete(String path) => _send(() => _dio.delete(path));

  void close() => _dio.close();

  /// A 2xx becomes [Ok] with the decoded body; everything else, including
  /// the exceptions `dio` throws, becomes [Failure].
  Future<Result<Object?>> _send(Future<Response<Object?>> Function() request) =>
      Result.guard(() async {
        final data = (await request()).data;
        return data == '' ? null : data;
      }, onError: fromException);

  /// Maps what `dio` throws to an [AppError].
  static AppError fromException(Object error) => switch (error) {
    DioException(
      type: DioExceptionType.badResponse,
      response: Response(:final statusCode?, :final data),
    ) =>
      mapError(statusCode, data),
    DioException(
      type: DioExceptionType.connectionTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout,
    ) =>
      const TimeoutError(),
    DioException(type: DioExceptionType.connectionError) =>
      const NetworkError(),
    _ => UnknownError(error),
  };

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
