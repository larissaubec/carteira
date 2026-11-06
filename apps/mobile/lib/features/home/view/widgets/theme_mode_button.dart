import 'package:flutter/material.dart';

import '../../../../l10n/strings.dart';

/// App bar button that flips between the light and the dark theme.
///
/// Starts from what is on screen (the system theme, at first), so the first
/// tap always changes something.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({required this.themeMode, super.key});

  final ValueNotifier<ThemeMode> themeMode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? Strings.themeLight : Strings.themeDark,
      icon: const Icon(Icons.brightness_6_outlined),
      onPressed: () =>
          themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
