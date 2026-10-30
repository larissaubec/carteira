import 'transaction_type.dart';

/// Query used to list transactions.
class TransactionFilter {
  const TransactionFilter({
    this.month,
    this.type,
    this.query,
    this.page = 1,
    this.pageSize = 20,
  });

  /// `YYYY-MM`, or null for all months.
  final String? month;
  final TransactionType? type;

  /// Case-insensitive search on the description.
  final String? query;
  final int page;
  final int pageSize;

  Map<String, String> toQueryParameters() => {
    'month': ?month,
    'type': ?type?.toJson(),
    if (query != null && query!.isNotEmpty) 'q': query!,
    'page': '$page',
    'pageSize': '$pageSize',
  };

  TransactionFilter copyWith({
    String? Function()? month,
    TransactionType? Function()? type,
    String? Function()? query,
    int? page,
    int? pageSize,
  }) => TransactionFilter(
    month: month != null ? month() : this.month,
    type: type != null ? type() : this.type,
    query: query != null ? query() : this.query,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  TransactionFilter nextPage() => copyWith(page: page + 1);

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.month == month &&
      other.type == type &&
      other.query == query &&
      other.page == page &&
      other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(month, type, query, page, pageSize);

  @override
  String toString() => 'TransactionFilter(${toQueryParameters()})';
}
