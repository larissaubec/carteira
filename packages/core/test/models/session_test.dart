import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  final session = Session(token: 'tok_1', user: SampleData.user);

  test('exposes the token only through getters', () {
    expect(session.token, 'tok_1');
    expect(session.authorizationHeader, 'Bearer tok_1');
  });

  test('fromJson parses the nested user', () {
    final parsed = Session.fromJson({
      'token': 'tok_2',
      'user': SampleData.user.toJson(),
    });
    expect(parsed.user, SampleData.user);
    expect(parsed.token, 'tok_2');
  });

  test('toJson round-trips', () {
    expect(Session.fromJson(session.toJson()), session);
  });
}
