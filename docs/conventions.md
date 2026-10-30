# Convenções do projeto

Fonte da verdade para quem escreve código neste repositório: instrutor, alunos e
agentes. Tudo o que estiver aqui vale para todos os pacotes.

## Versões

| Ferramenta | Versão |
|---|---|
| Flutter | 3.47.1 (canal stable) |
| Dart | 3.13.1 |
| Android SDK | 36 |
| Java | 21 (JBR do Android Studio) |

`environment: sdk: ^3.13.0` em todos os pubspecs. `flutter: ">=3.47.0"` nos pacotes Flutter.

## Idioma

- Identificadores, nomes de arquivos, mensagens de commit e comentários de código: **inglês**.
- Textos vistos pelo usuário do app (labels, mensagens de erro na tela) e toda a apostila: **português**.
- Nome do produto é "Carteira" e aparece como string de UI, nunca como identificador.

## Nomes de pacotes

| Pasta | Nome no pubspec | Tipo |
|---|---|---|
| `server/` | `carteira_server` | Dart (shelf) |
| `packages/core/` | `carteira_core` | Dart puro |
| `packages/design_system/` | `carteira_design_system` | Flutter package |
| `apps/cli/` | `carteira_cli` | Dart CLI |
| `apps/mobile/` | `carteira_app` | Flutter app (org `dev.carteira`) |

Dependências entre pacotes são por caminho (`path:`), não por pub workspace,
para que cada projeto abra sozinho no Android Studio.

## Dependências permitidas

`http`, `shelf`, `shelf_router`, `go_router`, `intl`, `shared_preferences`,
`test`, `flutter_test`, `integration_test`, `lints`, `flutter_lints`.
Qualquer outra precisa de justificativa no README do pacote.

## Estilo

- `dart format` com linha de 80 colunas. Vírgula final obrigatória.
- `analysis_options.yaml` da raiz incluído por todos os pacotes; zero warnings.
- Construtores `const` sempre que possível. Campos `final`. Modelos imutáveis com `copyWith`.
- Aspas simples. Sem `print` fora do CLI e do servidor (usar `Logger` ou `stdout`).
- Um tipo público por arquivo, arquivo em `snake_case` com o nome do tipo.
- `sealed class` para hierarquias fechadas (`Transaction`, `Result`, `AppError`)
  e `switch` exaustivo, sem `default`.
- Repositórios devolvem `Future<Result<T>>`, nunca lançam exceção para o chamador.
- Views não conhecem repositórios. ViewModels não importam `package:flutter/widgets.dart`
  além de `ChangeNotifier`/`ValueNotifier` (via `package:flutter/foundation.dart`).

## Camadas

```
ui        views (widgets) e view_models (ChangeNotifier + Command)
domain    modelos, Result, AppError, interfaces de repositório      (carteira_core)
data      ApiClient, repositórios remote e in_memory, storage       (carteira_core / app)
```

A regra de dependência aponta para dentro: ui -> domain <- data.

## Testes

- Todo arquivo em `lib/src/**` tem um par em `test/**` com o mesmo caminho.
- Fakes em vez de mocks: os repositórios in_memory são os fakes oficiais.
- `MockClient` de `package:http/testing.dart` para o `ApiClient`.
- Nome do teste em inglês descrevendo comportamento: `'returns Failure when token is missing'`.

## Git

- `main` é o app completo. `cap/00` a `cap/15` são os checkpoints de capítulo.
- Commits no imperativo, em inglês: `Add Transaction sealed class`.
