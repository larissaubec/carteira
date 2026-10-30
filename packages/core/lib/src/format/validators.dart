/// Form validators. Return `null` when valid, a message in Portuguese
/// otherwise, which is the shape Flutter's `FormField.validator` expects.
library;

final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Informe o e-mail.';
  if (!_emailPattern.hasMatch(email)) return 'E-mail inválido.';
  return null;
}

String? validatePassword(String? value, {int minLength = 6}) {
  final password = value ?? '';
  if (password.isEmpty) return 'Informe a senha.';
  if (password.length < minLength) {
    return 'A senha precisa ter pelo menos $minLength caracteres.';
  }
  return null;
}

String? validateRequired(String? value, {String field = 'Este campo'}) {
  if (value == null || value.trim().isEmpty) return '$field é obrigatório.';
  return null;
}

/// Accepts `1234.56` and `1.234,56`.
String? validateAmount(String? value) {
  final amount = parseAmount(value);
  if (amount == null) return 'Informe um valor numérico.';
  if (amount <= 0) return 'O valor precisa ser maior que zero.';
  return null;
}

/// Parses user input in either `1234.56` or `1.234,56` form.
double? parseAmount(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final normalized = raw.contains(',')
      ? raw.replaceAll('.', '').replaceAll(',', '.')
      : raw;
  return double.tryParse(normalized);
}
