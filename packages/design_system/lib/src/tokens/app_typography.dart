import 'package:flutter/material.dart';

/// Type scale built on the platform font.
///
/// No external font is bundled: the course keeps the dependency list short
/// and the platform face is the correct default for a finance app.
abstract final class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.8,
  );

  /// Money figures use tabular digits so columns line up.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );
}
