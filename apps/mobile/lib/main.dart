import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'features/auth/view/login_view.dart';
import 'l10n/strings.dart';

void main() => runApp(const CarteiraApp());

/// Root of the widget tree. [MaterialApp] installs the theme, the
/// navigator, the text direction and the localizations that every widget
/// below reads through its [BuildContext].
class CarteiraApp extends StatelessWidget {
  const CarteiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      debugShowCheckedModeBanner: false,
      home: const LoginView(),
    );
  }
}
