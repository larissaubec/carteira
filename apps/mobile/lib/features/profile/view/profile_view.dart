import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/strings.dart';
import '../../../routing/routes.dart';
import '../view_model/profile_view_model.dart';

/// Profile tab: who is signed in and the way out.
///
/// Editing the name and photo comes in a later step.
class ProfileView extends StatefulWidget {
  const ProfileView({required this.viewModel, super.key});

  final ProfileViewModel viewModel;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    _bind(widget.viewModel);
  }

  @override
  void didUpdateWidget(ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.signOut.removeListener(_onSignOutChanged);
      _bind(widget.viewModel);
    }
  }

  @override
  void dispose() {
    widget.viewModel.signOut.removeListener(_onSignOutChanged);
    super.dispose();
  }

  void _bind(ProfileViewModel viewModel) {
    viewModel.signOut.addListener(_onSignOutChanged);
    if (!viewModel.load.running && !viewModel.load.completed) {
      viewModel.load.execute();
    }
  }

  /// Signed out (with or without the server agreeing): back to login.
  void _onSignOutChanged() {
    final command = widget.viewModel.signOut;
    if (!mounted || command.running || command.result == null) return;
    command.clearResult();
    context.go(Routes.login);
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.signOut),
        content: const Text(Strings.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(Strings.signOut),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await widget.viewModel.signOut.execute();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return AppScaffold(
      title: Strings.profileTitle,
      body: ListenableBuilder(
        listenable: Listenable.merge([
          viewModel,
          viewModel.load,
          viewModel.signOut,
        ]),
        builder: (context, _) {
          final user = viewModel.user;
          if (user == null) {
            final error = viewModel.load.result?.errorOrNull;
            return error == null
                ? const StateView.loading()
                : StateView.error(
                    message: error.message,
                    onRetry: viewModel.load.execute,
                  );
          }
          return ListView(
            children: [
              const Gap.xl(),
              _Header(user: user),
              const Gap.xxl(),
              AppButton.secondary(
                label: Strings.signOut,
                icon: Icons.logout,
                isLoading: viewModel.signOut.running,
                onPressed: _confirmSignOut,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = context.semanticColors.muted;
    return Column(
      children: [
        AppAvatar(name: user.name, imageUrl: user.avatarUrl, size: 96),
        const Gap.lg(),
        Text(user.name, style: theme.textTheme.titleLarge),
        const Gap.xs(),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const Gap.xs(),
        Text(
          '${Strings.memberSince} ${formatDate(user.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}
