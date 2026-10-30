# carteira_design_system

Tokens e tema do app Carteira. Puro Flutter, sem dependência do
`carteira_core`. Os componentes chegam no capítulo 7.

```sh
flutter test                 # testes do tema
cd example && flutter run    # galeria de tokens
```

Estrutura:

- `lib/src/tokens/` — `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`, `AppDurations`
- `lib/src/theme/` — `AppTheme.light()`, `AppTheme.dark()`, `AppSemanticColors`
