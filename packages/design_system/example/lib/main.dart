import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'pages/buttons_page.dart';
import 'pages/inputs_page.dart';
import 'pages/lists_page.dart';
import 'pages/states_page.dart';
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
        home: const GalleryHome(),
      ),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  static final _pages = <({String title, IconData icon, Widget page})>[
    (title: 'Tokens', icon: Icons.palette_outlined, page: const TokensPage()),
    (title: 'Botões', icon: Icons.smart_button, page: const ButtonsPage()),
    (title: 'Campos', icon: Icons.edit_outlined, page: const InputsPage()),
    (title: 'Listas', icon: Icons.list_alt, page: const ListsPage()),
    (title: 'Estados', icon: Icons.hourglass_empty, page: const StatesPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Galeria',
      actions: const [ThemeModeButton()],
      padded: false,
      body: ListView.separated(
        itemCount: _pages.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _pages[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => item.page)),
          );
        },
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
