import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// Scaffold with the app's standard chrome: flat app bar, horizontal screen
/// padding around [body] (unless [padded] is false, for full-bleed lists).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.floatingActionButton,
    this.padded = true,
    this.showAppBar = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  /// Rendered below the body, e.g. a [NavigationBar].
  final Widget? bottom;
  final Widget? floatingActionButton;
  final bool padded;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title == null ? null : Text(title!),
              actions: actions,
              leading: leading,
            )
          : null,
      body: SafeArea(
        child: padded
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                child: body,
              )
            : body,
      ),
      bottomNavigationBar: bottom,
      floatingActionButton: floatingActionButton,
    );
  }
}
