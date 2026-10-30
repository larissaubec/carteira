import 'json.dart';

/// One page of a paginated list.
class Page<T> {
  const Page({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory Page.fromJson(Json json, T Function(Json) fromJson) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw FormatException('Field "items" must be a list, got: $rawItems');
    }
    return Page(
      items: [for (final item in rawItems) fromJson(asJson(item))],
      page: json.readInt('page', fallback: 1),
      pageSize: json.readInt('pageSize', fallback: rawItems.length),
      total: json.readInt('total', fallback: rawItems.length),
    );
  }

  const Page.empty() : items = const [], page = 1, pageSize = 0, total = 0;

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;

  bool get hasMore => page * pageSize < total;

  bool get isEmpty => items.isEmpty;

  Json toJson(Json Function(T) toJson) => {
    'items': [for (final item in items) toJson(item)],
    'page': page,
    'pageSize': pageSize,
    'total': total,
  };

  @override
  String toString() => 'Page($page/$pageSize of $total)';
}
