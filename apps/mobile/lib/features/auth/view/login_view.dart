import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/strings.dart';
import '../../../routing/routes.dart';
import '../view_model/login_view_model.dart';

/// Login screen.
///
/// Read it from the outside in: a [Scaffold] gives the page its background
/// and safe areas; a [ListView] lets the content scroll when the keyboard
/// shows up; the children stack vertically with explicit spacing.
///
/// The view only draws and forwards input. Validation, the request and the
/// stored session belong to the [LoginViewModel].
class LoginView extends StatefulWidget {
  const LoginView({required this.viewModel, super.key});

  final LoginViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onLoginChanged);
  }

  @override
  void didUpdateWidget(LoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.login.removeListener(_onLoginChanged);
      widget.viewModel.login.addListener(_onLoginChanged);
    }
  }

  @override
  void dispose() {
    widget.viewModel.login.removeListener(_onLoginChanged);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Signed in: the session is already stored, go to the home screen.
  void _onLoginChanged() {
    if (!mounted || !widget.viewModel.login.completed) return;
    widget.viewModel.login.clearResult();
    context.go(Routes.home);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.viewModel.submit(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = widget.viewModel;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([viewModel, viewModel.login]),
          builder: (context, _) {
            final running = viewModel.login.running;
            final errorMessage = viewModel.errorMessage;
            return AutofillGroup(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.xxxl,
                ),
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: AppSpacing.xxxl,
                    color: theme.colorScheme.primary,
                  ),
                  const Gap.lg(),
                  Text(
                    Strings.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const Gap.xs(),
                  Text(
                    Strings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.semanticColors.muted,
                    ),
                  ),
                  const Gap.xxl(),
                  AppTextField(
                    key: const Key('login_email'),
                    label: Strings.email,
                    controller: _email,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    errorText: viewModel.emailError,
                    enabled: !running,
                    onChanged: (_) => viewModel.onEdited(),
                  ),
                  const Gap.lg(),
                  PasswordField(
                    key: const Key('login_password'),
                    label: Strings.password,
                    controller: _password,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    errorText: viewModel.passwordError,
                    enabled: !running,
                    onChanged: (_) => viewModel.onEdited(),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (errorMessage != null) ...[
                    const Gap.lg(),
                    _ErrorBanner(message: errorMessage),
                  ],
                  const Gap.xl(),
                  AppButton(
                    label: Strings.signIn,
                    isLoading: running,
                    onPressed: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Why the sign in failed, in the words of the [AppError] message.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = context.semanticColors.expense;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: color),
              const Gap.sm(),
              Expanded(
                child: Text(
                  message,
                  key: const Key('login_error'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
