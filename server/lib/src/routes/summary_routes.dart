import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../api_error.dart';
import '../json.dart';
import '../middleware/auth.dart';
import '../validation.dart';

/// Totais do mês. Transferências não entram no cálculo.
void registerSummaryRoutes(Router router) {
  router.get('/summary', (Request request) {
    final month =
        request.url.queryParameters['month'] ?? monthKey(DateTime.now());
    if (!isValidMonth(month)) {
      throw const ApiError.validation('Invalid query', {
        'month': 'must be in the format YYYY-MM',
      });
    }
    var income = 0.0;
    var expense = 0.0;
    for (final transaction in request.session.transactions) {
      if (!(transaction['date'] as String).startsWith(month)) {
        continue;
      }
      final amount = (transaction['amount'] as num).toDouble();
      switch (transaction['type']) {
        case 'income':
          income += amount;
        case 'expense':
          expense += amount;
      }
    }
    income = roundMoney(income);
    expense = roundMoney(expense);
    return jsonResponse({
      'month': month,
      'income': income,
      'expense': expense,
      'balance': roundMoney(income - expense),
    });
  });
}
