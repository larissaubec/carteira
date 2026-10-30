import 'package:flutter/material.dart';

/// Raw color palette of the Carteira design system.
///
/// Two palettes, one per brightness, with the same field names so the theme
/// can be built from either one. Widgets never read these directly; they go
/// through [ThemeData] or `AppSemanticColors`.
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.error,
    required this.onError,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color outline;
  final Color income;
  final Color expense;
  final Color transfer;
  final Color warning;
  final Color error;
  final Color onError;
}

/// The two official palettes.
abstract final class AppColors {
  /// Light palette: warm-grey grounds with a deep teal-blue accent.
  static const AppColorPalette light = AppColorPalette(
    primary: Color(0xFF0F6E8A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDDEEF4),
    onPrimaryContainer: Color(0xFF07333F),
    background: Color(0xFFF7F6F3),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEFEDE8),
    onSurface: Color(0xFF1E2229),
    onSurfaceMuted: Color(0xFF6B7078),
    outline: Color(0xFFD9D6D0),
    income: Color(0xFF2E7D5B),
    expense: Color(0xFFB4483A),
    transfer: Color(0xFF6B7480),
    warning: Color(0xFFB26A1B),
    error: Color(0xFFB4483A),
    onError: Color(0xFFFFFFFF),
  );

  /// Dark palette: the same hues lifted so they read on dark grounds.
  static const AppColorPalette dark = AppColorPalette(
    primary: Color(0xFF5FB3CC),
    onPrimary: Color(0xFF07333F),
    primaryContainer: Color(0xFF15414E),
    onPrimaryContainer: Color(0xFFCDE8F0),
    background: Color(0xFF14171A),
    surface: Color(0xFF1C2126),
    surfaceVariant: Color(0xFF262C33),
    onSurface: Color(0xFFE8E9EB),
    onSurfaceMuted: Color(0xFF9AA1AA),
    outline: Color(0xFF373E46),
    income: Color(0xFF5FBF93),
    expense: Color(0xFFE07A6C),
    transfer: Color(0xFF9AA4B0),
    warning: Color(0xFFE0A24A),
    error: Color(0xFFE07A6C),
    onError: Color(0xFF2A0F0B),
  );
}
