import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../api_error.dart';
import '../json.dart';
import '../middleware/auth.dart';
import '../validation.dart';

const _defaultPageSize = 20;

void registerTransactionRoutes(Router router) {
  router.get('/transactions', (Request request) {
    final query = request.url.queryParameters;
    final errors = validateListQuery(query);
    if (errors.isNotEmpty) {
      throw ApiError.validation('Invalid query', errors);
    }
    final month = query['month'];
    final type = query['type'];
    final search = query['q']?.trim().toLowerCase();
    final page = int.tryParse(query['page'] ?? '') ?? 1;
    final pageSize = int.tryParse(query['pageSize'] ?? '') ?? _defaultPageSize;

    final filtered =
        request.session.transactions.where((transaction) {
          if (month != null &&
              !(transaction['date'] as String).startsWith(month)) {
            return false;
          }
          if (type != null && transaction['type'] != type) {
            return false;
          }
          if (search != null && search.isNotEmpty) {
            final description = (transaction['description'] as String)
                .toLowerCase();
            if (!description.contains(search)) {
              return false;
            }
          }
          return true;
        }).toList()..sort(
          (a, b) => (b['date'] as String).compareTo(a['date'] as String),
        );

    final start = (page - 1) * pageSize;
    final items = start >= filtered.length
        ? const <JsonMap>[]
        : filtered.sublist(start, (start + pageSize).clamp(0, filtered.length));
    return jsonResponse({
      'items': items,
      'page': page,
      'pageSize': pageSize,
      'total': filtered.length,
    });
  });

  router.get('/transactions/<id>', (Request request, String id) {
    return jsonResponse(_find(request, id));
  });

  router.post('/transactions', (Request request) async {
    final body = await readJsonObject(request);
    final errors = validateTransaction(body);
    if (errors.isNotEmpty) {
      throw ApiError.validation('Invalid transaction', errors);
    }
    final session = request.session;
    final transaction = normalizeTransaction(
      body,
      id: session.nextTransactionId(),
    );
    session.transactions.add(transaction);
    return jsonResponse(transaction, status: 201);
  });

  router.put('/transactions/<id>', (Request request, String id) async {
    final body = await readJsonObject(request);
    final errors = validateTransaction(body);
    if (errors.isNotEmpty) {
      throw ApiError.validation('Invalid transaction', errors);
    }
    final session = request.session;
    final index = session.transactions.indexOf(_find(request, id));
    final updated = normalizeTransaction(body, id: id);
    session.transactions[index] = updated;
    return jsonResponse(updated);
  });

  router.delete('/transactions/<id>', (Request request, String id) {
    final session = request.session;
    session.transactions.remove(_find(request, id));
    return noContent();
  });
}

JsonMap _find(Request request, String id) {
  final transaction = request.session.findTransaction(id);
  if (transaction == null) {
    throw ApiError.notFound('Transaction $id not found');
  }
  return transaction;
}
