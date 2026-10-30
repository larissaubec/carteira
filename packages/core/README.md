# carteira_core

Domínio e dados do app Carteira em Dart puro, sem dependência de Flutter.
É o que os capítulos 1 a 5 do curso constroem; o CLI e o app Flutter só
consomem este pacote.

```
lib/src/models/         User, Transaction (sealed: Income, Expense, Transfer),
                        Session, Summary, TransactionFilter, Page
lib/src/result/         Result<T> (Ok / Failure) e AppError (hierarquia fechada)
lib/src/format/         MoneyFormatter (strategy por moeda), datas, validadores,
                        parseList, groupBy, extensão DateTimeX
lib/src/repositories/   interfaces + implementações in_memory/ e remote/
lib/src/api/            ApiClient (http) que fala o contrato de docs/api-contract.md
lib/src/storage/        SessionStorage (interface) e InMemorySessionStorage
```

Regras: repositórios devolvem `Future<Result<T>>` e nunca lançam; modelos são
imutáveis com `copyWith`; `fromJson` tolera campo ausente ou nulo.

```sh
dart test
```
