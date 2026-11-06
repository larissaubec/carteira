import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class InputsPage extends StatelessWidget {
  const InputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Campos',
      actions: const [ThemeModeButton()],
      body: ListView(
        children: [
          const SectionHeader(title: 'AppTextField'),
          const AppTextField(
            label: 'E-mail',
            hint: 'voce@exemplo.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
          ),
          const Gap.md(),
          const AppTextField(
            label: 'Com erro',
            errorText: 'Informe um e-mail válido',
          ),
          const Gap.md(),
          const AppTextField(
            label: 'Com ajuda',
            helperText: 'Opcional',
            maxLines: 3,
          ),
          const Gap.md(),
          const AppTextField(label: 'Desabilitado', enabled: false),
          const SectionHeader(title: 'PasswordField'),
          const PasswordField(),
          const Gap.md(),
          const PasswordField(label: 'Nova senha', showStrength: true),
          const SectionHeader(title: 'AppAvatar'),
          const Row(
            children: [
              AppAvatar(name: 'Ana Ribeiro', size: 32),
              Gap.sm(),
              AppAvatar(name: 'Ana Ribeiro'),
              Gap.sm(),
              AppAvatar(name: 'Bruno Costa', size: 56),
              Gap.sm(),
              AppAvatar(
                name: 'Ana Ribeiro',
                size: 72,
                imageUrl: 'https://i.pravatar.cc/150?img=47',
              ),
            ],
          ),
          const Gap.xxl(),
        ],
      ),
    );
  }
}
