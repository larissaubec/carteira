import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

/// Wraps [child] in a MaterialApp with the app theme, as every screen does.
Widget wrap(Widget child, {bool dark = false}) {
  return MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}
