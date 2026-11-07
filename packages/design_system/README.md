# carteira_design_system

Tokens, tema e componentes visuais do app Carteira. Puro Flutter, sem
dependência do `carteira_core`: dinheiro e datas chegam já formatados como
`String`.

```sh
flutter test                 # testes de widget
cd example && flutter run    # galeria de componentes
```

Estrutura:

- `lib/src/tokens/` — `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`, `AppDurations`
- `lib/src/theme/` — `AppTheme.light()`, `AppTheme.dark()`, `AppSemanticColors`
- `lib/src/components/` — átomos e moléculas usados pelo app
