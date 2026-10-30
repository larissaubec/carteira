import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  test('POST /reset restores the seed data for the session', () async {
    final api = TestApi();
    final token = await api.login();
    await api.send('DELETE', '/transactions/tx_0001', token: token);
    await api.send('PUT', '/me', token: token, body: {'name': 'Outra'});

    final reset = await api.send('POST', '/reset', token: token);
    expect(reset.statusCode, 204);

    final list = await decode(
      await api.send('GET', '/transactions', token: token),
    );
    expect(list['total'], 60);
    final me = await decode(await api.send('GET', '/me', token: token));
    expect(me['name'], 'Ana Ribeiro');
  });
}
