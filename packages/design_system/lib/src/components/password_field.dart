import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'app_text_field.dart';

/// Password strength as computed by [PasswordField.strengthOf].
enum PasswordStrength { empty, weak, fair, strong }

/// Password input with a show/hide toggle and an optional strength bar.
///
/// Stateful on purpose: whether the text is hidden is UI state that belongs
/// to the widget, not to the screen's ViewModel.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Senha',
    this.errorText,
    this.showStrength = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String label;
  final String? errorText;

  /// Show a strength meter under the field.
  final bool showStrength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool enabled;

  /// Length plus character classes (lower, upper, digit, symbol).
  static PasswordStrength strengthOf(String value) {
    if (value.isEmpty) return PasswordStrength.empty;
    var classes = 0;
    if (value.contains(RegExp('[a-z]'))) classes++;
    if (value.contains(RegExp('[A-Z]'))) classes++;
    if (value.contains(RegExp('[0-9]'))) classes++;
    if (value.contains(RegExp(r'[^A-Za-z0-9]'))) classes++;
    final score =
        classes + (value.length >= 8 ? 1 : 0) + (value.length >= 12 ? 1 : 0);
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    return PasswordStrength.strong;
  }

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;
  late TextEditingController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onTextChanged);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.showStrength) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final field = AppTextField(
      label: widget.label,
      controller: _controller,
      errorText: widget.errorText,
      obscureText: _obscure,
      enabled: widget.enabled,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      prefixIcon: Icons.lock_outline,
      suffix: IconButton(
        key: const Key('password_toggle'),
        tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );

    if (!widget.showStrength) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        const SizedBox(height: AppSpacing.sm),
        _StrengthBar(strength: PasswordField.strengthOf(_controller.text)),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final scheme = Theme.of(context).colorScheme;
    final (fill, color, label) = switch (strength) {
      PasswordStrength.empty => (0.0, scheme.outline, ''),
      PasswordStrength.weak => (1 / 3, semantic.expense, 'Fraca'),
      PasswordStrength.fair => (2 / 3, semantic.warning, 'Razoável'),
      PasswordStrength.strong => (1.0, semantic.income, 'Forte'),
    };
    return Semantics(
      label: label.isEmpty ? 'Força da senha' : 'Força da senha: $label',
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 4,
                color: color,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
