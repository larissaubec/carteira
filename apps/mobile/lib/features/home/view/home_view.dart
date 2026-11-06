import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/strings.dart';
import '../../../routing/routes.dart';
import '../view_model/home_view_model.dart';
import 'widgets/month_selector.dart';
import 'widgets/theme_mode_button.dart';
import 'widgets/type_filter.dart';

/// Home screen ("Lançamentos").
///
/// One scrollable column, top to bottom:
///
/// 1. [MonthSelector]: the month every number below refers to;
/// 2. [BalanceCard]: balance, income and expense of the month (`/summary`);
/// 3. "Por categoria": one [CategoryBar] per expense category;
/// 4. search ([AppTextField]) and [TypeFilter]: narrow the list only;
/// 5. the transactions, grouped by day under a [SectionHeader], one
///    [TransactionTile] each, 20 at a time.
///
/// Like the login screen, the view only draws the [HomeViewModel] state and
/// forwards taps to it.
class HomeView extends StatefulWidget {
  const HomeView({
    required this.viewModel,
    required this.themeMode,
    super.key,
  });

  final HomeViewModel viewModel;
  final ValueNotifier<ThemeMode> themeMode;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scroll = ScrollController();
  late final TextEditingController _search;
  bool _leaving = false;

  HomeViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: _viewModel.query);
    _scroll.addListener(_onScroll);
    _bind(_viewModel);
  }

  @override
  void didUpdateWidget(HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      _unbind(oldWidget.viewModel);
      _search.text = widget.viewModel.query;
      _bind(widget.viewModel);
    }
  }

  @override
  void dispose() {
    _unbind(_viewModel);
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _bind(HomeViewModel viewModel) {
    viewModel.addListener(_onViewModelChanged);
    viewModel.loadMore.addListener(_onLoadMoreChanged);
    if (viewModel.summary == null && !viewModel.load.running) {
      viewModel.load.execute();
    }
  }

  void _unbind(HomeViewModel viewModel) {
    viewModel.removeListener(_onViewModelChanged);
    viewModel.loadMore.removeListener(_onLoadMoreChanged);
  }

  /// The token was rejected: back to login, once.
  void _onViewModelChanged() {
    if (!mounted || _leaving || !_viewModel.sessionExpired) return;
    _leaving = true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(Strings.sessionExpired)));
    context.go(Routes.login);
  }

  void _onLoadMoreChanged() {
    final command = _viewModel.loadMore;
    if (!mounted || !command.error || _viewModel.sessionExpired) return;
    command.clearResult();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(Strings.loadMoreError)));
  }

  /// Infinite scroll: fetch the next page a little before the end.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final nearEnd = _scroll.position.extentAfter < 400;
    if (nearEnd && _viewModel.hasMore && !_viewModel.loadMore.running) {
      _viewModel.loadMore.execute();
    }
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(Strings.comingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Strings.appName,
      padded: false,
      actions: [ThemeModeButton(themeMode: widget.themeMode)],
      floatingActionButton: FloatingActionButton(
        tooltip: Strings.newTransaction,
        onPressed: _comingSoon,
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _viewModel,
          _viewModel.load,
          _viewModel.loadMore,
        ]),
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final viewModel = _viewModel;
    final month = viewModel.selectedMonth;

    // First load: nothing to show yet.
    if (month == null) {
      final error = viewModel.load.result?.errorOrNull;
      if (error != null) {
        return StateView.error(
          message: error.message,
          onRetry: viewModel.load.execute,
        );
      }
      return const StateView.loading();
    }

    return RefreshIndicator(
      onRefresh: viewModel.load.execute,
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        // Room for the floating button over the last tile.
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          MonthSelector(
            months: viewModel.months,
            selected: month,
            onSelected: viewModel.selectMonth,
          ),
          _padded(_buildOverview(context, month)),
          _padded(_buildFilters()),
          ..._buildList(context),
        ],
      ),
    );
  }

  /// Balance card and expenses by category: depend only on the month.
  Widget _buildOverview(BuildContext context, String month) {
    final viewModel = _viewModel;
    final summary = viewModel.summary;
    final error = viewModel.load.result?.errorOrNull;

    if (summary == null) {
      return SizedBox(
        height: 240,
        child: error != null && !viewModel.load.running
            ? StateView.error(
                message: error.message,
                onRetry: viewModel.load.execute,
              )
            : const StateView.loading(),
      );
    }

    final money = viewModel.money;
    final muted = context.semanticColors.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap.sm(),
        BalanceCard(
          title: Strings.monthBalance,
          balance: money.format(summary.balance),
          income: money.format(summary.income),
          expense: money.format(summary.expense),
          monthLabel: formatMonthKey(month),
        ),
        const SectionHeader(title: Strings.byCategory),
        if (viewModel.categories.isEmpty)
          Text(
            Strings.noExpenses,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: muted,
            ),
          ),
        for (final row in viewModel.categories)
          CategoryBar(
            label: row.category ?? Strings.noCategory,
            amount: money.format(row.amount),
            share: row.share,
          ),
      ],
    );
  }

  /// Search and type: narrow the list below, not the overview above.
  Widget _buildFilters() {
    final viewModel = _viewModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap.xl(),
        AppTextField(
          key: const Key('home_search'),
          label: Strings.searchHint,
          controller: _search,
          prefixIcon: Icons.search,
          textInputAction: TextInputAction.search,
          onChanged: viewModel.search,
        ),
        const Gap.md(),
        TypeFilter(selected: viewModel.type, onChanged: viewModel.selectType),
        const Gap.sm(),
        SizedBox(
          height: 2,
          child: viewModel.refreshing ? const LinearProgressIndicator() : null,
        ),
      ],
    );
  }

  /// Day headers and tiles. Tiles go edge to edge, like in the gallery;
  /// [ListTile] already has the screen padding inside.
  List<Widget> _buildList(BuildContext context) {
    final viewModel = _viewModel;
    final error = viewModel.listError;

    if (error != null && !viewModel.refreshing) {
      return [
        StateView.error(message: error.message, onRetry: viewModel.retryList),
      ];
    }
    if (viewModel.summary == null) return const [];
    if (viewModel.transactions.isEmpty) {
      if (viewModel.refreshing) return const [];
      return const [
        StateView.empty(
          message: Strings.noTransactions,
          icon: Icons.receipt_long_outlined,
        ),
      ];
    }

    return [
      for (final section in viewModel.sections) ...[
        _padded(SectionHeader(title: formatDayHeading(section.day))),
        for (final transaction in section.items)
          _tile(transaction, viewModel.money),
      ],
      if (viewModel.hasMore)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: viewModel.loadMore.running
                ? const CircularProgressIndicator.adaptive()
                : AppButton.text(
                    label: Strings.loadMore,
                    onPressed: viewModel.loadMore.execute,
                  ),
          ),
        ),
    ];
  }

  /// Domain [Transaction] to design system [TransactionTile]. The design
  /// system does not know the domain, so the mapping lives here.
  Widget _tile(Transaction transaction, MoneyFormatter money) {
    final kind = switch (transaction) {
      Income() => TransactionKind.income,
      Expense() => TransactionKind.expense,
      Transfer() => TransactionKind.transfer,
    };
    final subtitle = switch (transaction) {
      Transfer(:final account, :final toAccount) => '$account → $toAccount',
      Income(:final category, :final account) ||
      Expense(:final category, :final account) =>
        '${category ?? Strings.noCategory} · $account',
    };
    return TransactionTile(
      key: ValueKey(transaction.id),
      kind: kind,
      title: transaction.description,
      subtitle: subtitle,
      amount: money.format(transaction.amount),
      onTap: _comingSoon,
    );
  }

  static Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
    child: child,
  );
}
