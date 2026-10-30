import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  late TestApi api;
  late String token;

  setUp(() async {
    api = TestApi();
    token = await api.login();
  });

  group('GET /transactions', () {
    test('lists the first page sorted by date desc', () async {
      final response = await api.send('GET', '/transactions', token: token);
      expect(response.statusCode, 200);
      final json = await decode(response);
      expect(json['page'], 1);
      expect(json['pageSize'], 20);
      expect(json['total'], 60);
      final items = (json['items'] as List<dynamic>).cast<JsonMap>();
      expect(items, hasLength(20));
      final dates = items.map((t) => t['date'] as String).toList();
      final sorted = [...dates]..sort((a, b) => b.compareTo(a));
      expect(dates, orderedEquals(sorted));
    });

    test('paginates', () async {
      final response = await api.send(
        'GET',
        '/transactions?page=4&pageSize=25',
        token: token,
      );
      final json = await decode(response);
      expect(json['items'], isEmpty);
      expect(json['total'], 60);
      final third = await decode(
        await api.send('GET', '/transactions?page=3&pageSize=25', token: token),
      );
      expect(third['items'], hasLength(10));
    });

    test('filters by month, type and text', () async {
      final json = await decode(
        await api.send(
          'GET',
          '/transactions?month=2026-08&type=expense&q=conta',
          token: token,
        ),
      );
      final items = (json['items'] as List<dynamic>).cast<JsonMap>();
      expect(items, isNotEmpty);
      for (final item in items) {
        expect(item['date'], startsWith('2026-08'));
        expect(item['type'], 'expense');
        expect(
          (item['description'] as String).toLowerCase(),
          contains('conta'),
        );
      }
      expect(json['total'], items.length);
    });

    test('rejects invalid query params with 422', () async {
      final response = await api.send(
        'GET',
        '/transactions?month=agosto&page=0',
        token: token,
      );
      expect(response.statusCode, 422);
      expect(
        (await errorFields(response)).keys,
        containsAll(['month', 'page']),
      );
    });
  });

  group('GET /transactions/:id', () {
    test('returns the transaction', () async {
      final response = await api.send(
        'GET',
        '/transactions/tx_0001',
        token: token,
      );
      expect(response.statusCode, 200);
      expect((await decode(response))['id'], 'tx_0001');
    });

    test('returns 404 for unknown id', () async {
      final response = await api.send(
        'GET',
        '/transactions/tx_9999',
        token: token,
      );
      expect(response.statusCode, 404);
      expect(await errorCode(response), 'not_found');
    });
  });

  group('POST /transactions', () {
    test('creates with a new id and returns 201', () async {
      final response = await api.send(
        'POST',
        '/transactions',
        token: token,
        body: sampleTransaction(),
      );
      expect(response.statusCode, 201);
      final json = await decode(response);
      expect(json['id'], 'tx_0081');
      expect(json['amount'], 42.5);
      expect(json['toAccount'], isNull);
      final fetched = await api.send(
        'GET',
        '/transactions/tx_0081',
        token: token,
      );
      expect(fetched.statusCode, 200);
    });

    test('returns 422 with field errors', () async {
      final response = await api.send(
        'POST',
        '/transactions',
        token: token,
        body: {...sampleTransaction(), 'amount': -5, 'description': ''},
      );
      expect(response.statusCode, 422);
      final json = await decode(response);
      final error = json['error'] as JsonMap;
      expect(error['code'], 'validation');
      final fields = error['fields'] as JsonMap;
      expect(fields['amount'], 'must be greater than zero');
      expect(fields['description'], 'must not be empty');
    });

    test('transfer requires toAccount', () async {
      final response = await api.send(
        'POST',
        '/transactions',
        token: token,
        body: {
          ...sampleTransaction(type: 'transfer'),
          'toAccount': null,
        },
      );
      expect(response.statusCode, 422);
      expect(await errorFields(response), contains('toAccount'));
    });
  });

  group('PUT /transactions/:id', () {
    test('replaces the transaction keeping the id from the path', () async {
      final response = await api.send(
        'PUT',
        '/transactions/tx_0001',
        token: token,
        body: {
          ...sampleTransaction(),
          'id': 'tx_0099',
          'description': 'Editado',
        },
      );
      expect(response.statusCode, 200);
      final json = await decode(response);
      expect(json['id'], 'tx_0001');
      expect(json['description'], 'Editado');
    });

    test('returns 404 for unknown id', () async {
      final response = await api.send(
        'PUT',
        '/transactions/tx_9999',
        token: token,
        body: sampleTransaction(),
      );
      expect(response.statusCode, 404);
    });
  });

  group('DELETE /transactions/:id', () {
    test('returns 204 and then 404', () async {
      final first = await api.send(
        'DELETE',
        '/transactions/tx_0002',
        token: token,
      );
      expect(first.statusCode, 204);
      final second = await api.send(
        'DELETE',
        '/transactions/tx_0002',
        token: token,
      );
      expect(second.statusCode, 404);
      final list = await decode(
        await api.send('GET', '/transactions', token: token),
      );
      expect(list['total'], 59);
    });
  });

  test('sessions are isolated per token', () async {
    final other = await api.login();
    await api.send('DELETE', '/transactions/tx_0003', token: token);
    final mine = await api.send('GET', '/transactions/tx_0003', token: token);
    final theirs = await api.send('GET', '/transactions/tx_0003', token: other);
    expect(mine.statusCode, 404);
    expect(theirs.statusCode, 200);
  });
}
