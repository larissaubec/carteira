# carteira_app

O app Flutter do curso. Abra esta pasta no Android Studio (File → Open) e
rode em um emulador Android ou simulador iOS com `flutter run`.

## O que já funciona

- **Login** com o `AuthRepository` do `carteira_core`: valida o formulário,
  mostra o erro na própria tela (senha errada, servidor fora do ar) e, no
  sucesso, guarda a sessão (token + usuário) com `shared_preferences`.
- **Sessão persistida**: ao abrir o app com sessão guardada, ele vai direto
  para a Home. Se o servidor recusar o token (401), a sessão é apagada e o
  app volta para o login.
- **Home (Lançamentos)**: seletor de mês, `BalanceCard` com o resumo do mês
  (`GET /summary`), gastos "Por categoria" (`CategoryBar`, calculados a partir
  das despesas do mês), busca, filtro por tipo e a lista agrupada por dia
  (`SectionHeader` + `TransactionTile`), com paginação de 20 em 20.
- **Perfil**: dados do usuário e "Sair da conta".

## Como rodar

```sh
flutter pub get
flutter run                                    # usa o servidor local
flutter run --dart-define=USE_IN_MEMORY=true   # sem servidor
flutter test
```

Com servidor: suba antes `cd ../../server && dart run`. O endereço padrão é
`http://10.0.2.2:8080` no emulador Android e `http://localhost:8080` no resto.
Em um celular de verdade, use o IP do computador:
`flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080`.

## Estrutura

```
lib/
  main.dart                    restaura a sessão e sobe o app
  config/                      dependências (repositórios) e --dart-define
  data/storage/                SessionStorage com shared_preferences
  routing/                     go_router: rotas, guarda de sessão, barra inferior
  utils/                       Command (estado das ações) e formatação de mês
  l10n/strings.dart            todos os textos da tela
  features/
    auth/   view/ + view_model/    login
    home/   view/ + view_model/    lançamentos do mês
    profile/view/ + view_model/    perfil e saída
```

Cada cena segue o mesmo padrão: a **View** só desenha e repassa toques; o
**ViewModel** (`ChangeNotifier` + `Command`) fala com os repositórios do
`carteira_core`. Views não conhecem repositórios; quem monta cada ViewModel é
o router.
