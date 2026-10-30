import 'package:carteira_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen shows the brand, two fields and a button', (
    tester,
  ) async {
    await tester.pumpWidget(const CarteiraApp());
    expect(find.text('Carteira'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });
}
