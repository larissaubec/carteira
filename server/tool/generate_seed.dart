// Gera o seed.json de forma determinística.
//
// Uso: dart run tool/generate_seed.dart [caminho/seed.json]
import 'dart:convert';
import 'dart:io';
import 'dart:math';

typedef Json = Map<String, Object?>;

const _expenseTemplates = <String, List<(String, double, double)>>{
  'Alimentação': [
    ('Mercado Pão de Açúcar', 180, 420),
    ('Padaria da esquina', 12, 38),
    ('Restaurante Sabor Mineiro', 45, 120),
    ('iFood', 35, 95),
    ('Açougue Bom Corte', 60, 140),
    ('Feira de sábado', 40, 90),
  ],
  'Transporte': [
    ('Uber', 14, 48),
    ('Combustível Shell', 150, 320),
    ('Estacionamento shopping', 12, 30),
    ('Pedágio Bandeirantes', 10, 25),
    ('Bilhete único', 20, 60),
  ],
  'Lazer': [
    ('Cinema Cinemark', 32, 70),
    ('Netflix', 55.9, 55.9),
    ('Spotify', 21.9, 21.9),
    ('Bar com amigos', 60, 180),
    ('Show no Espaço Unimed', 150, 380),
  ],
  'Saúde': [
    ('Farmácia Droga Raia', 25, 140),
    ('Consulta dermatologista', 250, 400),
    ('Academia Smart Fit', 119.9, 119.9),
    ('Plano de saúde Amil', 480, 480),
  ],
  'Educação': [
    ('Curso online Alura', 89, 89),
    ('Livraria Cultura', 60, 190),
    ('Mensalidade da pós', 890, 890),
  ],
  'Outros': [
    ('Presente de aniversário', 80, 250),
    ('Barbearia', 45, 70),
    ('Renner roupas', 120, 380),
  ],
};

const _notes = [
  'Compra do mês',
  'Dividido com a Carla',
  'Pago no crédito',
  'Reembolso pendente',
  'Promoção',
];

class _Generator {
  _Generator(int seed) : _random = Random(seed);

  final Random _random;

  double money(double min, double max) {
    final value = min + _random.nextDouble() * (max - min);
    return (value * 100).round() / 100;
  }

  T pick<T>(List<T> items) => items[_random.nextInt(items.length)];

  bool chance(double probability) => _random.nextDouble() < probability;

  int day(int month) => 1 + _random.nextInt(month == 2 ? 28 : 30);

  String date(int month, int day) {
    final hour = 8 + _random.nextInt(14);
    final minute = _random.nextInt(60);
    return '2026-${_two(month)}-${_two(day)}T${_two(hour)}:${_two(minute)}:00Z';
  }

  Json transaction({
    required String type,
    required double amount,
    required String description,
    required String? category,
    required String date,
    required String account,
    String? note,
    String? toAccount,
  }) => {
    'id': '',
    'type': type,
    'amount': amount,
    'description': description,
    'category': category,
    'date': date,
    'note': note,
    'account': account,
    'toAccount': toAccount,
  };

  Json randomExpense(int month) {
    final category = pick(_expenseTemplates.keys.toList());
    final (description, min, max) = pick(_expenseTemplates[category]!);
    return transaction(
      type: 'expense',
      amount: money(min, max),
      description: description,
      category: category,
      date: date(month, day(month)),
      account: pick(const ['Nubank', 'Carteira']),
      note: chance(0.3) ? pick(_notes) : null,
    );
  }
}

List<Json> _anaTransactions(_Generator g) {
  final items = <Json>[];
  for (final month in [7, 8, 9]) {
    items.addAll([
      g.transaction(
        type: 'income',
        amount: 8500,
        description: 'Salário Acme Tecnologia',
        category: 'Salário',
        date: g.date(month, 5),
        account: 'Itaú',
        note: 'Salário mensal',
      ),
      g.transaction(
        type: 'transfer',
        amount: 1500,
        description: 'Transferência para reserva',
        category: null,
        date: g.date(month, 6),
        account: 'Itaú',
        toAccount: 'Nubank',
        note: 'Reserva de emergência',
      ),
      g.transaction(
        type: 'expense',
        amount: 2100,
        description: 'Aluguel',
        category: 'Moradia',
        date: g.date(month, 10),
        account: 'Itaú',
      ),
      g.transaction(
        type: 'expense',
        amount: 480,
        description: 'Condomínio',
        category: 'Moradia',
        date: g.date(month, 10),
        account: 'Itaú',
      ),
      g.transaction(
        type: 'expense',
        amount: g.money(140, 230),
        description: 'Conta de luz Enel',
        category: 'Moradia',
        date: g.date(month, 15),
        account: 'Nubank',
      ),
      g.transaction(
        type: 'expense',
        amount: g.money(70, 110),
        description: 'Conta de água Sabesp',
        category: 'Moradia',
        date: g.date(month, 15),
        account: 'Nubank',
      ),
      g.transaction(
        type: 'expense',
        amount: 119.9,
        description: 'Internet Vivo Fibra',
        category: 'Moradia',
        date: g.date(month, 20),
        account: 'Nubank',
      ),
      g.transaction(
        type: 'expense',
        amount: g.money(50, 300),
        description: 'Pix para João',
        category: null,
        date: g.date(month, g.day(month)),
        account: 'Nubank',
      ),
    ]);
    if (month != 8) {
      items.add(
        g.transaction(
          type: 'income',
          amount: g.money(900, 1800),
          description: 'Freelance site institucional',
          category: 'Outros',
          date: g.date(month, 22),
          account: 'Nubank',
          note: 'Projeto para a padaria',
        ),
      );
    }
    final randomCount = month == 8 ? 12 : 11;
    for (var i = 0; i < randomCount; i++) {
      items.add(g.randomExpense(month));
    }
  }
  return items;
}

List<Json> _brunoTransactions(_Generator g) {
  final items = <Json>[];
  for (final month in [7, 8, 9]) {
    items.add(
      g.transaction(
        type: 'income',
        amount: 6200,
        description: 'Salário Logística Brasil',
        category: 'Salário',
        date: g.date(month, 5),
        account: 'Itaú',
      ),
    );
    for (var i = 0; i < 5; i++) {
      items.add(g.randomExpense(month));
    }
  }
  items.addAll([
    g.transaction(
      type: 'transfer',
      amount: 800,
      description: 'Transferência para Carteira',
      category: null,
      date: g.date(8, 12),
      account: 'Itaú',
      toAccount: 'Carteira',
    ),
    g.transaction(
      type: 'transfer',
      amount: 500,
      description: 'Transferência para Nubank',
      category: null,
      date: g.date(9, 3),
      account: 'Itaú',
      toAccount: 'Nubank',
    ),
  ]);
  return items;
}

void _assignIds(List<Json> items, int start) {
  items.sort((a, b) => (a['date']! as String).compareTo(b['date']! as String));
  var number = start;
  for (final item in items) {
    item['id'] = 'tx_${number.toString().padLeft(4, '0')}';
    number++;
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

void main(List<String> args) {
  final output = File(args.isEmpty ? 'seed.json' : args.first);
  final g = _Generator(2026);

  final ana = _anaTransactions(g);
  _assignIds(ana, 1);
  final bruno = _brunoTransactions(g);
  _assignIds(bruno, ana.length + 1);

  final seed = <String, Object?>{
    'users': [
      {
        'id': 'usr_01',
        'name': 'Ana Ribeiro',
        'email': 'ana@carteira.dev',
        'password': '123456',
        'avatarUrl': null,
        'createdAt': '2024-03-11T09:00:00Z',
        'transactions': ana,
      },
      {
        'id': 'usr_02',
        'name': 'Bruno Costa',
        'email': 'bruno@carteira.dev',
        'password': '123456',
        'avatarUrl': 'https://i.pravatar.cc/150?img=12',
        'createdAt': '2025-01-20T14:30:00Z',
        'transactions': bruno,
      },
    ],
  };

  output.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(seed)}\n',
  );
  stdout.writeln(
    'Wrote ${output.path}: ${ana.length} transactions for Ana, '
    '${bruno.length} for Bruno',
  );
}
