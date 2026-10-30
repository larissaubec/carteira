import 'dart:io';

import 'package:shelf/shelf.dart';

import '../api_error.dart';

/// Converte [ApiError] na resposta padrão e qualquer outra exceção em 500.
Middleware errorHandlerMiddleware() {
  return (inner) {
    return (request) async {
      try {
        return await inner(request);
      } on ApiError catch (error) {
        return error.toResponse();
      } on HijackException {
        rethrow;
      } catch (error, stackTrace) {
        stderr.writeln('Unhandled error: $error\n$stackTrace');
        return const ApiError.internal().toResponse();
      }
    };
  };
}
