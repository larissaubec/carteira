import 'json.dart';

const transactionTypes = {'income', 'expense', 'transfer'};

final _monthPattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

bool isValidMonth(String value) => _monthPattern.hasMatch(value);

/// Erros de campo de uma transaction. Vazio quando válida.
Map<String, String> validateTransaction(JsonMap json) {
  final errors = <String, String>{};

  final type = json['type'];
  if (type is! String || !transactionTypes.contains(type)) {
    errors['type'] = 'must be one of ${transactionTypes.join(', ')}';
  }

  final amount = json['amount'];
  if (amount is! num) {
    errors['amount'] = 'must be a number';
  } else if (amount <= 0) {
    errors['amount'] = 'must be greater than zero';
  }

  final description = json['description'];
  if (description is! String || description.trim().isEmpty) {
    errors['description'] = 'must not be empty';
  }

  final date = json['date'];
  if (date is! String || DateTime.tryParse(date) == null) {
    errors['date'] = 'must be an ISO 8601 date';
  }

  final account = json['account'];
  if (account is! String || account.trim().isEmpty) {
    errors['account'] = 'must not be empty';
  }

  final category = json['category'];
  if (category != null && category is! String) {
    errors['category'] = 'must be a string or null';
  }

  final note = json['note'];
  if (note != null && note is! String) {
    errors['note'] = 'must be a string or null';
  }

  final toAccount = json['toAccount'];
  if (type == 'transfer') {
    if (toAccount is! String || toAccount.trim().isEmpty) {
      errors['toAccount'] = 'is required for transfers';
    }
  } else if (toAccount != null && toAccount is! String) {
    errors['toAccount'] = 'must be a string or null';
  }

  return errors;
}

/// Monta a transaction canônica a partir de um corpo já validado.
JsonMap normalizeTransaction(JsonMap json, {required String id}) {
  final type = json['type'] as String;
  final category = json['category'] as String?;
  final note = json['note'] as String?;
  return {
    'id': id,
    'type': type,
    'amount': roundMoney(json['amount'] as num),
    'description': (json['description'] as String).trim(),
    'category': category == null || category.trim().isEmpty
        ? null
        : category.trim(),
    'date': formatDate(DateTime.parse(json['date'] as String)),
    'note': note == null || note.trim().isEmpty ? null : note.trim(),
    'account': (json['account'] as String).trim(),
    'toAccount': type == 'transfer'
        ? (json['toAccount'] as String).trim()
        : null,
  };
}

/// Erros de campo de `PUT /me`.
Map<String, String> validateProfile(JsonMap json) {
  final errors = <String, String>{};
  final name = json['name'];
  if (name is! String || name.trim().isEmpty) {
    errors['name'] = 'must not be empty';
  }
  final avatarUrl = json['avatarUrl'];
  if (avatarUrl != null && avatarUrl is! String) {
    errors['avatarUrl'] = 'must be a string or null';
  }
  return errors;
}

/// Erros dos parâmetros de `GET /transactions`.
Map<String, String> validateListQuery(Map<String, String> query) {
  final errors = <String, String>{};
  final month = query['month'];
  if (month != null && !isValidMonth(month)) {
    errors['month'] = 'must be in the format YYYY-MM';
  }
  final type = query['type'];
  if (type != null && !transactionTypes.contains(type)) {
    errors['type'] = 'must be one of ${transactionTypes.join(', ')}';
  }
  final page = query['page'];
  if (page != null && ((int.tryParse(page) ?? 0) < 1)) {
    errors['page'] = 'must be an integer greater than zero';
  }
  final pageSize = query['pageSize'];
  if (pageSize != null) {
    final size = int.tryParse(pageSize) ?? 0;
    if (size < 1 || size > 100) {
      errors['pageSize'] = 'must be an integer between 1 and 100';
    }
  }
  return errors;
}
