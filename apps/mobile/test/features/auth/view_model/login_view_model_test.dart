import 'package:carteira_app/features/auth/view_model/login_view_model.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySessionStorage storage;
  late InMemoryAuthRepository auth;
  late LoginViewModel viewModel;

  setUp(() {
    storage = InMemorySessionStorage();
    auth = InMemoryAuthRepository(storage: storage);
    viewModel = LoginViewModel(authRepository: auth);
  });

  test('signs in and stores the session', () async {
    await viewModel.submit(email: ' ana@carteira.dev ', password: '123456');

    expect(viewModel.login.completed, isTrue);
    expect(viewModel.errorMessage, isNull);
    expect(auth.currentSession?.user.email, 'ana@carteira.dev');
    expect(await storage.read(), auth.currentSession);
  });

  test('shows the message of the error when the password is wrong', () async {
    await viewModel.submit(email: 'ana@carteira.dev', password: 'errada');

    expect(viewModel.login.error, isTrue);
    expect(viewModel.errorMessage, 'E-mail ou senha incorretos.');
    expect(await storage.read(), isNull);
  });

  test('validates locally and sends no request for an invalid form', () async {
    await viewModel.submit(email: 'ana', password: '');

    expect(viewModel.emailError, 'E-mail inválido.');
    expect(viewModel.passwordError, 'Informe a senha.');
    expect(viewModel.login.result, isNull);
    expect(auth.currentSession, isNull);
  });

  test('typing again hides the previous messages', () async {
    await viewModel.submit(email: 'ana@carteira.dev', password: 'errada');
    expect(viewModel.errorMessage, isNotNull);

    viewModel.onEdited();
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.emailError, isNull);
  });
}
