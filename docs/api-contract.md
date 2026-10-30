# Contrato da API do servidor mock

Base URL local: `http://localhost:8080`. Emulador Android: `http://10.0.2.2:8080`.

## Regras gerais

- Todas as respostas são JSON com `Content-Type: application/json; charset=utf-8`.
- Todas as rotas exceto `POST /auth/login` e `GET /health` exigem
  `Authorization: Bearer <token>`. Sem token ou token desconhecido: `401 unauthorized`.
- No login o servidor cria um **conjunto de dados exclusivo do token** copiado do
  `seed.json`. Cada sessão vê e altera só os próprios dados.
- Datas em ISO 8601 UTC (`2026-09-06T14:32:00Z`). Valores monetários como `number`
  com duas casas, sempre positivos; o tipo diz se é entrada ou saída.
- Campos opcionais são enviados **sempre**, com `null` quando vazios. O cliente deve
  tolerar também a ausência do campo.
- Latência simulada padrão entre 300 e 800 ms (`LATENCY_MIN_MS` / `LATENCY_MAX_MS`;
  use 0 nos testes).
- CORS liberado para qualquer origem.

## Cabeçalhos de simulação

| Cabeçalho | Efeito |
|---|---|
| `X-Delay-Ms: 3000` | força a latência informada nessa requisição |
| `X-Fail: 500` | responde `500 internal` |
| `X-Fail: timeout` | nunca responde (fecha após 60 s) |
| `X-Fail: expired` | responde `401 token_expired` |

## Formato de erro

```json
{ "error": { "code": "not_found", "message": "Transaction tx_9999 not found" } }
```

Em `422` o objeto ganha `fields`:

```json
{ "error": { "code": "validation", "message": "Invalid transaction",
             "fields": { "amount": "must be greater than zero" } } }
```

| Status | code |
|---|---|
| 400 | `bad_request` (JSON malformado) |
| 401 | `invalid_credentials`, `unauthorized`, `token_expired` |
| 404 | `not_found` |
| 422 | `validation` |
| 500 | `internal` |

## Modelos

```json
// user
{ "id": "usr_01", "name": "Ana Ribeiro", "email": "ana@carteira.dev",
  "avatarUrl": null, "createdAt": "2024-03-11T09:00:00Z" }

// transaction
{ "id": "tx_0042", "type": "expense", "amount": 89.9, "description": "Mercado",
  "category": "Alimentação", "date": "2026-09-06T14:32:00Z", "note": null,
  "account": "Nubank", "toAccount": null }
// type: income | expense | transfer. transfer exige toAccount e não entra no saldo.

// summary
{ "month": "2026-09", "income": 8500.0, "expense": 3210.45, "balance": 5289.55 }
```

## Rotas

| Método | Rota | Corpo | Sucesso | Erros |
|---|---|---|---|---|
| POST | `/auth/login` | `{email, password}` | `200 {token, user}` | 401 invalid_credentials, 422 |
| POST | `/auth/logout` | | `204` | 401 |
| GET | `/health` | | `200 {status: "ok", version}` | |
| GET | `/me` | | `200 user` | 401 |
| PUT | `/me` | `{name, avatarUrl}` | `200 user` | 401, 422 (name vazio) |
| GET | `/transactions` | query `month=YYYY-MM`, `type`, `q`, `page` (1), `pageSize` (20) | `200 {items, page, pageSize, total}` | 401, 422 |
| GET | `/transactions/:id` | | `200 transaction` | 401, 404 |
| POST | `/transactions` | transaction sem `id` | `201 transaction` | 401, 422 |
| PUT | `/transactions/:id` | transaction (id do caminho prevalece) | `200 transaction` | 401, 404, 422 |
| DELETE | `/transactions/:id` | | `204` | 401, 404 |
| GET | `/summary` | query `month` (padrão: mês atual) | `200 summary` | 401 |
| POST | `/reset` | | `204` (dados da sessão voltam ao seed) | 401 |

Lista de transações ordenada por `date` decrescente. `q` filtra por `description`
sem diferenciar maiúsculas. `total` é a contagem após os filtros.

## Validação de transaction

- `type` em `income | expense | transfer`
- `amount` > 0
- `description` não vazia
- `date` ISO 8601 válida
- `account` não vazia
- `toAccount` obrigatório quando `type = transfer`

## Seed

Usuários (senha `123456` para todos):

| id | nome | email |
|---|---|---|
| usr_01 | Ana Ribeiro | ana@carteira.dev |
| usr_02 | Bruno Costa | bruno@carteira.dev |

Categorias: Alimentação, Transporte, Moradia, Lazer, Saúde, Educação, Salário, Outros.
Contas: Nubank, Itaú, Carteira. Cerca de 60 lançamentos para Ana entre julho e
setembro de 2026, 20 para Bruno. Alguns lançamentos com `category` e `note` nulos
de propósito.

## Configuração

| Variável | Padrão |
|---|---|
| `PORT` | 8080 |
| `LATENCY_MIN_MS` | 300 |
| `LATENCY_MAX_MS` | 800 |
| `SEED_FILE` | `seed.json` ao lado do binário |
