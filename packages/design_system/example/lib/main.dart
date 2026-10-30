import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'pages/tokens_page.dart';

void main() => runApp(const GalleryApp());

/// Theme mode chosen in the gallery. A [ValueNotifier] is enough: one value,
/// one listener, no package.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Galeria',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: const TokensPage(),
      ),
    );
  }
}

/// Cycles system -> light -> dark.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        final icon = switch (mode) {
          ThemeMode.system => Icons.brightness_auto,
          ThemeMode.light => Icons.light_mode,
          ThemeMode.dark => Icons.dark_mode,
        };
        return IconButton(
          tooltip: 'Tema: ${mode.name}',
          icon: Icon(icon),
          onPressed: () {
            themeMode.value = switch (mode) {
              ThemeMode.system => ThemeMode.light,
              ThemeMode.light => ThemeMode.dark,
              ThemeMode.dark => ThemeMode.system,
            };
          },
        );
      },
    );
  }
}
