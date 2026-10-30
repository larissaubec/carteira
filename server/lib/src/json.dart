import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'api_error.dart';

/// Um objeto JSON já decodificado.
typedef JsonMap = Map<String, dynamic>;

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

/// Resposta JSON com o status informado.
Response jsonResponse(Object? body, {int status = 200}) {
  return Response(status, body: jsonEncode(body), headers: _jsonHeaders);
}

/// Resposta vazia `204 No Content`.
Response noContent() => Response(204);

/// Lê o corpo da requisição como objeto JSON.
///
/// Lança [ApiError.badRequest] se o corpo não for um objeto JSON válido.
Future<JsonMap> readJsonObject(Request request) async {
  final raw = await request.readAsString();
  if (raw.trim().isEmpty) {
    throw const ApiError.badRequest('Request body is empty');
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    throw const ApiError.badRequest();
  }
  if (decoded is! JsonMap) {
    throw const ApiError.badRequest('Request body must be a JSON object');
  }
  return decoded;
}

/// Formata uma data em ISO 8601 UTC sem milissegundos: `2026-09-06T14:32:00Z`.
String formatDate(DateTime date) {
  final utc = date.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${utc.year}-${two(utc.month)}-${two(utc.day)}'
      'T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}Z';
}

/// Chave `YYYY-MM` de uma data.
String monthKey(DateTime date) {
  final utc = date.toUtc();
  return '${utc.year}-${utc.month.toString().padLeft(2, '0')}';
}

/// Arredonda para duas casas decimais.
double roundMoney(num value) => (value * 100).round() / 100;
