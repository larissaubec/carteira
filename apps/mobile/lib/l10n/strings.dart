/// Every text the user sees, in one place. Portuguese only for now; this is
/// the seam where a real localization layer would plug in.
abstract final class Strings {
  static const appName = 'Carteira';

  // Auth
  static const loginTitle = 'Entrar';
  static const loginSubtitle = 'Acompanhe suas finanças em um só lugar.';
  static const email = 'E-mail';
  static const password = 'Senha';
  static const signIn = 'Entrar';
  static const signOut = 'Sair da conta';
  static const signOutConfirm = 'Deseja sair da sua conta?';
  static const restoringSession = 'Carregando sua carteira…';

  // Navigation
  static const tabTransactions = 'Lançamentos';
  static const tabProfile = 'Perfil';
  static const theme = 'Tema';

  // Transactions
  static const monthBalance = 'Saldo do mês';
  static const searchHint = 'Buscar por descrição';
  static const allTypes = 'Todos';
  static const income = 'Receita';
  static const expense = 'Despesa';
  static const transfer = 'Transferência';
  static const transferShort = 'Transf.';
  static const noTransactions = 'Nenhum lançamento neste período.';
  static const newTransaction = 'Novo lançamento';
  static const transactionDetail = 'Lançamento';
  static const amount = 'Valor';
  static const description = 'Descrição';
  static const category = 'Categoria';
  static const noCategory = 'Sem categoria';
  static const date = 'Data';
  static const account = 'Conta';
  static const toAccount = 'Conta de destino';
  static const note = 'Observação';
  static const noNote = 'Sem observação';
  static const save = 'Salvar';
  static const delete = 'Excluir';
  static const cancel = 'Cancelar';
  static const deleteConfirmTitle = 'Excluir lançamento?';
  static const deleteConfirmBody = 'Você pode desfazer logo em seguida.';
  static const deleted = 'Lançamento excluído.';
  static const undo = 'Desfazer';
  static const saved = 'Salvo.';
  static const loadMoreError = 'Não foi possível carregar mais itens.';

  // Profile
  static const profileTitle = 'Perfil';
  static const name = 'Nome';
  static const avatarUrl = 'URL da foto';
  static const memberSince = 'Na Carteira desde';

  // Generic
  static const retry = 'Tentar novamente';
  static const genericError = 'Algo deu errado. Tente novamente.';
}
