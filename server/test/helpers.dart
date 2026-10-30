import 'dart:convert';
import 'dart:io';

import 'package:carteira_server/carteira_server.dart';
import 'package:shelf/shelf.dart';

typedef JsonMap = Map<String, dynamic>;

/// Seed real do projeto, carregado uma vez por arquivo de teste.
Seed loadSeed() => Seed.fromFile(File('seed.json'));

/// Cliente de teste que fala com o handler em processo, sem sockets.
class TestApi {
  TestApi({Seed? seed, LatencyConfig latency = LatencyConfig.none})
    : seed = seed ?? loadSeed() {
    store = SessionStore(this.seed);
    handler = createHandler(seed: this.seed, latency: latency, store: store);
  }

  final Seed seed;
  late final SessionStore store;
  late final Handler handler;

  Future<Response> send(
    String method,
    String path, {
    Object? body,
    String? token,
    Map<String, String> headers = const {},
  }) {
    final request = Request(
      method,
      Uri.parse('http://localhost$path'),
      body: body == null ? null : jsonEncode(body),
      headers: {
        if (body != null) 'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
        ...headers,
      },
    );
    return Future.value(handler(request));
  }

  Future<String> login({
    String email = 'ana@carteira.dev',
    String password = '123456',
  }) async {
    final response = await send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final json = await decode(response);
    return json['token'] as String;
  }
}

Future<JsonMap> decode(Response response) async {
  return jsonDecode(await response.readAsString()) as JsonMap;
}

Future<String> errorCode(Response response) async {
  final json = await decode(response);
  return (json['error'] as JsonMap)['code'] as String;
}

Future<JsonMap> errorFields(Response response) async {
  final json = await decode(response);
  return (json['error'] as JsonMap)['fields'] as JsonMap;
}

JsonMap sampleTransaction({String type = 'expense'}) => {
  'type': type,
  'amount': 42.5,
  'description': 'Café da tarde',
  'category': 'Alimentação',
  'date': '2026-09-07T16:00:00Z',
  'note': null,
  'account': 'Nubank',
  'toAccount': type == 'transfer' ? 'Itaú' : null,
};
