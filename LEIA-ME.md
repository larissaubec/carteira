# Carteira · pacote do aluno (cap/06)

Este pacote tem tudo o que a aula precisa, no estado em que o capítulo começa:

| Pasta | O que é |
|---|---|
| `server/` | API REST simulada em Dart. Suba antes de rodar o app. |
| `apps/mobile/` | O app Flutter. É a pasta que você abre no Android Studio. |
| `packages/core/` | Domínio e dados em Dart puro (modelos, `Result`, repositórios). |
| `packages/design_system/` | Tokens, tema e componentes; galeria em `example/`. |
| `docs/` | Contrato da API e convenções de código. |
| `carteira.code-workspace` | Workspace do VS Code com as quatro pastas. |

Requisitos: Flutter 3.47.1 (canal stable, traz o Dart 3.13.1), Android
Studio com o plugin Flutter **ou** VS Code com a extensão Flutter, e um
emulador Android ou simulador iOS. Confira com `flutter doctor`.

## 1. Subir o servidor

```sh
cd server
dart pub get
dart run                                  # http://localhost:8080
```

Sem latência simulada, para desenvolver: `LATENCY_MIN_MS=0 LATENCY_MAX_MS=0 dart run`.
Teste com `curl http://localhost:8080/health`. Login de teste:
`ana@carteira.dev` / `123456`.

## 2a. Android Studio

**File › Open** e escolha a pasta `apps/mobile` (não a raiz do pacote). O
plugin Flutter reconhece o projeto e resolve `carteira_core` e
`carteira_design_system` por caminho. Aceite o `flutter pub get` quando
for oferecido. As configurações de execução já existem na barra superior:
**Carteira (servidor local)** e, quando o capítulo permitir, **Carteira (sem
servidor)**. Para a galeria de componentes, abra
`packages/design_system/example` como outro projeto.

## 2b. VS Code

**File › Open Workspace from File…** e escolha `carteira.code-workspace`.
Instale as extensões recomendadas quando o VS Code perguntar. Em **Run and
Debug** (F5) estão as mesmas configurações do Android Studio, mais duas para
o servidor. Rode `flutter pub get` na pasta `apps/mobile` uma vez.

## 3. Rodar e testar

```sh
cd apps/mobile
flutter pub get
flutter run                               # escolhe o dispositivo conectado
flutter test                              # testes de widget e de ViewModel
```

No emulador Android o servidor local é `http://10.0.2.2:8080`; no simulador
iOS, `http://localhost:8080`. O app já usa o endereço certo em cada um.

## Se algo der errado

- `flutter doctor` primeiro. A versão precisa ser 3.47.x.
- "Target of URI doesn't exist: package:carteira_core": rode `flutter pub get`
  dentro de `apps/mobile`; as dependências são por caminho relativo, então a
  estrutura de pastas do pacote precisa ficar como está.
- Porta 8080 ocupada: `PORT=8081 dart run` e ajuste com
  `flutter run --dart-define=API_BASE_URL=http://localhost:8081`.
