# carteira_server

API REST simulada do app Carteira. Escrita em Dart com `shelf`, guarda tudo em
memória e cria um conjunto de dados exclusivo por sessão: cada login recebe uma
cópia do `seed.json`, então vários alunos podem usar a mesma instância sem
interferir uns nos outros.

O contrato completo está em [`../docs/api-contract.md`](../docs/api-contract.md).

## Rodando

```sh
dart pub get
dart run                      # http://localhost:8080
```

Sem latência, para desenvolvimento:

```sh
LATENCY_MIN_MS=0 LATENCY_MAX_MS=0 dart run
```

No emulador Android o servidor local é `http://10.0.2.2:8080`.

## Variáveis de ambiente

| Variável | Padrão | Uso |
|---|---|---|
| `PORT` | `8080` | porta HTTP |
| `LATENCY_MIN_MS` | `300` | latência mínima simulada |
| `LATENCY_MAX_MS` | `800` | latência máxima simulada |
| `SEED_FILE` | `seed.json` na pasta atual, senão ao lado do binário | dados iniciais |

## Exemplos com curl

Login (usuários do seed: `ana@carteira.dev` e `bruno@carteira.dev`, senha `123456`):

```sh
curl -s -X POST http://localhost:8080/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"ana@carteira.dev","password":"123456"}'
```

Guarde o `token` da resposta e use nas demais rotas:

```sh
TOKEN=tok_...
curl -s "http://localhost:8080/transactions?month=2026-09&pageSize=5" \
  -H "Authorization: Bearer $TOKEN"

curl -s "http://localhost:8080/summary?month=2026-09" \
  -H "Authorization: Bearer $TOKEN"

curl -s -X DELETE http://localhost:8080/transactions/tx_0060 \
  -H "Authorization: Bearer $TOKEN" -w '%{http_code}\n'
```

Simulando falhas nas aulas de tratamento de erro:

```sh
curl -s http://localhost:8080/me -H "Authorization: Bearer $TOKEN" -H 'X-Fail: 500'
curl -s http://localhost:8080/me -H "Authorization: Bearer $TOKEN" -H 'X-Fail: expired'
curl -s http://localhost:8080/me -H "Authorization: Bearer $TOKEN" -H 'X-Delay-Ms: 3000'
```

Voltar os dados da sessão ao estado inicial:

```sh
curl -s -X POST http://localhost:8080/reset -H "Authorization: Bearer $TOKEN"
```

## Estrutura

```
bin/server.dart            ponto de entrada: lê o ambiente e sobe o servidor
lib/carteira_server.dart   API pública: createHandler, Seed, LatencyConfig, SessionStore
lib/src/handler.dart       monta o pipeline de middlewares e os routers
lib/src/middleware/        cors, tratamento de erro, latência, X-Fail, auth
lib/src/routes/            auth, me (perfil), transactions, summary, reset, health
lib/src/store.dart         sessões em memória, uma cópia do seed por token
lib/src/validation.dart    validações que geram 422
lib/src/seed.dart          carregamento do seed.json
seed.json                  dados iniciais, gerados por tool/generate_seed.dart
```

## Testes

Os testes chamam o handler em processo, sem abrir porta:

```sh
dart test
```

## Regenerando o seed

```sh
dart run tool/generate_seed.dart
```

O gerador é determinístico: o mesmo comando sempre produz o mesmo arquivo.

## Docker

```sh
docker build -t carteira-server .
docker run -p 8080:8080 carteira-server
```

Serve para hospedar em plataformas como Render ou Koyeb. Lembre que o estado
fica em memória: quando o serviço reinicia, as sessões somem e o aluno precisa
fazer login de novo.
