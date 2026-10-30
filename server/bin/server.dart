import 'dart:io';

import 'package:carteira_server/carteira_server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future<void> main(List<String> args) async {
  final env = Platform.environment;
  final port = int.tryParse(env['PORT'] ?? '') ?? 8080;
  final seedFile = _resolveSeedFile(env['SEED_FILE']);
  if (!seedFile.existsSync()) {
    stderr.writeln('seed.json not found at ${seedFile.path}');
    exitCode = 1;
    return;
  }

  final seed = Seed.fromFile(seedFile);
  final latency = LatencyConfig.fromEnvironment(env);
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(createHandler(seed: seed, latency: latency));

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  stdout
    ..writeln('Carteira API v$serverVersion')
    ..writeln('Listening on http://localhost:${server.port}')
    ..writeln('Seed: ${seedFile.path} (${seed.users.length} users)')
    ..writeln('Latency: ${latency.minMs}-${latency.maxMs} ms');
}

/// `SEED_FILE`, senão `seed.json` na pasta atual, senão ao lado do binário.
File _resolveSeedFile(String? fromEnv) {
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return File(fromEnv);
  }
  final local = File('seed.json');
  if (local.existsSync()) {
    return local;
  }
  final executableDir = File(Platform.resolvedExecutable).parent;
  return File('${executableDir.path}/seed.json');
}
