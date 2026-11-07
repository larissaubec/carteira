import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/dependencies.dart';
import 'l10n/strings.dart';
import 'routing/router.dart';

/// Builds the dependencies (and restores the stored session) before the
/// first frame, so the app opens straight on the right screen.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(CarteiraApp(dependencies: dependencies));
}

/// Root of the widget tree. [MaterialApp] installs the theme, the
/// navigator, the text direction and the localizations that every widget
/// below reads through its [BuildContext].
class CarteiraApp extends StatefulWidget {
  const CarteiraApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<CarteiraApp> createState() => _CarteiraAppState();
}

class _CarteiraAppState extends State<CarteiraApp> {
  // Created once: rebuilding the app (a theme change) keeps the navigation.
  late final GoRouter _router = createRouter(widget.dependencies);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: widget.dependencies.themeMode,
      builder: (context, themeMode, _) => MaterialApp.router(
        title: Strings.appName,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
