import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('write, read and clear', () async {
    final storage = InMemorySessionStorage();
    expect(await storage.read(), isNull);
    final session = Session(token: 't', user: SampleData.user);
    await storage.write(session);
    expect(await storage.read(), session);
    await storage.clear();
    expect(await storage.read(), isNull);
  });
}
