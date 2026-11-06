import 'package:carteira_app/config/dependencies.dart';
import 'package:carteira_app/main.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late InMemorySessionStorage storage;

  /// The app with in-memory repositories, after restoring [storage] just
  /// like `main` does.
  Future<AppDependencies> pumpApp(WidgetTester tester) async {
    final dependencies = AppDependencies.inMemory(
      storage: storage,
      delay: Duration.zero,
    );
    await tester.runAsync(() => dependencies.authRepository.restore());
    await tester.pumpWidget(CarteiraApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> signIn(WidgetTester tester, String password) async {
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'ana@carteira.dev',
    );
    await tester.enterText(find.byKey(const Key('login_password')), password);
    await tester.tap(find.widgetWithText(AppButton, 'Entrar'));
    await tester.pumpAndSettle();
  }

  setUp(() => storage = InMemorySessionStorage());

  testWidgets('login screen shows the brand, two fields and a button', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Carteira'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(AppButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('validates the form before calling the API', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(AppButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);
  });

  testWidgets('wrong password shows the error on the login screen', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester, 'errada');

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.text('Saldo do mês'), findsNothing);
    expect(await storage.read(), isNull);
  });

  testWidgets('signs in, stores the session and opens the home screen', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester, '123456');

    expect(find.text('Saldo do mês'), findsOneWidget);
    expect(find.text('Lançamentos'), findsOneWidget);
    expect(await storage.read(), isNotNull);
  });

  testWidgets('opens straight on the home screen with a stored session', (
    tester,
  ) async {
    await storage.write(sampleSession);
    await pumpApp(tester);

    expect(find.text('Saldo do mês'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Entrar'), findsNothing);
  });

  testWidgets('signing out goes back to login and forgets the session', (
    tester,
  ) async {
    await storage.write(sampleSession);
    await pumpApp(tester);

    await tester.tap(find.text('Perfil').last);
    await tester.pumpAndSettle();
    expect(find.text('Ana Ribeiro'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Sair da conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sair da conta'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'Entrar'), findsOneWidget);
    expect(await storage.read(), isNull);
  });
}
