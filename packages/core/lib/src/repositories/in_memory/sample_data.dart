import '../../models/transaction.dart';
import '../../models/user.dart';

/// Small realistic dataset used by the CLI, the app before chapter 13 and
/// the tests. Dates are in September and August 2026.
abstract final class SampleData {
  static const password = '123456';

  static final user = User(
    id: 'usr_01',
    name: 'Ana Ribeiro',
    email: 'ana@carteira.dev',
    createdAt: DateTime.utc(2024, 3, 11, 9),
  );

  static List<Transaction> transactions() => [
    Income(
      id: 'tx_0001',
      amount: 8500,
      description: 'Salário',
      category: 'Salário',
      date: DateTime.utc(2026, 9, 5, 9),
      account: 'Itaú',
    ),
    Expense(
      id: 'tx_0002',
      amount: 89.9,
      description: 'Mercado',
      category: 'Alimentação',
      date: DateTime.utc(2026, 9, 6, 14, 32),
      account: 'Nubank',
    ),
    Expense(
      id: 'tx_0003',
      amount: 1850,
      description: 'Aluguel',
      category: 'Moradia',
      date: DateTime.utc(2026, 9, 1, 8),
      account: 'Itaú',
      note: 'Vencimento dia 1',
    ),
    Transfer(
      id: 'tx_0004',
      amount: 1000,
      description: 'Reserva do mês',
      date: DateTime.utc(2026, 9, 5, 10),
      account: 'Itaú',
      toAccount: 'Nubank',
    ),
    Expense(
      id: 'tx_0005',
      amount: 42.5,
      description: 'Uber',
      category: 'Transporte',
      date: DateTime.utc(2026, 9, 6, 19, 5),
      account: 'Nubank',
    ),
    Expense(
      id: 'tx_0006',
      amount: 35,
      description: 'Padaria',
      date: DateTime.utc(2026, 9, 7, 8, 15),
      account: 'Carteira',
    ),
    Expense(
      id: 'tx_0007',
      amount: 129.9,
      description: 'Curso online',
      category: 'Educação',
      date: DateTime.utc(2026, 9, 3, 21),
      account: 'Nubank',
    ),
    Expense(
      id: 'tx_0008',
      amount: 260,
      description: 'Cinema e jantar',
      category: 'Lazer',
      date: DateTime.utc(2026, 9, 4, 22, 40),
      account: 'Nubank',
      note: 'Aniversário do Pedro',
    ),
    Income(
      id: 'tx_0009',
      amount: 8500,
      description: 'Salário',
      category: 'Salário',
      date: DateTime.utc(2026, 8, 5, 9),
      account: 'Itaú',
    ),
    Expense(
      id: 'tx_0010',
      amount: 1850,
      description: 'Aluguel',
      category: 'Moradia',
      date: DateTime.utc(2026, 8, 1, 8),
      account: 'Itaú',
    ),
    Expense(
      id: 'tx_0011',
      amount: 612.3,
      description: 'Mercado do mês',
      category: 'Alimentação',
      date: DateTime.utc(2026, 8, 9, 11),
      account: 'Nubank',
    ),
    Expense(
      id: 'tx_0012',
      amount: 180,
      description: 'Consulta',
      category: 'Saúde',
      date: DateTime.utc(2026, 8, 18, 15),
      account: 'Itaú',
    ),
    Income(
      id: 'tx_0013',
      amount: 1200,
      description: 'Freela site',
      category: 'Outros',
      date: DateTime.utc(2026, 8, 22, 17),
      account: 'Nubank',
      note: 'Cliente: padaria Pão Quente',
    ),
  ];
}
