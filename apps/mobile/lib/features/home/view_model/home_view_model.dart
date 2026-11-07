import 'dart:async';

import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../utils/command.dart';

/// Share of one category in the expenses of the month.
///
/// [category] is null for expenses without a category; the view decides how
/// to call them ("Sem categoria").
typedef CategoryTotal = ({String? category, double amount, double share});

/// Transactions of one calendar day, in the order the API sent them.
typedef DaySection = ({DateTime day, List<Transaction> items});

/// State and actions of the home screen ("Lançamentos").
///
/// The screen has two parts that answer to different filters:
///
/// - the month overview (balance card and "por categoria") depends only on
///   the selected month: `GET /summary` plus every expense of the month;
/// - the list depends on the month, the type segment and the search box:
///   `GET /transactions`, 20 at a time.
///
/// Changing the month reloads both; typing in the search box or picking a
/// type reloads only the list.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required TransactionRepository transactionRepository,
    required AuthRepository authRepository,
    DateTime Function()? clock,
    this.searchDelay = const Duration(milliseconds: 400),
    this.pageSize = 20,
  }) : _transactionRepository = transactionRepository,
       _authRepository = authRepository,
       months = _lastMonths((clock ?? DateTime.now)(), count: 12) {
    load = Command0<void>(_load);
    loadMore = Command0<void>(_loadMore);
  }

  final TransactionRepository _transactionRepository;
  final AuthRepository _authRepository;

  /// Wait after the last keystroke before searching.
  final Duration searchDelay;

  /// Items per request of the list.
  final int pageSize;

  /// Formats every amount on the screen.
  final MoneyFormatter money = MoneyFormatter.forCurrency(Currency.brl);

  /// Month keys (`YYYY-MM`) offered in the selector, newest first.
  final List<String> months;

  /// Loads the overview and the first page of the selected month. On the
  /// first run it also picks the month: the one of the newest transaction.
  late final Command0<void> load;

  /// Appends the next page of the list.
  late final Command0<void> loadMore;

  String? _selectedMonth;
  bool _loadAgain = false;
  Summary? _summary;
  List<CategoryTotal> _categories = const [];

  TransactionType? _type;
  String _query = '';
  Timer? _searchTimer;

  List<Transaction> _items = const [];
  int _page = 0;
  int _total = 0;
  int _listVersion = 0;
  bool _refreshing = false;
  AppError? _listError;

  bool _sessionExpired = false;

  /// Selected month key, or null before the first [load] finishes.
  String? get selectedMonth => _selectedMonth;

  /// Totals of the selected month.
  Summary? get summary => _summary;

  /// Expenses of the month by category, biggest first.
  List<CategoryTotal> get categories => _categories;

  /// Type segment: null means all.
  TransactionType? get type => _type;

  /// Text in the search box.
  String get query => _query;

  /// Loaded transactions, newest first.
  List<Transaction> get transactions => _items;

  /// [transactions] grouped by day, for the section headers.
  List<DaySection> get sections => [
    for (final MapEntry(key: day, value: items) in groupBy(
      _items,
      (Transaction transaction) => transaction.date.dayStart,
    ).entries)
      (day: day, items: items),
  ];

  /// The server has more items than the ones loaded.
  bool get hasMore => _items.length < _total;

  /// The list is being reloaded after a filter change.
  bool get refreshing => _refreshing;

  /// Why the last list reload failed, or null.
  AppError? get listError => _listError;

  /// The API rejected the token (expired, or the server restarted). The
  /// local session is already cleared; the view sends the user to login.
  bool get sessionExpired => _sessionExpired;

  /// Shows [monthKey]. Reloads the overview and the list.
  void selectMonth(String monthKey) {
    if (monthKey == _selectedMonth) return;
    _selectedMonth = monthKey;
    // Drop the previous month at once, so the screen never shows September
    // numbers under the October chip while the new month loads.
    _summary = null;
    _categories = const [];
    _items = const [];
    _total = 0;
    _listError = null;
    _listVersion++; // a list reload of the old month is now stale
    _refreshing = false;
    notifyListeners();
    if (load.running) {
      _loadAgain = true;
    } else {
      load.execute();
    }
  }

  /// Filters the list by type; null shows every type.
  void selectType(TransactionType? type) {
    if (type == _type) return;
    _type = type;
    notifyListeners();
    _refreshList();
  }

  /// Filters the list by description, after [searchDelay] without typing.
  void search(String text) {
    _query = text;
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDelay, _refreshList);
  }

  /// Retries the list after [listError].
  void retryList() => _refreshList();

  Future<Result<void>> _load() async {
    Result<void> result;
    do {
      _loadAgain = false;
      result = await _loadMonth();
    } while (_loadAgain);
    return result;
  }

  Future<Result<void>> _loadMonth() async {
    if (_selectedMonth == null) {
      final newest = await _newestMonth();
      switch (newest) {
        case Failure(:final error):
          return _fail(error);
        case Ok(:final value):
          _selectedMonth = value;
          if (!months.contains(value)) {
            // `YYYY-MM` sorts as text; keep newest first.
            months
              ..add(value)
              ..sort((a, b) => b.compareTo(a));
          }
      }
    }
    final month = _selectedMonth!;

    // A month load supersedes any list reload in flight.
    final version = ++_listVersion;
    _refreshing = false;
    final (summary, expenses, page) = await (
      _transactionRepository.summary(month),
      _expensesOf(month),
      _transactionRepository.list(_filter(page: 1)),
    ).wait;
    // The user picked another month meanwhile; the loop in [_load] runs
    // again for it.
    if (_loadAgain) return const Ok(null);

    final error =
        summary.errorOrNull ?? expenses.errorOrNull ?? page.errorOrNull;
    if (error != null) return _fail(error);

    _summary = summary.valueOrNull;
    _categories = byCategory(expenses.valueOrNull ?? const []);
    // Skip the page when a type or search change already reloaded the list.
    if (version == _listVersion) {
      _applyPage(page.valueOrNull!, append: false);
      _listError = null;
    }
    notifyListeners();
    return const Ok(null);
  }

  /// Month of the newest transaction, so the screen opens on a month with
  /// data. Falls back to the current month when there are no transactions.
  Future<Result<String>> _newestMonth() async {
    final result = await _transactionRepository.list(
      const TransactionFilter(pageSize: 1),
    );
    return result.map(
      (page) =>
          page.items.isEmpty ? months.first : page.items.first.date.monthKey,
    );
  }

  /// Every expense of [month], following the pages (100 per request, the
  /// maximum the API accepts).
  Future<Result<List<Transaction>>> _expensesOf(String month) async {
    final all = <Transaction>[];
    var filter = TransactionFilter(
      month: month,
      type: TransactionType.expense,
      pageSize: 100,
    );
    while (true) {
      final result = await _transactionRepository.list(filter);
      switch (result) {
        case Failure(:final error):
          return Failure(error);
        case Ok(:final value):
          all.addAll(value.items);
          if (!value.hasMore || value.items.isEmpty) return Ok(all);
          filter = filter.nextPage();
      }
    }
  }

  Future<void> _refreshList() async {
    final month = _selectedMonth;
    if (month == null) return;
    final version = ++_listVersion;
    _refreshing = true;
    notifyListeners();

    final result = await _transactionRepository.list(_filter(page: 1));
    if (version != _listVersion) return;

    _refreshing = false;
    switch (result) {
      case Ok(:final value):
        _applyPage(value, append: false);
        _listError = null;
      case Failure(:final error):
        _listError = error;
        await _fail(error);
    }
    notifyListeners();
  }

  Future<Result<void>> _loadMore() async {
    if (!hasMore || _refreshing || _selectedMonth == null) {
      return const Ok(null);
    }
    final version = _listVersion;
    final result = await _transactionRepository.list(_filter(page: _page + 1));
    if (version != _listVersion) return const Ok(null);
    switch (result) {
      case Ok(:final value):
        _applyPage(value, append: true);
        notifyListeners();
        return const Ok(null);
      case Failure(:final error):
        return _fail(error);
    }
  }

  TransactionFilter _filter({required int page}) {
    final text = _query.trim();
    return TransactionFilter(
      month: _selectedMonth,
      type: _type,
      query: text.isEmpty ? null : text,
      page: page,
      pageSize: pageSize,
    );
  }

  void _applyPage(Page<Transaction> page, {required bool append}) {
    _items = append ? [..._items, ...page.items] : page.items;
    _page = page.page;
    _total = page.total;
  }

  /// Records [error]. A 401 means the stored token is no longer valid: clear
  /// the session so the next launch starts on the login screen.
  Future<Result<void>> _fail(AppError error) async {
    if (error is UnauthorizedError && !_sessionExpired) {
      _sessionExpired = true;
      await _authRepository.logout();
      notifyListeners();
    }
    return Failure(error);
  }

  /// Groups [expenses] by category and computes each share of the total,
  /// biggest first. Public so it can be tested on its own.
  static List<CategoryTotal> byCategory(List<Transaction> expenses) {
    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    if (total <= 0) return const [];
    final groups = groupBy(expenses, (Transaction t) => t.category);
    final rows = [
      for (final MapEntry(key: category, value: items) in groups.entries)
        (
          category: category,
          amount: items.fold<double>(0, (sum, t) => sum + t.amount),
          share: 0.0,
        ),
    ];
    rows.sort((a, b) => b.amount.compareTo(a.amount));
    return [
      for (final row in rows)
        (category: row.category, amount: row.amount, share: row.amount / total),
    ];
  }

  /// [count] month keys ending at the month of [now], newest first.
  static List<String> _lastMonths(DateTime now, {required int count}) => [
    for (var i = 0; i < count; i++) DateTime(now.year, now.month - i).monthKey,
  ];

  @override
  void dispose() {
    _searchTimer?.cancel();
    load.dispose();
    loadMore.dispose();
    super.dispose();
  }
}
